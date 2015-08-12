#include "supertelegram.h"

class SuperTelegramPrivate
{
public:
    QString defaultHostAddress;
    int defaultHostPort;
    int defaultHostDcId;
    int appId;
    QString appHash;
};

SuperTelegram::SuperTelegram(QObject *parent) :
    QObject(parent)
{
    p = new SuperTelegramPrivate;
    p->defaultHostAddress = "149.154.167.50";
    p->defaultHostPort = 443;
    p->defaultHostDcId = 2;
    p->appId = 13682;
    p->appHash = "de37bcf00f4688de900510f4f87384bb";
}

void SuperTelegram::setDefaultHostAddress(const QString &host)
{
    if(p->defaultHostAddress == host)
        return;

    p->defaultHostAddress = host;
    emit defaultHostAddressChanged();
}

QString SuperTelegram::defaultHostAddress() const
{
    return p->defaultHostAddress;
}

void SuperTelegram::setDefaultHostPort(int port)
{
    if(p->defaultHostPort == port)
        return;

    p->defaultHostPort = port;
    emit defaultHostPortChanged();
}

int SuperTelegram::defaultHostPort() const
{
    return p->defaultHostPort;
}

void SuperTelegram::setDefaultHostDcId(int dcId)
{
    if(p->defaultHostDcId == dcId)
        return;

    p->defaultHostDcId = dcId;
    emit defaultHostDcIdChanged();
}

int SuperTelegram::defaultHostDcId() const
{
    return p->defaultHostDcId;
}

void SuperTelegram::setAppId(int appId)
{
    if(p->appId == appId)
        return;

    p->appId = appId;
    emit appIdChanged();
}

int SuperTelegram::appId() const
{
    return p->appId;
}

void SuperTelegram::setAppHash(const QString &appHash)
{
    if(p->appHash == appHash)
        return;

    p->appHash = appHash;
    emit appHashChanged();
}

QString SuperTelegram::appHash() const
{
    return p->appHash;
}

SuperTelegram::~SuperTelegram()
{
    delete p;
}

