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

    static CommandPeerType inputPeerToCmdPeer(InputPeer::InputPeerType t);
    static InputPeer::InputPeerType cmdPeerToInputPeer(CommandPeerType t);

private:
    QList<TimerMessage> timerMessageQueryFetch(QSqlQuery &query);

private:
    CommandsDatabasePrivate *p;
};

#endif // COMMANDSDATABASE_H
