#ifndef SUPERTELEGRAMSERVICE_H
#define SUPERTELEGRAMSERVICE_H

#include <QObject>
#include <QDateTime>

class StgStoreManagerCore;
class InputPeer;
class AsemanNetworkSleepManager;
class SuperTelegram;
class Telegram;
class Chat;
class User;
class Dialog;
class Message;
class Update;
class Photo;
class SuperTelegramServicePrivate;
class SuperTelegramService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qint64 profilePictureEstimatedTime READ profilePictureEstimatedTime NOTIFY profilePictureEstimatedTimeChanged)

public:
    SuperTelegramService(QObject *parent = 0);
    ~SuperTelegramService();

    static qint64 generateRandomId();
    qint64 profilePictureEstimatedTime() const;

public slots:
    void start(Telegram *tg = 0,
               SuperTelegram *stg = 0,
               AsemanNetworkSleepManager *sleepManager = 0,
               StgStoreManagerCore *store = 0);
    void stop();
    void wake();
    void sleep();

    void updatesGetState();
    void updateDialogs();
    void updateProfilePictureEstimatedTime(const QDateTime &dt = QDateTime::currentDateTime());

signals:
    void profilePictureEstimatedTimeChanged();

private slots:
    void authNeeded();
    void authLoggedIn();
    void clockTriggred();
    void switchPicture();
    void updateShortMessage(qint32 id, qint32 userId, const QString &message, qint32 pts, qint32 pts_count, qint32 date, qint32 fwd_from_id, qint32 fwd_date, qint32 reply_to_msg_id, bool unread, bool out);
    void messagesGetDialogsAnswer(qint64 id, qint32 sliceCount, const QList<Dialog> &dialogs, const QList<Message> &messages, const QList<Chat> &chats, const QList<User> &users);
    void photosUploadProfilePhotoAnswer(qint64 id, const Photo &photo, const QList<User> &users);
    void authCheckedPhoneError_slt(qint64 msgId);
    void fatalError();

    void updateAutoMessage();
    void updateSensMessage();
    void updatePPicChanged();
    void initTelegram();
    void hostCheckerStateChanged();

protected:
    void timerEvent(QTimerEvent *e);

private:
    void startClock();

    void checkTimerMessages(const QDateTime &dt);
    void checkProfilePicState(const QDateTime &dt);
    void checkPendingActions();
    void processOnTheMessage(qint32 id, const InputPeer &input, const QString &msg);

    QString getNextProfilePicture() const;

    Telegram *initTelegramObject();
    void initTelegramSignal(Telegram *telegram);

private:
    SuperTelegramServicePrivate *p;
};

#endif // SUPERTELEGRAMSERVICE_H
