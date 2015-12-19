#ifndef SUPERTELEGRAMSERVICE_H
#define SUPERTELEGRAMSERVICE_H

#include <QObject>

class InputPeer;
class AsemanNetworkSleepManager;
class SuperTelegram;
class Telegram;
class Chat;
class User;
class Update;
class SuperTelegramServicePrivate;
class SuperTelegramService : public QObject
{
    Q_OBJECT
public:
    SuperTelegramService(QObject *parent = 0);
    ~SuperTelegramService();

    static qint64 generateRandomId();

public slots:
    void start(Telegram *tg = 0, SuperTelegram *stg = 0, AsemanNetworkSleepManager *sleepManager = 0);
    void stop();
    void wake();
    void sleep();

private slots:
    void authNeeded();
    void authLoggedIn();
    void clockTriggred();
    void switchPicture();
    void update();
    void updateShortMessage(qint32 id, qint32 userId, const QString &message, qint32 pts, qint32 pts_count, qint32 date, qint32 fwd_from_id, qint32 fwd_date, qint32 reply_to_msg_id, bool unread, bool out);

    void updated(int reason);

    void updateAutoMessage();
    void updateSensMessage();
    void updatePPicChanged();
    void initTelegram();
    void hostCheckerStateChanged();
    void updatesGetState();

protected:
    void timerEvent(QTimerEvent *e);

private:
    void startClock();

    void checkTimerMessages(const QDateTime &dt);
    void processOnTheMessage(qint32 id, const InputPeer &input, const QString &msg);

private:
    SuperTelegramServicePrivate *p;
};

#endif // SUPERTELEGRAMSERVICE_H
