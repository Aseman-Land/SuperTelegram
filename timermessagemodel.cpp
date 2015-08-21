#include "timermessagemodel.h"
#include "commandsdatabase.h"
#include "telegramqml.h"

#include <telegram.h>
#include <database.h>

#include <QPointer>
#include <QUuid>
#include <QTimer>
#include <QDebug>

class TimerMessageModelPrivate
{
public:
    QList<TimerMessage> full_list;
    QList<TimerMessage> list;
    QHash<QString,TimerMessage> hash;

    QPointer<CommandsDatabase> db;
    QPointer<TelegramQml> telegram;

    QTimer *timer;

    QList<qint64> progresses;
};

TimerMessageModel::TimerMessageModel(QObject *parent) :
    QAbstractListModel(parent)
{
    p = new TimerMessageModelPrivate;
    p->timer = new QTimer(this);
    p->timer->setInterval(100);

    connect(p->timer, SIGNAL(timeout()), SLOT(changed_prv()));
}

CommandsDatabase *TimerMessageModel::database() const
{
    return p->db;
}

void TimerMessageModel::setDatabase(CommandsDatabase *db)
{
    if(p->db == db)
        return;

    p->db = db;
    refresh();

    emit databaseChanged();
}

TelegramQml *TimerMessageModel::telegram() const
{
    return p->telegram;
}

void TimerMessageModel::setTelegram(TelegramQml *tg)
{
    if(p->telegram == tg)
        return;
    if(p->telegram)
    {
        disconnect(p->telegram, SIGNAL(usersChanged()), this, SLOT(changed()));
        disconnect(p->telegram, SIGNAL(chatsChanged()), this, SLOT(changed()));
    }

    p->telegram = tg;
    if(p->telegram)
    {
        connect(p->telegram, SIGNAL(usersChanged()), this, SLOT(changed()));
        connect(p->telegram, SIGNAL(chatsChanged()), this, SLOT(changed()));

        connect(p->telegram->telegram(), SIGNAL(messagesGetDialogsAnswer(qint64,qint32,QList<Dialog>,QList<Message>,QList<Chat>,QList<User>)),
                SLOT(messagesGetDialogsAnswer(qint64,qint32,QList<Dialog>,QList<Message>,QList<Chat>,QList<User>)));
        connect(p->telegram->telegram(), SIGNAL(contactsGetContactsAnswer(qint64,bool,QList<Contact>,QList<User>)),
                SLOT(contactsGetContactsAnswer(qint64,bool,QList<Contact>,QList<User>)));

        p->telegram->database()->readFullDialogs();
        p->progresses << p->telegram->telegram()->contactsGetContacts();
        p->progresses << p->telegram->telegram()->messagesGetDialogs();
        emit initializingChanged();
    }

    refresh();
    emit telegramChanged();
}

TimerMessage TimerMessageModel::id(const QModelIndex &index) const
{
    return p->list.at(index.row());
}

int TimerMessageModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return count();
}

QVariant TimerMessageModel::data(const QModelIndex &index, int role) const
{
    QVariant result;
    const TimerMessage &item = TimerMessageModel::id(index);
    switch(role)
    {
    case GuidRole:
        result = item.guid;
        break;

    case MessageRole:
        result = item.message;
        break;

    case DateTimeRole:
        result = item.dateTime;
        break;

    case PeerIdRole:
        result = item.peer.chatId()? item.peer.chatId() : item.peer.userId();
        break;

    case PeerTypeRole:
        result = CommandsDatabase::inputPeerToCmdPeer(item.peer.classType());
        break;

    case PeerAccessHashRole:
        result = item.peer.accessHash();
        break;

    case PeerIsChat:
        result = (item.peer.classType() == InputPeer::typeInputPeerChat);
        break;
    }

    return result;
}

QHash<qint32, QByteArray> TimerMessageModel::roleNames() const
{
    static QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
    res->insert( GuidRole, "guid");
    res->insert( MessageRole, "message");
    res->insert( DateTimeRole, "dateTime");
    res->insert( PeerIdRole, "peerId");
    res->insert( PeerTypeRole, "peerType");
    res->insert( PeerAccessHashRole, "peerAccessHash");
    res->insert( PeerIsChat, "peerIsChat");
    return *res;
}

int TimerMessageModel::count() const
{
    return p->list.count();
}

