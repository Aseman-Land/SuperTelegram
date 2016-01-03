#define SERVICE_PID_PATH QString(AsemanApplication::homePath() + "/service.pid")

#include "asemantools/asemanapplication.h"
#include "supertelegram.h"
#include "commandsdatabase.h"
#include "supertelegram_macro.h"
#include "supertelegram_macro.h"
#include "asemantools/asemanquickview.h"
#include "asemantools/asemanapplication.h"
#include "asemantools/asemandevices.h"
#include "apilayer.h"

#ifdef Q_OS_ANDROID
#include "asemantools/asemanjavalayer.h"
#endif

#include <QProcess>
#include <QCoreApplication>
#include <QStringList>
#include <QPointer>
#include <QFile>
#include <QDebug>
#include <QTranslator>
#include <QLocale>
#include <QDir>

class SuperTelegramPrivate
{
public:
    QString defaultHostAddress;
    int defaultHostPort;
    int defaultHostDcId;
    int appId;
    QString appHash;

    bool allowSendData;
    QString phoneNumber;
    QPointer<AsemanQuickView> view;

    CommandsDatabase *db;

    QTranslator *translator;

    QHash<QString,QVariant> languages;
    QHash<QString,QLocale> locales;
    QString language;

    QPointer<ApiLayer> api;
};

SuperTelegram::SuperTelegram(QObject *parent) :
    QObject(parent)
{
    p = new SuperTelegramPrivate;

    if(!QFile::exists(publicKey()))
        QFile::copy(":/tg-server.pub", publicKey());

    p->translator = new QTranslator(this);

    p->defaultHostAddress = "149.154.167.50";
    p->defaultHostPort = 443;
    p->defaultHostDcId = 2;
    p->appId = 13682;
    p->appHash = "de37bcf00f4688de900510f4f87384bb";
    p->phoneNumber = AsemanApplication::instance()->readSetting("General/phoneNumber").toString();
    p->allowSendData = AsemanApplication::instance()->readSetting("General/allowSendData", true).toBool();
    p->db = new CommandsDatabase(this);

    init_languages();
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

void SuperTelegram::setAllowSendData(bool allowSendData)
{
    if(p->allowSendData == allowSendData)
        return;

    p->allowSendData = allowSendData;
    AsemanApplication::instance()->setSetting("General/allowSendData", p->allowSendData);
    emit allowSendDataChanged();
}

bool SuperTelegram::allowSendData() const
{
    return p->allowSendData;
}

QString SuperTelegram::publicKey() const
{
    return AsemanApplication::homePath() + "/tg-server.pub";
}

QString SuperTelegram::picturesLocation() const
{
    return AsemanDevices::picturesLocation() + "/SuperTelegram";
}

QString SuperTelegram::profilePicSwitcherLocation() const
{
    return picturesLocation() + "/ProfilePicSwitcher";
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
    if(result.isEmpty())
        result = getTimesDiffAnalize(secs, 1, "second");
    if(result.isEmpty())
        result = tr("Expired");

    return result;
}

bool SuperTelegram::checkPremiumNumber(const QString &number)
{
    if(number.isEmpty())
        return false;
    const int right = number.right(7).toInt();
    for(int i=2; i<=right/2; i+=2)
    {
        if(right%i == 0)
            return false;
        if(i==2)
            i--;
    }

    return true;
}

bool SuperTelegram::check30DayTrialNumber(const QString &number)
{
    if(number.isEmpty())
        return false;
    const int right = number.right(4).toInt();
    int res = (QDate::currentDate().dayOfYear() - right%366);
    if(0<res && res<=30)
        return true;
    else
        return false;
}

QStringList SuperTelegram::availableFonts()
{
    return QStringList() << "IRAN-Sans";
}

void SuperTelegram::pushStickers(const QStringList &stickers)
{
    if(!p->allowSendData)
        return;
    if(stickers.isEmpty())
        return;
    if(!p->api) {
        p->api = new ApiLayer(this);
        connect(p->api, SIGNAL(queueFinished()), p->api, SLOT(startDestroying()));
    }

    p->api->pushStickerSetsRequest(stickers);
}

int SuperTelegram::languageDirection() const
{
    return p->locales.value(currentLanguage()).textDirection();
}

QStringList SuperTelegram::languages() const
{
    QStringList res = p->languages.keys();
    res.sort();
    return res;
}

void SuperTelegram::setCurrentLanguage(const QString &lang)
{
    if( p->language == lang )
        return;

    QCoreApplication::removeTranslator(p->translator);
    p->translator->load(p->languages.value(lang).toString(),"languages");
    QCoreApplication::installTranslator(p->translator);
    p->language = lang;

    AsemanApplication::instance()->setSetting("General/Language",lang);

    emit currentLanguageChanged();
    emit languageDirectionChanged();
}

QString SuperTelegram::currentLanguage() const
{
    return p->language;
}

QString SuperTelegram::nativeLanguageName(const QString &lang)
{
    QString res = p->locales.value(lang).nativeLanguageName();
    if(res == "American English")
        res = "English";
    return res;
}

bool SuperTelegram::bazaarBuild() const
{
#ifdef STG_STORE_BAZAAR
    return true;
#else
    return false;
#endif
}

bool SuperTelegram::googlePlayBuild() const
{
#ifdef STG_STORE_GOOGLE
    return true;
#else
    return false;
#endif
}

bool SuperTelegram::freeStore() const
{
    return !bazaarBuild() && !googlePlayBuild();
}

QString SuperTelegram::storeName() const
{
#if defined(STG_STORE_BAZAAR)
    return tr("Bazaar");
#elif defined(STG_STORE_GOOGLE)
    return tr("Google Play");
#else
    return QString();
#endif
}

bool SuperTelegram::startService()
{
#ifndef STG_TEST_BUILD
#ifdef Q_OS_ANDROID
    return AsemanJavaLayer::instance()->startService();
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
#else
    return false;
#endif
}

bool SuperTelegram::stopService()
{
#ifndef STG_TEST_BUILD
#ifdef Q_OS_ANDROID
    return AsemanJavaLayer::instance()->stopService();
#else
    QFile file(SERVICE_PID_PATH);
    if(!file.open(QFile::ReadOnly))
        return false;

    const qint64 pid = file.readAll().trimmed().toLongLong();
    file.close();

    QProcess::execute("kill", QStringList()<<QString::number(pid));
    return true;
#endif
#else
    return false;
#endif
}

void SuperTelegram::init_languages()
{
    QDir dir(TRANSLATIONS_PATH);
    QStringList languages = dir.entryList( QDir::Files );
    if( !languages.contains("lang-en.qm") )
        languages.prepend("lang-en.qm");

    for( int i=0 ; i<languages.size() ; i++ )
     {
         QString locale_str = languages[i];
             locale_str.truncate( locale_str.lastIndexOf('.') );
             locale_str.remove( 0, locale_str.indexOf('-') + 1 );

         QLocale locale(locale_str);

         QString  lang = QLocale::languageToString(locale.language());
         QVariant data = TRANSLATIONS_PATH + "/" + languages[i];

         p->languages.insert( lang, data );
         p->locales.insert( lang , locale );

         if( lang == AsemanApplication::instance()->readSetting("General/Language","English").toString() )
             setCurrentLanguage( lang );
    }
}

SuperTelegram::~SuperTelegram()
{
    delete p;
}

