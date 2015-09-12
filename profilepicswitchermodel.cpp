#include "profilepicswitchermodel.h"

#include <QDir>
#include <QFileInfo>
#include <QFile>

class ProfilePicSwitcherModelPrivate
{
public:
    QStringList list;
    QString folder;
};

ProfilePicSwitcherModel::ProfilePicSwitcherModel(QObject *parent) :
    AsemanAbstractListModel(parent)
{
    p = new ProfilePicSwitcherModelPrivate;
}

void ProfilePicSwitcherModel::setFolder(const QString &url)
{
    if(p->folder == url)
        return;

    p->folder = url;
    QDir().mkpath(p->folder);

    refresh();
    emit folderChanged();
}

QString ProfilePicSwitcherModel::folder() const
{
    return p->folder;
}

QString ProfilePicSwitcherModel::id(const QModelIndex &index) const
{
    return p->list.at(index.row());
}

int ProfilePicSwitcherModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return count();
}

QVariant ProfilePicSwitcherModel::data(const QModelIndex &index, int role) const
{
    const QString &path = id(index);

    QVariant res;
    switch(role)
    {
    case DataImagePathRole:
        res = path;
        break;

    case DataImageNameRole:
        res = path.mid(path.lastIndexOf("/")+1);
        break;
    }

    return res;
}

QHash<qint32, QByteArray> ProfilePicSwitcherModel::roleNames() const
{
    static QHash<qint32, QByteArray> *res = 0;
    if( res )
        return *res;

    res = new QHash<qint32, QByteArray>();
    res->insert( DataImagePathRole, "path");
    res->insert( DataImageNameRole, "name");
    return *res;
}

int ProfilePicSwitcherModel::count() const
{
    return p->list.count();
}

void ProfilePicSwitcherModel::refresh()
{
    QStringList list;
    if(p->folder.count())
    {
        const QStringList &files = QDir(p->folder).entryList(QDir::Files, QDir::Time);
        foreach(const QString &f, files)
            list << QFileInfo(p->folder + "/" + f).filePath();
    }

    changed(list);
}

void ProfilePicSwitcherModel::add(const QString &src)
{
    if(p->folder.isEmpty())
        return;

    const QString fileName = src.mid(src.lastIndexOf("/")+1);
    const QString file = QFileInfo(p->folder + "/" + fileName).filePath();

    if( !QFile::copy(src, file) )
        return;

    QStringList list = p->list;
    list << file;

    changed(list);
}

void ProfilePicSwitcherModel::remove(const QString &f)
{
    if(p->folder.isEmpty())
        return;

    const QString file = QFileInfo(f).filePath();
    QFile::remove(file);

    QStringList list = p->list;
    list.removeAll(file);

    changed(list);
}

void ProfilePicSwitcherModel::changed(const QStringList &list)
{
    for( int i=0 ; i<p->list.count() ; i++ )
    {
        const QString &key = p->list.at(i);
        if( list.contains(key) )
            continue;

        beginRemoveRows(QModelIndex(), i, i);
        p->list.removeAt(i);
        i--;
        endRemoveRows();
    }


    QStringList temp_list = list;
    for( int i=0 ; i<temp_list.count() ; i++ )
    {
        const QString &key = temp_list.at(i);
        if( p->list.contains(key) )
            continue;

        temp_list.removeAt(i);
        i--;
    }
    while( p->list != temp_list )
        for( int i=0 ; i<p->list.count() ; i++ )
        {
            const QString &key = p->list.at(i);
            int nw = temp_list.indexOf(key);
            if( i == nw )
                continue;

            beginMoveRows( QModelIndex(), i, i, QModelIndex(), nw>i?nw+1:nw );
            p->list.move( i, nw );
            endMoveRows();
        }


    for( int i=0 ; i<list.count() ; i++ )
    {
        const QString &key = list.at(i);
        if( p->list.contains(key) )
            continue;

        beginInsertRows(QModelIndex(), i, i );
        p->list.insert( i, key );
        endInsertRows();
    }

    emit countChanged();
}

ProfilePicSwitcherModel::~ProfilePicSwitcherModel()
{
    delete p;
}

