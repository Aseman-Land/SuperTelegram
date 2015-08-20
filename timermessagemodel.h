#ifndef TIMERMESSAGEMODEL_H
#define TIMERMESSAGEMODEL_H

#include <QAbstractListModel>

class TelegramQml;
class TimerMessage;
class CommandsDatabase;
class TimerMessageModelPrivate;
class TimerMessageModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(CommandsDatabase* database READ database WRITE setDatabase NOTIFY databaseChanged)
    Q_PROPERTY(TelegramQml* telegram READ telegram WRITE setTelegram NOTIFY telegramChanged)

public:
    enum DataRoles {
        GuidRole = Qt::UserRole,
        MessageRole,
        DateTimeRole,
        PeerIdRole,
        PeerTypeRole,
        PeerAccessHashRole,
        PeerIsChat
    };

    TimerMessageModel(QObject *parent = 0);
    ~TimerMessageModel();

    CommandsDatabase *database() const;
    void setDatabase(CommandsDatabase *db);

    TelegramQml *telegram() const;
    void setTelegram(TelegramQml *tg);

    TimerMessage id( const QModelIndex &index ) const;
    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QHash<qint32,QByteArray> roleNames() const;

    int count() const;

public slots:
    void refresh();
    QString createItem(qint64 dId, const QDateTime &dt, const QString &message);
    bool updateItem(const QString &guid, qint64 dId, const QDateTime &dt, const QString &message);

signals:
    void countChanged();
    void databaseChanged();
    void telegramChanged();

private slots:
    void changed();
    void changed_prv();

private:
    TimerMessageModelPrivate *p;
};

#endif // TIMERMESSAGEMODEL_H
