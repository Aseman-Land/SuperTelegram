#define DATABASE_SRC_PATH ":/database/commands.sqlite"
#define DATABASE_DST_PATH QString(AsemanApplication::homePath() + "/commands.sqlite")

#include "commandsdatabase.h"
#include "asemantools/asemanapplication.h"

#include <QFile>
#include <QFileInfo>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QUuid>
#include <QDebug>

class CommandsDatabasePrivate
{
public:
    QSqlDatabase db;
    QString connectionName;
};

CommandsDatabase::CommandsDatabase(QObject *parent) :
    QObject(parent)
{
    p = new CommandsDatabasePrivate;
    p->connectionName = QUuid::createUuid().toString();

    if(!QFileInfo::exists(DATABASE_DST_PATH))
        QFile::copy(DATABASE_SRC_PATH, DATABASE_DST_PATH);

    QFile(DATABASE_DST_PATH).setPermissions(QFileDevice::ReadUser|QFileDevice::WriteUser|
                                  QFileDevice::ReadGroup|QFileDevice::WriteGroup);

    p->db = QSqlDatabase::addDatabase("QSQLITE", p->connectionName);
    p->db.setDatabaseName(DATABASE_DST_PATH);
    p->db.open();
}

QString CommandsDatabase::timerMessageInsert(const TimerMessage &tmsg)
{
    TimerMessage item = tmsg;
    if(item.guid.isEmpty())
        item.guid = QUuid::createUuid().toString();

    QSqlQuery query(p->db);
    query.prepare("INSERT OR REPLACE INTO TimerMessages (guid,peerId,peerType,peerAccessHash,message,time) "
                  "VALUES (:guid, :peerId, :peerType, :peerAccessHash, :message, :time)");
    query.bindValue(":guid", item.guid);
    query.bindValue(":peerId", item.peer.chatId()? item.peer.chatId() : item.peer.userId());
    query.bindValue(":peerType", inputPeerToCmdPeer(item.peer.classType()));
    query.bindValue(":peerAccessHash", item.peer.accessHash());
    query.bindValue(":message", item.message);
    query.bindValue(":time", item.dateTime);
    if(!query.exec())
    {
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
        return QString();
    }

    return item.guid;
}

bool CommandsDatabase::timerMessageRemove(const QString &guid)
{
    if(guid.isEmpty())
        return false;

    QSqlQuery query(p->db);
    query.prepare("DELETE FROM TimerMessages WHERE guid=:guid");
    query.bindValue(":guid", guid);
    if(!query.exec())
    {
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
        return false;
    }

    return true;
}

QList<TimerMessage> CommandsDatabase::timerMessageFetchAll()
{
    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM TimerMessages ORDER BY time ASC");
    return timerMessageQueryFetch(query);
}

QList<TimerMessage> CommandsDatabase::timerMessageFetch(const QDateTime &dt)
{
    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM TimerMessages WHERE time=:time");
    query.bindValue(":time", dt);
    return timerMessageQueryFetch(query);
}

QList<TimerMessage> CommandsDatabase::timerMessageFetchNext()
{
    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM TimerMessages ORDER BY time ASC LIMIT 1");

    const QList<TimerMessage> &list = timerMessageQueryFetch(query);
    if(list.isEmpty())
        return list;
    else
        return timerMessageFetch(list.first().dateTime);
}

QList<TimerMessage> CommandsDatabase::timerMessageFetchExpired()
{
    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM TimerMessages WHERE time<:time");
    query.bindValue(":time", QDateTime::currentDateTime());
    return timerMessageQueryFetch(query);
}

TimerMessage CommandsDatabase::timerMessageFetch(const QString &guid)
{
    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM TimerMessages WHERE guid=:guid");
    query.bindValue(":guid", guid);

    const QList<TimerMessage> &list = timerMessageQueryFetch(query);
    if(list.isEmpty())
        return TimerMessage();
    else
        return list.first();
}

QList<TimerMessage> CommandsDatabase::timerMessageQueryFetch(QSqlQuery &query)
{
    QList<TimerMessage> result;
    if(!query.exec())
    {
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
        return result;
    }

    while(query.next())
    {
        QSqlRecord record = query.record();

        const int peerType = cmdPeerToInputPeer((CommandsDatabase::CommandPeerType)record.value("peerType").toInt());
        InputPeer peer(static_cast<InputPeer::InputPeerType>(peerType));
        switch(peerType)
        {
        case InputPeer::typeInputPeerEmpty:
        case InputPeer::typeInputPeerChat:
            peer.setChatId(record.value("peerId").toLongLong());
            break;
        case InputPeer::typeInputPeerContact:
        case InputPeer::typeInputPeerForeign:
        case InputPeer::typeInputPeerSelf:
            peer.setUserId(record.value("peerId").toLongLong());
            peer.setAccessHash(record.value("peerAccessHash").toLongLong());
            break;
        }

        TimerMessage item;
        item.guid = record.value("guid").toString();
        item.peer = peer;
        item.message = record.value("message").toString();
        item.dateTime = record.value("time").toDateTime();

        result << item;
    }

    return result;
}

CommandsDatabase::CommandPeerType CommandsDatabase::inputPeerToCmdPeer(InputPeer::InputPeerType t)
{
    switch(static_cast<int>(t))
    {
    case InputPeer::typeInputPeerEmpty:
        return CmdPeerEmpty;
        break;
    case InputPeer::typeInputPeerSelf:
        return CmdPeerSelf;
        break;
    case InputPeer::typeInputPeerContact:
        return CmdPeerContact;
        break;
    case InputPeer::typeInputPeerForeign:
        return CmdPeerForeign;
        break;
    case InputPeer::typeInputPeerChat:
        return CmdPeerChat;
        break;
    }

    return CmdPeerEmpty;
}

InputPeer::InputPeerType CommandsDatabase::cmdPeerToInputPeer(CommandsDatabase::CommandPeerType t)
{
    switch(static_cast<int>(t))
    {
    case CmdPeerEmpty:
        return InputPeer::typeInputPeerEmpty;
        break;
    case CmdPeerSelf:
        return InputPeer::typeInputPeerSelf;
        break;
    case CmdPeerContact:
        return InputPeer::typeInputPeerContact;
        break;
    case CmdPeerForeign:
        return InputPeer::typeInputPeerForeign;
        break;
    case CmdPeerChat:
        return InputPeer::typeInputPeerChat;
        break;
    }

    return InputPeer::typeInputPeerEmpty;
}

CommandsDatabase::~CommandsDatabase()
{
    delete p;
}

