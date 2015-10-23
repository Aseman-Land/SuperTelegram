#ifndef SUPERTELEGRAMSERVICE_H
#define SUPERTELEGRAMSERVICE_H

#include <QObject>

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

public slots:
    void start(Telegram *tg = 0);
    void stop();

private slots:
    void authNeeded();
    void authLoggedIn();
    void clockTriggred();
    void updateShortMessage(qint32 id, qint32 userId, const QString &message, qint32 pts, qint32 pts_count, qint32 date, qint32 fwd_from_id, qint32 fwd_date, qint32 reply_to_msg_id, bool unread, bool out);

    void updated(int reason);

private:
    void startClock();
    qint64 generateRandomId() const;

    void checkTimerMessages(const QDateTime &dt);

private slots:
    void updateAutoMessage();
    void updateSensMessage();
    void initTelegram();

protected:
    void timerEvent(QTimerEvent *e);

private:
    SuperTelegramServicePrivate *p;
};

#endif // SUPERTELEGRAMSERVICE_H
