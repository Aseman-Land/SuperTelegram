#include "supertelegramservice.h"
#include "supertelegram.h"
#include "stghbserver.h"
#include "asemantools/asemanapplication.h"
#include "asemantools/asemandevices.h"
#include "commandsdatabase.h"
#include "stghbclient.h"

#include "telegram.h"
#include "util/utils.h"

#include <QDir>
#include <QFileInfo>
#include <QTimer>
#include <QDebug>

class SuperTelegramServicePrivate
{
public:
    SuperTelegram *stg;
    Telegram *telegram;
    CommandsDatabase *db;
    StgHBServer *server;

    QTimer *clock;

    AutoMessage activeAutoMessages;
};

SuperTelegramService::SuperTelegramService(QObject *parent) :
    QObject(parent)
{
    p = new SuperTelegramServicePrivate;

    p->clock = new QTimer(this);
    p->clock->setSingleShot(true);

    p->db = new CommandsDatabase(this);

    p->stg = new SuperTelegram(this);
    p->telegram = 0;

    p->server = new StgHBServer(this);

    connect(p->clock , SIGNAL(timeout())   , SLOT(clockTriggred()));
    connect(p->server, SIGNAL(updated(int)), SLOT(updated(int))   );

    updateAutoMessage();
    startClock();
}

void SuperTelegramService::start()
{
    if(p->telegram)
        return;

    const QString phoneNumber = p->stg->phoneNumber();
    const QString configPath = AsemanApplication::homePath();
    const QString pkey = AsemanDevices::resourcePath() + "/tg-server.pub";
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
                               pkey);
    p->telegram->init();

    connect(p->telegram, SIGNAL(authNeeded()), SLOT(authNeeded()));
    connect(p->telegram, SIGNAL(authLoggedIn()), SLOT(authLoggedIn()));

    connect(p->telegram, SIGNAL(updateShortMessage(qint32,qint32,QString,qint32,qint32,qint32,qint32,qint32,qint32,bool,bool)),
            SLOT(updateShortMessage(qint32,qint32,QString,qint32,qint32,qint32,qint32,qint32,qint32,bool,bool)));
}

void SuperTelegramService::stop()
{
    if(!p->telegram)
        return;

    delete p->telegram;
    p->telegram = 0;
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

    InputPeer input(InputPeer::typeInputPeerContact);
    input.setUserId(userId);

    if(!p->activeAutoMessages.guid.isEmpty())
        p->telegram->messagesSendMessage(input, generateRandomId(), tr("Auto message by SuperTelegram: %1").arg(p->activeAutoMessages.message), id);
}

void SuperTelegramService::updated(int reason)
{
    switch(reason)
    {
    case StgHBClient::UpdateAutoMessageReason:
        updateAutoMessage();
        break;
    }
}

void SuperTelegramService::updateAutoMessage()
{
    p->activeAutoMessages = p->db->autoMessageActiveMessage();
}

void SuperTelegramService::startClock()
{
    const QTime &time = QTime::currentTime();
    const int msec = 60000 - (time.second()*1000 + time.msec()) + 1000;

    p->clock->start(msec);
}

void SuperTelegramService::checkTimerMessages(const QDateTime &dt)
{
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

