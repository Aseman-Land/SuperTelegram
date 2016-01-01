#include "profilepicswitchermodel.h"
#include "asemantools/asemandevices.h"

#include <QDir>
#include <QFileInfo>
#include <QFile>
#include <QPointer>
#include <QUrl>
#include <QDebug>

class ProfilePicSwitcherModelPrivate
{
public:
    QStringList list;
    QString folder;
    QPointer<CommandsDatabase> db;
    int timer;
};

ProfilePicSwitcherModel::ProfilePicSwitcherModel(QObject *parent) :
    AsemanAbstractListModel(parent)
{
    p = new ProfilePicSwitcherModelPrivate;
    p->timer = 0;
}

CommandsDatabase *ProfilePicSwitcherModel::database() const
{
    return p->db;
}

void ProfilePicSwitcherModel::setDatabase(CommandsDatabase *db)
{
    if(p->db == db)
        return;

    p->db = db;
    p->timer = (p->db? p->db->profilePictureTimer(): -1);

    emit databaseChanged();
    emit timerChanged();
}

void ProfilePicSwitcherModel::setTimer(int ms)
{
    if(p->timer == ms)
        return;

    p->timer = ms;
    if(p->db)
    {
        p->db->profilePictureTimerSet(p->timer);
        p->db->profilePictureTimerSourceSet(QDateTime::currentDateTime().addSecs(-61));
    }

    emit timerChanged();
}

int ProfilePicSwitcherModel::timer() const
{
    return p->timer;
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
        res = QUrl::fromLocalFile(path);
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

void ProfilePicSwitcherModel::add(const QString &_src)
{
    if(p->folder.isEmpty())
        return;

    QString src = _src;
    if(src.left(AsemanDevices::localFilesPrePath().size()) == AsemanDevices::localFilesPrePath())
        src = src.mid(AsemanDevices::localFilesPrePath().size());

    const QString fileName = src.mid(src.lastIndexOf("/")+1);
    const QString file = QFileInfo(p->folder + "/" + fileName).filePath();

    if( !QFile::copy(src, file) )
        return;

    QStringList list = p->list;
    list << file;

    changed(list);
}

void ProfilePicSwitcherModel::remove(const QString &_f)
{
    if(p->folder.isEmpty())
        return;

    QString f = _f;
    if(f.left(AsemanDevices::localFilesPrePath().size()) == AsemanDevices::localFilesPrePath())
        f = f.mid(AsemanDevices::localFilesPrePath().size());

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

