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
    QHash<QString,QVariant> values;
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

    initBuffer();
    updateDb();
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
    query.bindValue(":time", fixTime(item.dateTime));
    if(!query.exec())
    {
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
        return QString();
    }

    emit timerMessageChanged();
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
    query.bindValue(":time", fixTime(dt));
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

QString CommandsDatabase::autoMessageInsert(const AutoMessage &amsg)
{
    AutoMessage item = amsg;
    if(item.guid.isEmpty())
        item.guid = QUuid::createUuid().toString();

    QSqlQuery query(p->db);
    query.prepare("INSERT OR REPLACE INTO AutoMessages (guid,message,active) "
                  "VALUES (:guid, :message, :active)");
    query.bindValue(":guid", item.guid);
    query.bindValue(":message", item.message);
    query.bindValue(":active", false);
    if(!query.exec())
    {
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
        return QString();
    }

    emit autoMessageChanged();
    return item.guid;
}

bool CommandsDatabase::autoMessageRemove(const QString &guid)
{
    if(guid.isEmpty())
        return false;

    QSqlQuery query(p->db);
    query.prepare("DELETE FROM AutoMessages WHERE guid=:guid");
    query.bindValue(":guid", guid);
    if(!query.exec())
    {
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
        return false;
    }

    return true;
}

QList<AutoMessage> CommandsDatabase::autoMessageFetchAll()
{
    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM AutoMessages");
    return autoMessageQueryFetch(query);
}

bool CommandsDatabase::autoMessageSetActive(const QString &guid)
{
    if(!autoMessageClearActive())
        return false;
    if(guid.isEmpty())
        return true;

    QSqlQuery query(p->db);
    query.prepare("UPDATE AutoMessages SET active=1 WHERE guid=:guid");
    query.bindValue(":guid", guid);
    if(!query.exec())
    {
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
        return false;
    }

    emit autoMessageChanged();
    return true;
}

bool CommandsDatabase::autoMessageClearActive()
{
    QSqlQuery query(p->db);
    query.prepare("UPDATE AutoMessages SET active=0");
    if(!query.exec())
    {
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
        return false;
    }

    return true;
}

AutoMessage CommandsDatabase::autoMessageActiveMessage()
{
    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM AutoMessages WHERE active=1");
    const QList<AutoMessage> &list = autoMessageQueryFetch(query);
    if(list.isEmpty())
        return AutoMessage();
    else
        return list.first();
}

bool CommandsDatabase::sensMessageInsert(const QString &key, const QString &value, qint64 userId)
{
    if(key.isEmpty())
        return false;

    QSqlQuery query(p->db);
    query.prepare("INSERT OR REPLACE INTO SensitiveMessages (key,value,user) "
                  "VALUES (:key, :value, :user)");
    query.bindValue(":key", key);
    query.bindValue(":value", value);
    query.bindValue(":user", userId);
    if(!query.exec())
    {
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
        return false;
    }

    emit sensMessageChanged();
    return true;
}

bool CommandsDatabase::sensMessageRemove(const QString &key)
{
    if(key.isEmpty())
        return false;

    QSqlQuery query(p->db);
    query.prepare("DELETE FROM SensitiveMessages WHERE key=:key");
    query.bindValue(":key", key);
    if(!query.exec())
    {
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
        return false;
    }

    return true;
}

QList<SensMessage> CommandsDatabase::sensMessageFetchAll()
{
    QList<SensMessage> result;
    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM SensitiveMessages");
    if(!query.exec())
    {
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
        return result;
    }

    while(query.next())
    {
        QSqlRecord record = query.record();

        SensMessage item;
        item.key = record.value("key").toString();
        item.value = record.value("value").toString();
        item.userId = record.value("user").toLongLong();

        result << item;
    }

    return result;
}

bool CommandsDatabase::profilePictureTimerSet(qint64 ms)
{
    bool res = setValue("profilePictureTimer", ms);
    emit profilePictureTimerChanged();
    return res;
}

qint64 CommandsDatabase::profilePictureTimer() const
{
    return value("profilePictureTimer", -1).toLongLong();
}

bool CommandsDatabase::saveAvatarsAdd(qint64 peerId, const QString &path)
{

}

qint64 CommandsDatabase::saveAvatarsRemovePeer(qint64 peer)
{

}

QMap<qint64, QString> CommandsDatabase::saveAvatarsFetchAll()
{

}

