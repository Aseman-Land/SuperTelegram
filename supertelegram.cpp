#include "supertelegram.h"
#include "commandsdatabase.h"
#include "asemantools/asemanquickview.h"
#include "asemantools/asemanapplication.h"

#ifdef Q_OS_ANDROID
#include "asemantools/asemanjavalayer.h"
#endif

#include <QProcess>
#include <QCoreApplication>
#include <QStringList>
#include <QPointer>

class SuperTelegramPrivate
{
public:
    QString defaultHostAddress;
    int defaultHostPort;
    int defaultHostDcId;
    int appId;
    QString appHash;

    QString phoneNumber;

#ifndef Q_OS_ANDROID
    QPointer<QProcess> process;
#endif
    QPointer<AsemanQuickView> view;

    CommandsDatabase *db;
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
    p->phoneNumber = AsemanApplication::instance()->readSetting("General/phoneNumber").toString();
    p->db = new CommandsDatabase(this);
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

void SuperTelegram::setView(QObject *v)
{
    AsemanQuickView *view = qobject_cast<AsemanQuickView*>(v);
    if(view && !v)
        return;
    if(p->view == view)
        return;

    p->view = view;
    emit viewChanged();
}

QObject *SuperTelegram::view() const
{
    return p->view;
}

void SuperTelegram::setPhoneNumber(const QString &phoneNumber)
{
    if(p->phoneNumber == phoneNumber)
        return;

    p->phoneNumber = phoneNumber;
    AsemanApplication::instance()->setSetting("General/phoneNumber", p->phoneNumber);
    emit phoneNumberChanged();
}

QString SuperTelegram::phoneNumber() const
{
    return p->phoneNumber;
}

bool SuperTelegram::startService()
{
#ifdef Q_OS_ANDROID
    if(!p->view || !p->view->javaLayer())
        return false;

    return p->view->javaLayer()->startService();
#else
    if(p->process)
        return true;

    const QString &cmd = AsemanApplication::applicationFilePath();
    QStringList args;
    args << "--service";

    p->process = new QProcess(this);
    p->process->setReadChannelMode(QProcess::ForwardedChannels);
    p->process->start(cmd, args);

    connect(p->process, SIGNAL(finished(int)), p->process, SLOT(deleteLater()));
    return true;
#endif
}

bool SuperTelegram::stopService()
{
#ifdef Q_OS_ANDROID
    if(!p->view || !p->view->javaLayer())
        return;

    return p->view->javaLayer()->stopService();
#else
    if(!p->process)
        return true;

    p->process->terminate();
    p->process = 0;
    return true;
#endif
}

SuperTelegram::~SuperTelegram()
{
    delete p;
}

