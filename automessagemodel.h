#ifndef AUTOMESSAGEMODEL_H
#define AUTOMESSAGEMODEL_H

#include <QAbstractListModel>
#include "commandsdatabase.h"

class AutoMessageModelPrivate;
class AutoMessageModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(CommandsDatabase* database READ database WRITE setDatabase NOTIFY databaseChanged)
    Q_PROPERTY(QString active READ active WRITE setActive NOTIFY activeChanged)

public:
    enum DataRoles {
        GuidRole = Qt::UserRole,
        MessageRole
    };

    AutoMessageModel(QObject *parent = 0);
    ~AutoMessageModel();

    CommandsDatabase *database() const;
    void setDatabase(CommandsDatabase *db);

    AutoMessage id( const QModelIndex &index ) const;
    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QHash<qint32,QByteArray> roleNames() const;
    int count() const;

    void setActive(const QString &active);
    QString active() const;

public slots:
    void refresh();
    QString addItem(const QString &message);
    bool updateItem(const QString &guid, const QString &message);
    bool deleteItem(const QString &guid);

signals:
    void countChanged();
    void databaseChanged();
    void activeChanged();

private:
    void changed(const QList<AutoMessage> &list);

private:
    AutoMessageModelPrivate *p;
};

#endif // AUTOMESSAGEMODEL_H
