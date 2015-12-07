#define ADD_USER_BLOCK_TIMER(USER_ID) { \
        int timerId = startTimer(5*60*1000); \
        p->userSentBlockTimer.insert(USER_ID, timerId); \
    }

#include "supertelegramservice.h"
#include "supertelegram.h"
#include "stghbserver.h"
#include "asemantools/asemanapplication.h"
#include "asemantools/asemandevices.h"
#include "asemantools/asemanhostchecker.h"
#include "commandsdatabase.h"
#include "stghbclient.h"

#include "telegram.h"
#include "util/utils.h"

#include <QDir>
#include <QFileInfo>
#include <QTimer>
#include <QDebug>
#include <QTimerEvent>
#include <QGeoPositionInfoSource>
#include <QPointer>
#include <QSet>

class SuperTelegramServicePrivate
{
public:
    QPointer<Telegram> telegram;
    QPointer<SuperTelegram> stg;
    QPointer<CommandsDatabase> db;

    QTimer *timerMessageClock;
    QTimer *updateClock;

    QTimer *tgSleepTimer;
    QTimer *tgWakeTimer;
    QTimer *tgUpdateTimer;
    QTimer *tgAutoUpdateTimer;

    AutoMessage activeAutoMessages;
    QList<SensMessage> sensMessages;

    QHash<qint64, qint64> userSentBlockTimer;

    QPointer<QGeoPositionInfoSource> positionSource;
    QGeoPositionInfo lastPosition;

    AsemanHostChecker *hostChecker;
    bool external;

    QSet<qint64> answeredMessages;
};

SuperTelegramService::SuperTelegramService(QObject *parent) :
    QObject(parent)
{
    p = new SuperTelegramServicePrivate;
    p->tgSleepTimer = 0;
    p->tgWakeTimer = 0;
    p->hostChecker = 0;
    p->external = false;

//    p->positionSource = QGeoPositionInfoSource::createDefaultSource(0);
    if (p->positionSource)
    {
        p->positionSource->setUpdateInterval(10000);
        p->positionSource->startUpdates();

        connect(p->positionSource, SIGNAL(positionUpdated(QGeoPositionInfo)), SLOT(positionUpdated(QGeoPositionInfo)));
    }

    p->updateClock = new QTimer(this);
    p->updateClock->setInterval(5*60*1000);

    p->timerMessageClock = new QTimer(this);
    p->timerMessageClock->setSingleShot(true);

    p->tgUpdateTimer = new QTimer(this);
    p->tgUpdateTimer->setInterval(3000);
    p->tgUpdateTimer->setSingleShot(true);

    p->tgAutoUpdateTimer = new QTimer(this);
    p->tgAutoUpdateTimer->setInterval(1*60*1000);
    p->tgAutoUpdateTimer->setSingleShot(false);
    p->tgAutoUpdateTimer->start();

    connect(p->timerMessageClock, SIGNAL(timeout()), SLOT(clockTriggred()));
    connect(p->updateClock, SIGNAL(timeout()), SLOT(update()));
    connect(p->tgUpdateTimer, SIGNAL(timeout()), SLOT(updatesGetState()));
    connect(p->tgAutoUpdateTimer, SIGNAL(timeout()), SLOT(updatesGetState()));
}

