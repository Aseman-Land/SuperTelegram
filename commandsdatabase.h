#ifndef COMMANDSDATABASE_H
#define COMMANDSDATABASE_H

#include <QObject>
#include <QDateTime>
#include <QVariant>

#include <telegram/types/types.h>

#define PPIC_TIMER_SRC_KEY "ppictimer/source"

class FileAccessHash
{
public:
    FileAccessHash(): accessHash(0), fileId(0) {}

    qint64 accessHash;
    qint64 fileId;

    bool operator ==(const FileAccessHash &b) {
        return accessHash == b.accessHash &&
               fileId == b.fileId;
    }
};
Q_DECLARE_METATYPE(FileAccessHash)

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
Q_DECLARE_METATYPE(TimerMessage)

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
Q_DECLARE_METATYPE(AutoMessage)

class SensMessage
{
public:
    SensMessage() : userId(0) {}

    QString key;
    QString value;
    qint64 userId;

    bool operator ==(const SensMessage &b) {
        return key == b.key &&
               value == b.value &&
               userId == b.userId;
    }
};
Q_DECLARE_METATYPE(SensMessage)

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

    bool sensMessageInsert(const QString &key, const QString &value, qint64 userId = 0);
    bool sensMessageRemove(const QString &key);
    QList<SensMessage> sensMessageFetchAll();

    bool profilePictureTimerSet(qint64 ms);
    qint64 profilePictureTimer() const;
    bool profilePictureTimerSourceSet(const QDateTime &time) { return setValue(PPIC_TIMER_SRC_KEY, time.toString()); }
    QDateTime profilePictureTimerSource() { return QDateTime::fromString(value(PPIC_TIMER_SRC_KEY).toString()); }

    bool saveAvatarsAdd(qint64 peerId, const QString &path);
    qint64 saveAvatarsRemovePeer(qint64 peer);
    QMap<qint64, QString> saveAvatarsFetchAll();

    static CommandPeerType inputPeerToCmdPeer(InputPeer::InputPeerType t);
    static InputPeer::InputPeerType cmdPeerToInputPeer(CommandPeerType t);

    bool addAccessHash(const QString &fileHash, const FileAccessHash &file);
    FileAccessHash getAccessHash(const QString &fileHash);
    bool removeAccessHash(const QString &fileHash);

public slots:
    bool setValue(const QString &key, const QVariant &value);
    QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;

signals:
    void profilePictureTimerChanged();
    void sensMessageChanged();
    void autoMessageChanged();
    void timerMessageChanged();

private:
    QList<TimerMessage> timerMessageQueryFetch(QSqlQuery &query);
    QList<AutoMessage> autoMessageQueryFetch(QSqlQuery &query);
    void initBuffer();
    void updateDb();
    QDateTime fixTime(const QDateTime &dt);

private:
    CommandsDatabasePrivate *p;
};

#endif // COMMANDSDATABASE_H
