#ifndef PROFILEPICSWITCHERMODEL_H
#define PROFILEPICSWITCHERMODEL_H

#include "asemantools/asemanabstractlistmodel.h"
#include "commandsdatabase.h"

class ProfilePicSwitcherModelPrivate;
class ProfilePicSwitcherModel : public AsemanAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(DataRoles)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(CommandsDatabase* database READ database WRITE setDatabase NOTIFY databaseChanged)
    Q_PROPERTY(QString folder READ folder WRITE setFolder NOTIFY folderChanged)
    Q_PROPERTY(int timer READ timer WRITE setTimer NOTIFY timerChanged)

public:
    enum DataRoles {
        DataImagePathRole = Qt::UserRole,
        DataImageNameRole
    };

    ProfilePicSwitcherModel(QObject *parent = 0);
    ~ProfilePicSwitcherModel();

    CommandsDatabase *database() const;
    void setDatabase(CommandsDatabase *db);

    void setTimer(int ms);
    int timer() const;

    void setFolder(const QString &url);
    QString folder() const;

    QString id( const QModelIndex &index ) const;
    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QHash<qint32,QByteArray> roleNames() const;
    int count() const;

public slots:
    void refresh();
    void add(const QString &file);
    void remove(const QString &file);

signals:
    void folderChanged();
    void countChanged();
    void databaseChanged();
    void timerChanged();

private:
    void changed(const QStringList &list);

private:
    ProfilePicSwitcherModelPrivate *p;
};

#endif // PROFILEPICSWITCHERMODEL_H