bool CommandsDatabase::setValue(const QString &key, const QVariant &value)
{
    if(CommandsDatabase::value(key) == value)
        return true;

    QSqlQuery query(p->db);
    query.prepare("INSERT OR REPLACE INTO General (key,value) "
                  "VALUES (:key, :value)");
    query.bindValue(":key", key);
    query.bindValue(":value", value);
    if(!query.exec())
    {
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
        return false;
    }

    p->values[key] = value;
    return true;
}

QVariant CommandsDatabase::value(const QString &key, const QVariant &defaultValue) const
{
    return p->values.value(key, defaultValue);
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

QList<AutoMessage> CommandsDatabase::autoMessageQueryFetch(QSqlQuery &query)
{
    QList<AutoMessage> result;
    if(!query.exec())
    {
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
        return result;
    }

    while(query.next())
    {
        QSqlRecord record = query.record();

        AutoMessage item;
        item.guid = record.value("guid").toString();
        item.message = record.value("message").toString();

        result << item;
    }

    return result;
}

void CommandsDatabase::initBuffer()
{
    p->values.clear();

    QSqlQuery query(p->db);
    query.prepare("SELECT * FROM General");
    if(!query.exec())
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
    else
    while(query.next())
    {
        QSqlRecord record = query.record();
        p->values[record.value("key").toString()] = record.value("value");
    }
}

void CommandsDatabase::updateDb()
{
    const int version = value("Database/version", "0").toString().toInt();
    int dyn_version = version;
    if(dyn_version == 0)
    {
        QSqlQuery query(p->db);
        query.prepare("CREATE TABLE FilesHash (fileHash STRING PRIMARY KEY, fileId STRING NOT NULL, accessHash STRING NOT NULL);");
        query.exec();
        dyn_version = 1;
        qDebug() << QString("Database updated to the %1 version.").arg(dyn_version);
    }
    if(dyn_version == 1)
    {
        QStringList queries;
        queries << "ALTER TABLE SensitiveMessages RENAME TO sqlitestudio_temp_table;"
                << "CREATE TABLE SensitiveMessages (\"key\" TEXT PRIMARY KEY, value TEXT NOT NULL, user BIGINT);"
                << "INSERT INTO SensitiveMessages (\"key\", value) SELECT \"key\", value FROM sqlitestudio_temp_table;"
                << "DROP TABLE sqlitestudio_temp_table;";

        foreach(const QString &q, queries)
        {
            QSqlQuery query(p->db);
            query.prepare(q);
            query.exec();
        }
        dyn_version = 2;
        qDebug() << QString("Database updated to the %1 version.").arg(dyn_version);
    }

    if(dyn_version != version)
        setValue("Database/version", QString::number(dyn_version));
}

QDateTime CommandsDatabase::fixTime(const QDateTime &dt)
{

    return QDateTime(dt.date(), QTime(dt.time().hour(), dt.time().minute(), 0));
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

bool CommandsDatabase::addAccessHash(const QString &fileHash, const FileAccessHash &file)
{
    QSqlQuery query(p->db);
    query.prepare("INSERT OR REPLACE INTO FilesHash (fileHash,fileId,accessHash) "
                  "VALUES (:hash, :fid, :acsHash)");
    query.bindValue(":hash", fileHash);
    query.bindValue(":fid", QString::number(file.fileId));
    query.bindValue(":acsHash", QString::number(file.accessHash));
    if(!query.exec())
    {
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
        return false;
    }

    return true;
}

FileAccessHash CommandsDatabase::getAccessHash(const QString &fileHash)
{
    FileAccessHash result;

    QSqlQuery query(p->db);
    query.prepare("SELECT fileHash,fileId,accessHash FROM FilesHash WHERE fileHash=:hash");
    query.bindValue(":hash", fileHash);
    if(!query.exec())
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
    else
    if(query.next())
    {
        QSqlRecord record = query.record();
        result.fileId = record.value("fileId").toString().toULongLong();
        result.accessHash = record.value("accessHash").toString().toULongLong();
    }

    return result;
}

bool CommandsDatabase::removeAccessHash(const QString &fileHash)
{
    QSqlQuery query(p->db);
    query.prepare("DELETE FROM FilesHash WHERE fileHash=:hash");
    query.bindValue(":hash", fileHash);
    if(!query.exec())
    {
        qDebug() << __PRETTY_FUNCTION__ << query.lastError().text();
        return false;
    }

    return true;
}

CommandsDatabase::~CommandsDatabase()
{
    delete p;
}

