#ifndef TIMERMESSAGEMODEL_H
#define TIMERMESSAGEMODEL_H

#include "asemantools/asemanabstractlistmodel.h"

class Dialog;
class User;
class Chat;
class Message;
class Contact;
class TelegramQml;
class TimerMessage;
class CommandsDatabase;
class TimerMessageModelPrivate;
class TimerMessageModel : public AsemanAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(DataRoles)

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool initializing READ initializing NOTIFY initializingChanged)
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
    bool initializing() const;

public slots:
    void refresh();
    QString createItem(qint64 dId, const QDateTime &dt, const QString &message);
    bool updateItem(const QString &guid, qint64 dId, const QDateTime &dt, const QString &message);
    bool deleteItem(const QString &guid);

signals:
    void countChanged();
    void databaseChanged();
    void telegramChanged();
    void initializingChanged();

private slots:
    void changed();
    void changed_prv();

    void messagesGetDialogsAnswer(qint64 id, qint32 sliceCount, const QList<Dialog> &dialogs, const QList<Message> &messages, const QList<Chat> &chats, const QList<User> &users);
    void contactsGetContactsAnswer(qint64 id, bool modified, const QList<Contact> &contacts, const QList<User> &users);

private:
    TimerMessageModelPrivate *p;
};

#endif // TIMERMESSAGEMODEL_H
