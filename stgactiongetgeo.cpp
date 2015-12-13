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
    if (p->locationListener)
    {
        connect(p->locationListener, SIGNAL(positionUpdated(QGeoPositionInfo)),
                SLOT(positionUpdated(QGeoPositionInfo)));
        p->locationListener->requestLocationUpdates(1000);
    }
    else
        emit finished();
}

void StgActionGetGeo::positionUpdated(const QGeoPositionInfo &update)
{
    if(!update.isValid())
    {
        qDebug() << "The update is invalid!";
        emit finished();
        return;
    }

    InputGeoPoint geo(InputGeoPoint::typeInputGeoPoint);
    geo.setLat(update.coordinate().latitude());
    geo.setLongValue(update.coordinate().longitude());

    p->telegram->messagesSendGeoPoint(p->peer, SuperTelegramService::generateRandomId(), geo, p->replyToId);
    if(!p->attachedMsg.isEmpty())
        p->telegram->messagesSendMessage(p->peer, SuperTelegramService::generateRandomId(), p->attachedMsg, p->replyToId);

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

