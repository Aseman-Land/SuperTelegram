#ifndef COMMANDSDATABASE_H
#define COMMANDSDATABASE_H

#include <QObject>
#include <QDateTime>

#include <telegram/types/types.h>

class TimerMessage
{
public:
    QString guid;
    QDateTime dateTime;
    InputPeer peer;
    QString message;

    bool operator ==(const TimerMessage &b) {
        return guid == b.guid &&
               dateTime == b.dateTime &&
               peer == b.peer &&
               message == b.message;
    }
};

class AutoMessage
{
public:
    QString guid;
    QString message;

    bool operator ==(const AutoMessage &b) {
        return guid == b.guid &&
               message == b.message;
    }
};

class SensMessage
{
public:
    QString key;
    QString value;

    bool operator ==(const SensMessage &b) {
        return key == b.key &&
               value == b.value;
    }
};

class QSqlQuery;
class CommandsDatabasePrivate;
class CommandsDatabase : public QObject
{
    Q_OBJECT
    Q_ENUMS(CommandPeerType)

public:
    enum CommandPeerType {
        CmdPeerEmpty,
        CmdPeerSelf,
        CmdPeerContact,
        CmdPeerForeign,
        CmdPeerChat
    };

    CommandsDatabase(QObject *parent = 0);
    ~CommandsDatabase();

    QString timerMessageInsert(const TimerMessage &tmsg);
    bool timerMessageRemove(const QString &guid);
    QList<TimerMessage> timerMessageFetchAll();
    QList<TimerMessage> timerMessageFetch(const QDateTime &dt);
    QList<TimerMessage> timerMessageFetchNext();
    QList<TimerMessage> timerMessageFetchExpired();
    TimerMessage timerMessageFetch(const QString &guid);

    QString autoMessageInsert(const AutoMessage &amsg);
    bool autoMessageRemove(const QString &guid);
    QList<AutoMessage> autoMessageFetchAll();
    bool autoMessageSetActive(const QString &guid);
    bool autoMessageClearActive();
    AutoMessage autoMessageActiveMessage();

    bool sensMessageInsert(const QString &key, const QString &value);
    bool sensMessageRemove(const QString &key);
    QList<SensMessage> sensMessageFetchAll();

    static CommandPeerType inputPeerToCmdPeer(InputPeer::InputPeerType t);
    static InputPeer::InputPeerType cmdPeerToInputPeer(CommandPeerType t);

private:
    QList<TimerMessage> timerMessageQueryFetch(QSqlQuery &query);
    QList<AutoMessage> autoMessageQueryFetch(QSqlQuery &query);

private:
    CommandsDatabasePrivate *p;
};

#endif // COMMANDSDATABASE_H
