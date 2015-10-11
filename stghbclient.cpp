#include "stghbclient.h"
#include "hyperbus/hyperbusreciever.h"

#include <QThread>

class StgHBClientPrivate
{
public:
    QThread *thread;
    StgHBClientCore *core;
};

StgHBClient::StgHBClient(QObject *parent) :
    QObject(parent)
{
    p = new StgHBClientPrivate;
    p->thread = 0;
    p->core = 0;
}

void StgHBClient::update(int reason)
{
    init();
    QMetaObject::invokeMethod(p->core, "update", Qt::QueuedConnection, Q_ARG(int, reason));
}

void StgHBClient::init()
{
    if(p->core)
        return;

    p->thread = new QThread(this);
    p->thread->start();

    p->core = new StgHBClientCore();
    p->core->moveToThread(p->thread);
}

StgHBClient::~StgHBClient()
{
    delete p;
}



StgHBClientCore::StgHBClientCore(QObject *parent) :
    QObject(parent)
{
}

void StgHBClientCore::update(int reason)
{
    HyperBusReciever reciever("127.0.0.1", 23784);
    reciever.sendCommand("/update", QList<QByteArray>()<<QByteArray::number(reason) );
}

StgHBClientCore::~StgHBClientCore()
{

}
