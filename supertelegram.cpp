#define SERVICE_PID_PATH QString(AsemanApplication::homePath() + "/service.pid")

#include "asemantools/asemanapplication.h"
#include "supertelegram.h"
#include "commandsdatabase.h"
#include "supertelegram_macro.h"
#include "asemantools/asemanquickview.h"
#include "asemantools/asemanapplication.h"
#include "asemantools/asemandevices.h"

#ifdef Q_OS_ANDROID
#include "asemantools/asemanjavalayer.h"
#endif

#include <QProcess>
#include <QCoreApplication>
#include <QStringList>
#include <QPointer>
#include <QFile>

class SuperTelegramPrivate
{
public:
    QString defaultHostAddress;
    int defaultHostPort;
    int defaultHostDcId;
    int appId;
    QString appHash;

    QString phoneNumber;
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

QString SuperTelegram::picturesLocation() const
{
    return AsemanDevices::picturesLocation() + "/SuperTelegram";
}

CommandsDatabase *SuperTelegram::database() const
{
    return p->db;
}

QString SuperTelegram::getTimeString(const QDateTime &dt)
{
    if( QDate::currentDate() == dt.date() ) // TODAY
        return dt.toString("HH:mm");
    else
    if( dt.date().daysTo(QDate::currentDate()) < 7 )
        return dt.toString("ddd HH:mm");
    else
    if( dt.date().year() == QDate::currentDate().year() )
        return dt.toString("dd MMM");
    else
        return dt.toString("dd MMM yy");
}

QString getTimesDiffAnalize(qreal secs, int partsCount, const QString &name)
{
    qreal parts = secs/partsCount;
    qreal rParts = qRound(parts*10)/10.0;
    if(rParts >= 1)
        return QString("%1 " + name + (rParts>1?"s":"")).arg(rParts);
    else
        return QString();
}

QString SuperTelegram::getTimesDiff(const QDateTime &a, const QDateTime &b)
{
    int secs = a.secsTo(b);
    QString result = getTimesDiffAnalize(secs, 24*60*60, "day");
    if(result.isEmpty())
        result = getTimesDiffAnalize(secs, 60*60, "hour");
    if(result.isEmpty())
        result = getTimesDiffAnalize(secs, 60, "minute");

    return result;
}

bool SuperTelegram::startService()
{
#ifdef Q_OS_ANDROID
    if(!p->view || !p->view->javaLayer())
        return false;

    return p->view->javaLayer()->startService();
#else
    stopService();

    QFile file(SERVICE_PID_PATH);
    if(!file.open(QFile::WriteOnly))
        return false;

    qint64 pid = 0;
    QProcess::startDetached(AsemanApplication::applicationFilePath(),
                            QStringList()<<"--service",
                            AsemanApplication::applicationDirPath(),
                            &pid);

    file.write(QByteArray::number(pid));
    file.close();
    return true;
#endif
}

bool SuperTelegram::stopService()
{
#ifdef Q_OS_ANDROID
    if(!p->view || !p->view->javaLayer())
        return true;

    return p->view->javaLayer()->stopService();
#else
    QFile file(SERVICE_PID_PATH);
    if(!file.open(QFile::ReadOnly))
        return false;

    const qint64 pid = file.readAll().trimmed().toLongLong();
    file.close();

    QProcess::execute("kill", QStringList()<<QString::number(pid));
    return true;
#endif
}

SuperTelegram::~SuperTelegram()
{
    delete p;
}

