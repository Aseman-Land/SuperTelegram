#include "supertelegramservice.h"
#include "supertelegram.h"
#include "asemantools/asemanapplication.h"
#include "asemantools/asemandevices.h"

#include <telegram.h>

#include <QDir>
#include <QFileInfo>
#include <QTimer>
#include <QDebug>

class SuperTelegramServicePrivate
{
public:
    SuperTelegram *stg;
    Telegram *telegram;
};

SuperTelegramService::SuperTelegramService(QObject *parent) :
    QObject(parent)
{
    p = new SuperTelegramServicePrivate;
    p->stg = new SuperTelegram(this);
    p->telegram = 0;
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
}

SuperTelegramService::~SuperTelegramService()
{
    delete p;
}