void SuperTelegramService::start(Telegram *tg, SuperTelegram *stg, AsemanHostChecker *hostChecker)
{
    if(p->telegram)
        return;

    if(tg)
    {
        p->stg = stg;
        p->db = p->stg->database();
        p->telegram = tg;
        p->hostChecker = hostChecker;
        p->external = true;
    }
    else
    {
        p->stg = new SuperTelegram(this);

        p->hostChecker = new AsemanHostChecker(this);
        p->db = p->stg->database();

        const QString phoneNumber = p->stg->phoneNumber();
        const QString configPath = AsemanApplication::homePath();
        if(!QFileInfo::exists(configPath + "/" + phoneNumber + "/auth"))
        {
            QTimer::singleShot(1, AsemanApplication::instance(), SLOT(exit()));
            return;
        }

        QDir().mkpath(configPath);

        p->telegram = new Telegram(p->stg->defaultHostAddress(),
                                   p->stg->defaultHostPort(),
                                   p->stg->defaultHostDcId(),
                                   p->stg->appId(),
                                   p->stg->appHash(),
                                   phoneNumber,
                                   configPath,
                                   p->stg->publicKey());

        connect(p->telegram, SIGNAL(authNeeded()), SLOT(authNeeded()));
        QTimer::singleShot(1000, this, SLOT(initTelegram()));

        p->hostChecker->setHost(p->stg->defaultHostAddress());
        p->hostChecker->setPort(p->stg->defaultHostPort());
        p->hostChecker->setInterval(5000);
    }

    p->tgWakeTimer = new QTimer(this);
    p->tgWakeTimer->setInterval(1000);
    p->tgWakeTimer->setSingleShot(true);

    p->tgSleepTimer = new QTimer(this);
    p->tgSleepTimer->setInterval(30*60*1000);
    p->tgSleepTimer->setSingleShot(false);
    p->tgSleepTimer->start();

    connect(p->tgSleepTimer, SIGNAL(timeout()), this, SLOT(sleep()));
    connect(p->tgSleepTimer, SIGNAL(timeout()), p->tgWakeTimer, SLOT(start()));
    connect(p->tgWakeTimer, SIGNAL(timeout()), this, SLOT(wake()));

    p->timerMessageClock->start();

    connect(p->db, SIGNAL(autoMessageChanged()), SLOT(updateAutoMessage()));
    connect(p->db, SIGNAL(sensMessageChanged()), SLOT(updateSensMessage()));

    connect(p->telegram, SIGNAL(authLoggedIn()), SLOT(authLoggedIn()));
    connect(p->telegram, SIGNAL(updateShortMessage(qint32,qint32,QString,qint32,qint32,qint32,qint32,qint32,qint32,bool,bool)),
            SLOT(updateShortMessage(qint32,qint32,QString,qint32,qint32,qint32,qint32,qint32,qint32,bool,bool)));

    connect(p->hostChecker, SIGNAL(availableChanged()), SLOT(hostCheckerStateChanged()));

    updateAutoMessage();
    updateSensMessage();
    startClock();
}

void SuperTelegramService::stop()
{
    if(!p->telegram)
        return;

    delete p->telegram;
    p->telegram = 0;

    p->timerMessageClock->stop();
}

void SuperTelegramService::authNeeded()
{
    AsemanApplication::exit(0);
}

void SuperTelegramService::authLoggedIn()
{
    qDebug() << "Logged In";
    p->telegram->updatesGetState();
}

void SuperTelegramService::clockTriggred()
{
    const QDateTime &dt = QDateTime::currentDateTime();

    checkTimerMessages(dt);

    startClock();
}

void SuperTelegramService::update()
{
    if(!p->telegram)
        return;

    p->telegram->updatesGetState();
}

