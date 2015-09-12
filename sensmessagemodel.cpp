#include "sensmessagemodel.h"

#include <QPointer>
#include <QHash>

class SensMessageModelPrivate
{
public:
    QPointer<CommandsDatabase> db;

    QHash<QString,SensMessage> hash;
    QList<SensMessage> list;
};

SensMessageModel::SensMessageModel(QObject *parent) :
    AsemanAbstractListModel(parent)
{
    p = new SensMessageModelPrivate;
}

void SensMessageModel::setDatabase(CommandsDatabase *db)
{
    if(p->db == db)
        return;

    p->db = db;
    refresh();
    emit databaseChanged();
}

CommandsDatabase *SensMessageModel::database() const
{
    return p->db;
}

SensMessage SensMessageModel::id(const QModelIndex &index) const
{
    return p->list.at(index.row());
}

int SensMessageModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return count();
}

QVariant SensMessageModel::data(const QModelIndex &index, int role) const
{
    QVariant result;
    const SensMessage &item = id(index);
    switch(role)
    {
    case KeyRole:
        result = item.key;
        break;

    case ValueRole:
        result = item.value;
        break;
    }

    return result;
}

QHash<qint32, QByteArray> SensMessageModel::roleNames() const
{
    static QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
    res->insert( KeyRole, "key");
    res->insert( ValueRole, "value");
    return *res;
}

int SensMessageModel::count() const
{
    return p->list.count();
}

void SensMessageModel::refresh()
{
    QList<SensMessage> list;
    if(p->db)
    {
        list = p->db->sensMessageFetchAll();
    }

    changed(list);
}

bool SensMessageModel::addItem(const QString &key, const QString &value)
{
    SensMessage item;
    item.key = key;
    item.value = value;

    p->db->sensMessageInsert(key, value);

    QList<SensMessage> list = p->list;
    bool added = false;
    for(int i=0; i<list.length(); i++)
        if(list.at(i).key == key)
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

bool SensMessageModel::removeItem(const QString &key)
{
    p->db->sensMessageRemove(key);

    QList<SensMessage> list = p->list;
    for(int i=0; i<list.length(); i++)
        if(list.at(i).key == key)
        {
            list.removeAt(i);
            i--;
        }

    changed(list);
    return true;
}

void SensMessageModel::changed(const QList<SensMessage> &list)
{
    QHash<QString,SensMessage> newHash;
    foreach(const SensMessage &item, list)
    {
        p->hash[item.key] = item;
        newHash[item.key] = item;
    }

    for( int i=0 ; i<p->list.count() ; i++ )
    {
        const SensMessage &item = p->list.at(i);
        if( list.contains(item) )
            continue;

        beginRemoveRows(QModelIndex(), i, i);
        p->list.removeAt(i);
        i--;
        endRemoveRows();
    }


    QList<SensMessage> temp_msgs = list;
    for( int i=0 ; i<temp_msgs.count() ; i++ )
    {
        const SensMessage &item = temp_msgs.at(i);
        if( p->list.contains(item) )
            continue;

        temp_msgs.removeAt(i);
        i--;
    }
    while( p->list != temp_msgs )
        for( int i=0 ; i<p->list.count() ; i++ )
        {
            const SensMessage &item = p->list.at(i);
            int nw = temp_msgs.indexOf(item);
            if( i == nw )
                continue;

            beginMoveRows( QModelIndex(), i, i, QModelIndex(), nw>i?nw+1:nw );
            p->list.move( i, nw );
            endMoveRows();
        }


    for( int i=0 ; i<list.count() ; i++ )
    {
        const SensMessage &item = list.at(i);
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

SensMessageModel::~SensMessageModel()
{
    delete p;
}

