#include "asemannetworkchecker.h"

#include <QNetworkConfigurationManager>
#include <QNetworkAccessManager>

class AsemanNetworkCheckerPrivate
{
public:
    QNetworkAccessManager *network;
};

AsemanNetworkChecker::AsemanNetworkChecker(QObject *parent) :
    QObject(parent)
{
    p = new AsemanNetworkCheckerPrivate;
    p->network = new QNetworkAccessManager(this);

    connect(p->network, SIGNAL(networkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility)),
            this, SIGNAL(onlineChanged()));
}

bool AsemanNetworkChecker::online() const
{
    return p->network->networkAccessible() == QNetworkAccessManager::Accessible;
}

AsemanNetworkChecker::~AsemanNetworkChecker()
{
    delete p;
}

