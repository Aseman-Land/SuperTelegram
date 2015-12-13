#include "stgactiongetgeo.h"
#include "telegram.h"
#include "supertelegramservice.h"
#include "asemantools/asemanlocationlistener.h"

#include <QPointer>
#include <QGeoPositionInfoSource>

class StgActionGetGeoPrivate
{
public:
    QPointer<AsemanLocationListener> locationListener;
    QPointer<Telegram> telegram;
    QString attachedMsg;
    InputPeer peer;
    qint64 replyToId;
};

StgActionGetGeo::StgActionGetGeo(QObject *parent) :
    AbstractStgAction(parent)
{
    p = new StgActionGetGeoPrivate;
    p->replyToId = 0;
}

QStringList StgActionGetGeo::keywords() const
{
    return QStringList() << "%location%";
}

void StgActionGetGeo::start(Telegram *tg, const InputPeer &peer, qint64 replyToId, const QString &attachedMsg)
{
    if(p->telegram || !tg)
    {
        emit finished();
        return;
    }

    p->telegram = tg;
    p->peer = peer;
    p->attachedMsg = attachedMsg;
    p->replyToId = replyToId;

    p->locationListener = new AsemanLocationListener(this);

    p->telegram->messagesSendMessage(p->peer, SuperTelegramService::generateRandomId(), tr("Your message is recieved my Lord.\nTrying to find the location.\nPlease Wait..."), p->replyToId);

    connect(p->locationListener, SIGNAL(positionUpdated(QGeoPositionInfo)),
            SLOT(positionUpdated(QGeoPositionInfo)));
    p->locationListener->requestLocationUpdates(1000);
}

void StgActionGetGeo::positionUpdated(const QGeoPositionInfo &update)
{
    if(!update.isValid())
    {
        qDebug() << "The update is invalid!";
        p->telegram->messagesSendMessage(p->peer, SuperTelegramService::generateRandomId(), tr("Sorry. There is an error.\nI can't find the location :("), p->replyToId);
        emit finished();
        return;
    }

    InputGeoPoint geo(InputGeoPoint::typeInputGeoPoint);
    geo.setLat(update.coordinate().latitude());
    geo.setLongValue(update.coordinate().longitude());

    p->telegram->messagesSendGeoPoint(p->peer, SuperTelegramService::generateRandomId(), geo, p->replyToId);
    if(!p->attachedMsg.isEmpty())
        p->telegram->messagesSendMessage(p->peer, SuperTelegramService::generateRandomId(),
                                         p->attachedMsg.replace("%location%","%1, %2").arg(geo.lat()).arg(geo.longValue()),
                                         p->replyToId);

    emit finished();
}

void StgActionGetGeo::error(QGeoPositionInfoSource::Error positioningError)
{
    qDebug() << positioningError;
    emit finished();
}

StgActionGetGeo::~StgActionGetGeo()
{
    delete p;
}