void SuperTelegramService::updateShortMessage(qint32 id, qint32 userId, const QString &message, qint32 pts, qint32 pts_count, qint32 date, qint32 fwd_from_id, qint32 fwd_date, qint32 reply_to_msg_id, bool unread, bool out)
{
    Q_UNUSED(pts)
    Q_UNUSED(pts_count)
    Q_UNUSED(date)
    Q_UNUSED(fwd_from_id)
    Q_UNUSED(fwd_date)
    Q_UNUSED(reply_to_msg_id)
    Q_UNUSED(message)

    if(!unread || out)
        return;
    if(p->userSentBlockTimer.contains(userId))
        return;
    if(p->answeredMessages.contains(id))
        return;

    InputPeer input(InputPeer::typeInputPeerContact);
    input.setUserId(userId);

    if(!p->activeAutoMessages.guid.isEmpty())
    {
        p->telegram->messagesSendMessage(input, generateRandomId(), tr("Auto message by SuperTelegram: %1").arg(p->activeAutoMessages.message), id);
        p->answeredMessages.insert(id);
        ADD_USER_BLOCK_TIMER(userId)
    }
    else
    {
        foreach(const SensMessage &sens, p->sensMessages)
            if(message.toLower().trimmed() == sens.key.toLower().trimmed())
            {
                if(sens.value.contains("%location%"))
                {
                    InputGeoPoint geo(InputGeoPoint::typeInputGeoPoint);
                    geo.setLat(p->lastPosition.coordinate().latitude());
                    geo.setLongValue(p->lastPosition.coordinate().longitude());

                    p->telegram->messagesSendGeoPoint(input, generateRandomId(), geo, id);
                    p->telegram->messagesSendMessage(input, generateRandomId(), tr("Auto message by SuperTelegram: %1")
                                                     .arg(QString(sens.value).replace("%location%", QString("%1, %2").arg(geo.lat()).arg(geo.longValue()) )), id);
                }
                else
                    p->telegram->messagesSendMessage(input, generateRandomId(), tr("Auto message by SuperTelegram: %1").arg(QString(sens.value)));

                p->answeredMessages.insert(id);
                break;
            }
    }
}

void SuperTelegramService::updated(int reason)
{
    switch(reason)
    {
    case StgHBClient::UpdateAutoMessageReason:
        updateAutoMessage();
        break;

    case StgHBClient::UpdateRewakeReason:
        p->telegram->sleep();
        p->telegram->wake();
        break;
    }
}

void SuperTelegramService::positionUpdated(const QGeoPositionInfo &update)
{
    p->lastPosition = update;
}

void SuperTelegramService::updateAutoMessage()
{
    if(!p->db) return;
    p->activeAutoMessages = p->db->autoMessageActiveMessage();
}

void SuperTelegramService::updateSensMessage()
{
    if(!p->db) return;
    p->sensMessages = p->db->sensMessageFetchAll();
}

void SuperTelegramService::initTelegram()
{
    if(!p->telegram)
        return;

    p->telegram->init();
}

void SuperTelegramService::hostCheckerStateChanged()
{
    if(p->hostChecker->available())
        wake();
    else
        sleep();
}

void SuperTelegramService::updatesGetState()
{
    if(p->telegram) p->telegram->updatesGetState();
}

void SuperTelegramService::wake()
{
    qDebug() << __FUNCTION__;
    if(p->telegram) p->telegram->wake();
    p->tgUpdateTimer->stop();
    p->tgUpdateTimer->start();
    p->tgAutoUpdateTimer->stop();
    p->tgAutoUpdateTimer->start();
}

void SuperTelegramService::sleep()
{
    qDebug() << __FUNCTION__;
    if(p->telegram) p->telegram->sleep();
    p->tgUpdateTimer->stop();
    p->tgAutoUpdateTimer->stop();
}

void SuperTelegramService::timerEvent(QTimerEvent *e)
{
    const qint64 userId = p->userSentBlockTimer.key(e->timerId());
    if(userId)
    {
        p->userSentBlockTimer.remove(userId);
        killTimer(e->timerId());
    }
}

void SuperTelegramService::startClock()
{
    const QTime &time = QTime::currentTime();
    const int msec = 60000 - (time.second()*1000 + time.msec()) + 1000;

    p->timerMessageClock->start(msec);
}

void SuperTelegramService::checkTimerMessages(const QDateTime &dt)
{
    if(!p->db) return;

    const QList<TimerMessage> &timerMessages = p->db->timerMessageFetch(dt);
    foreach(const TimerMessage &tm, timerMessages)
    {
        p->telegram->messagesSendMessage(tm.peer, generateRandomId(), tm.message);
    }
}

qint64 SuperTelegramService::generateRandomId() const
{
    qint64 randomId;
    Utils::randomBytes(&randomId, 8);
    return randomId;
}

SuperTelegramService::~SuperTelegramService()
{
    delete p;
}

