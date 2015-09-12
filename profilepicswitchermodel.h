#ifndef PROFILEPICSWITCHERMODEL_H
#define PROFILEPICSWITCHERMODEL_H

#include "asemantools/asemanabstractlistmodel.h"

class ProfilePicSwitcherModelPrivate;
class ProfilePicSwitcherModel : public AsemanAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(DataRoles)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString folder READ folder WRITE setFolder NOTIFY folderChanged)

public:
    enum DataRoles {
        DataImagePathRole = Qt::UserRole,
        DataImageNameRole
    };

    ProfilePicSwitcherModel(QObject *parent = 0);
    ~ProfilePicSwitcherModel();

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

private:
    void changed(const QStringList &list);

private:
    ProfilePicSwitcherModelPrivate *p;
};

#endif // PROFILEPICSWITCHERMODEL_H