bool TimerMessageModel::initializing() const
{
    return p->progresses.count();
}

void TimerMessageModel::refresh()
{
    QList<TimerMessage> list;
    if(p->db && p->telegram)
        list = p->db->timerMessageFetchAll();

    p->full_list = list;
    changed_prv();
}

QString TimerMessageModel::createItem(qint64 dId, const QDateTime &dt, const QString &message)
{
    const QString &guid = QUuid::createUuid().toString();
    if( !updateItem(guid, dId, dt, message) )
        return QString();

    return guid;
}

bool TimerMessageModel::updateItem(const QString &guid, qint64 dId, const QDateTime &dt, const QString &message)
{
    if(!p->telegram)
        return false;

    const InputPeer &peer = p->telegram->getInputPeer(dId);

    TimerMessage item = p->hash.value(guid);
    item.guid = guid;
    item.peer = peer;
    item.dateTime = dt;
    item.message = message;

    p->db->timerMessageInsert(item);
    p->full_list.prepend(item);

    changed();
    return true;
}

bool TimerMessageModel::deleteItem(const QString &guid)
{
    if(!p->telegram)
        return false;

    p->db->timerMessageRemove(guid);
    for(int i=0; i<p->full_list.length(); i++)
        if(p->full_list.at(i).guid == guid)
        {
            p->full_list.removeAt(i);
            i--;
        }

    changed();
    return true;
}

void TimerMessageModel::changed()
{
    p->timer->stop();
    p->timer->start();
}

void TimerMessageModel::changed_prv()
{
    p->timer->stop();
    if(!p->telegram)
        return;

    QList<TimerMessage> list;
    QHash<QString,TimerMessage> newHash;
    foreach(const TimerMessage &item, p->full_list)
    {
        if(p->telegram->user(item.peer.userId()) == p->telegram->nullUser() &&
           p->telegram->chat(item.peer.chatId()) == p->telegram->nullChat())
            continue;

        list << item;
        p->hash[item.guid] = item;
        newHash[item.guid] = item;
    }

    for( int i=0 ; i<p->list.count() ; i++ )
    {
        const TimerMessage &item = p->list.at(i);
        if( list.contains(item) )
            continue;

        beginRemoveRows(QModelIndex(), i, i);
        p->list.removeAt(i);
        i--;
        endRemoveRows();
    }


    QList<TimerMessage> temp_msgs = list;
    for( int i=0 ; i<temp_msgs.count() ; i++ )
    {
        const TimerMessage &item = temp_msgs.at(i);
        if( p->list.contains(item) )
            continue;

        temp_msgs.removeAt(i);
        i--;
    }
    while( p->list != temp_msgs )
        for( int i=0 ; i<p->list.count() ; i++ )
        {
            const TimerMessage &item = p->list.at(i);
            int nw = temp_msgs.indexOf(item);
            if( i == nw )
                continue;

            beginMoveRows( QModelIndex(), i, i, QModelIndex(), nw>i?nw+1:nw );
            p->list.move( i, nw );
            endMoveRows();
        }


    for( int i=0 ; i<list.count() ; i++ )
    {
        const TimerMessage &item = list.at(i);
        if( p->list.contains(item) )
            continue;

        beginInsertRows(QModelIndex(), i, i );
        p->list.insert( i, item );
        endInsertRows();
    }

    p->hash.clear();
    p->hash = newHash;

    emit countChanged();
}

void TimerMessageModel::messagesGetDialogsAnswer(qint64 id, qint32 sliceCount, const QList<Dialog> &dialogs, const QList<Message> &messages, const QList<Chat> &chats, const QList<User> &users)
{
    Q_UNUSED(sliceCount)
    Q_UNUSED(dialogs)
    Q_UNUSED(messages)
    Q_UNUSED(users)
    Q_UNUSED(chats)
    int count = p->progresses.removeAll(id);
    if(count)
        emit initializingChanged();
}

void TimerMessageModel::contactsGetContactsAnswer(qint64 id, bool modified, const QList<Contact> &contacts, const QList<User> &users)
{
    Q_UNUSED(modified)
    Q_UNUSED(contacts)
    Q_UNUSED(users)
    int count = p->progresses.removeAll(id);
    if(count)
        emit initializingChanged();
}

TimerMessageModel::~TimerMessageModel()
{
    delete p;
}

