#ifndef SENSMESSAGEMODEL_H
#define SENSMESSAGEMODEL_H

#include <QAbstractListModel>

#include "commandsdatabase.h"

class SensMessageModelPrivate;
class SensMessageModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(CommandsDatabase* database READ database WRITE setDatabase NOTIFY databaseChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum DataRoles {
        KeyRole = Qt::UserRole,
        ValueRole
    };

    SensMessageModel(QObject *parent = 0);
    ~SensMessageModel();

    void setDatabase(CommandsDatabase *db);
    CommandsDatabase *database() const;

    SensMessage id( const QModelIndex &index ) const;
    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QHash<qint32,QByteArray> roleNames() const;

    int count() const;

public slots:
    void refresh();
    bool addItem(const QString &key, const QString &value);
    bool removeItem(const QString &key);

signals:
    void databaseChanged();
    void countChanged();

private:
    void changed(const QList<SensMessage> &list);

private:
    SensMessageModelPrivate *p;
};

#endif // SENSMESSAGEMODEL_H
