#include "automessagemodel.h"

#include <QPointer>
#include <QUuid>

class AutoMessageModelPrivate
{
public:
    QList<AutoMessage> list;
    QHash<QString,AutoMessage> hash;

    QPointer<CommandsDatabase> db;
    QString active;

    AutoMessage defaultMessage;
};

AutoMessageModel::AutoMessageModel(QObject *parent) :
    QAbstractListModel(parent)
{
    p = new AutoMessageModelPrivate;
    p->defaultMessage.guid = "";
    p->defaultMessage.message = tr("Disable");
}

CommandsDatabase *AutoMessageModel::database() const
{
    return p->db;
}

void AutoMessageModel::setDatabase(CommandsDatabase *db)
{
    if(p->db == db)
        return;

    p->db = db;
    refresh();

    emit databaseChanged();
}

AutoMessage AutoMessageModel::id(const QModelIndex &index) const
{
    return p->list.at(index.row());
}

int AutoMessageModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return count();
}

QVariant AutoMessageModel::data(const QModelIndex &index, int role) const
{
    QVariant result;
    const AutoMessage &item = id(index);
    switch(role)
    {
    case GuidRole:
        result = item.guid;
        break;

    case MessageRole:
        result = item.message;
        break;
    }

    return result;
}

QHash<qint32, QByteArray> AutoMessageModel::roleNames() const
{
    static QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
    res->insert( GuidRole, "guid");
    res->insert( MessageRole, "message");
    return *res;
}

int AutoMessageModel::count() const
{
    return p->list.count();
}

void AutoMessageModel::setActive(const QString &active)
{
    if(p->active == active)
        return;

    p->active = active;
    if(p->db)
        p->db->autoMessageSetActive(p->active);

    emit activeChanged();
}

QString AutoMessageModel::active() const
{
    return p->active;
}

void AutoMessageModel::refresh()
{
    QList<AutoMessage> list;
    list << p->defaultMessage;

    QString active;
    if(p->db)
    {
        list << p->db->autoMessageFetchAll();
        active = p->db->autoMessageActiveMessage().guid;
    }

    changed(list);
    if(p->active != active)
    {
        p->active = active;
        emit activeChanged();
    }
}

QString AutoMessageModel::addItem(const QString &message)
{
    const QString &guid = QUuid::createUuid().toString();
    if( !updateItem(guid, message) )
        return QString();

    return guid;
}

bool AutoMessageModel::updateItem(const QString &guid, const QString &message)
{
    AutoMessage item = p->hash.value(guid);
    item.guid = guid;
    item.message = message;

    p->db->autoMessageInsert(item);

    QList<AutoMessage> list = p->list;
    bool added = false;
    for(int i=0; i<list.length(); i++)
        if(list.at(i).guid == guid)
        {
            list[i] = item;
            added = true;
            break;
        }
    if(!added)
        list.prepend(item);

    changed(list);
    return true;
}

bool AutoMessageModel::deleteItem(const QString &guid)
{
    p->db->autoMessageRemove(guid);

    QList<AutoMessage> list = p->list;
    for(int i=0; i<list.length(); i++)
        if(list.at(i).guid == guid)
        {
            list.removeAt(i);
            i--;
        }

    changed(list);
    return true;
}

void AutoMessageModel::changed(const QList<AutoMessage> &list)
{
    QHash<QString,AutoMessage> newHash;
    foreach(const AutoMessage &item, list)
    {
        p->hash[item.guid] = item;
        newHash[item.guid] = item;
    }

    for( int i=0 ; i<p->list.count() ; i++ )
    {
        const AutoMessage &item = p->list.at(i);
        if( list.contains(item) )
            continue;

        beginRemoveRows(QModelIndex(), i, i);
        p->list.removeAt(i);
        i--;
        endRemoveRows();
    }


    QList<AutoMessage> temp_msgs = list;
    for( int i=0 ; i<temp_msgs.count() ; i++ )
    {
        const AutoMessage &item = temp_msgs.at(i);
        if( p->list.contains(item) )
            continue;

        temp_msgs.removeAt(i);
        i--;
    }
    while( p->list != temp_msgs )
        for( int i=0 ; i<p->list.count() ; i++ )
        {
            const AutoMessage &item = p->list.at(i);
            int nw = temp_msgs.indexOf(item);
            if( i == nw )
                continue;

            beginMoveRows( QModelIndex(), i, i, QModelIndex(), nw>i?nw+1:nw );
            p->list.move( i, nw );
            endMoveRows();
        }


    for( int i=0 ; i<list.count() ; i++ )
    {
        const AutoMessage &item = list.at(i);
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

AutoMessageModel::~AutoMessageModel()
{
    delete p;
}

