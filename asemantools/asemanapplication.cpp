/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "asemanapplication.h"
#include "asemantools.h"

#include <QDir>
#include <QFont>
#include <QSettings>
#include <QThread>
#include <QCoreApplication>
#include <QDebug>

#ifdef QT_GUI_LIB
#include <QGuiApplication>
#endif
#ifdef QT_CORE_LIB
#include <QCoreApplication>
#endif
#ifdef QT_WIDGETS_LIB
#include <QApplication>
#include "qtsingleapplication/qtsingleapplication.h"
#endif

static QSettings *app_global_settings = 0;
static AsemanApplication *aseman_app_singleton = 0;

class AsemanApplicationPrivate
{
public:
    QFont globalFont;
    int appType;
    QCoreApplication *app;
};

AsemanApplication::AsemanApplication() :
    QObject()
{
    p = new AsemanApplicationPrivate;
    p->app = QCoreApplication::instance();
    p->appType = NoneApplication;

#ifdef QT_WIDGETS_LIB
    if( qobject_cast<QtSingleApplication*>(p->app) )
        p->appType = WidgetApplication;
    else
#endif
#ifdef QT_GUI_LIB
    if( qobject_cast<QGuiApplication*>(p->app) )
        p->appType = GuiApplication;
    else
#endif
#ifdef QT_CORE_LIB
    if( qobject_cast<QCoreApplication*>(p->app) )
        p->appType = CoreApplication;
#endif

    if(!aseman_app_singleton)
        aseman_app_singleton = this;
}

AsemanApplication::AsemanApplication(int &argc, char **argv, ApplicationType appType) :
    QObject()
{
    if(!aseman_app_singleton)
        aseman_app_singleton = this;

    p = new AsemanApplicationPrivate;
    p->appType = appType;

    switch(p->appType)
    {
#ifdef QT_CORE_LIB
    case CoreApplication:
        p->app = new QCoreApplication(argc, argv);
        connect(p->app, SIGNAL(organizationNameChanged())  , SIGNAL(organizationNameChanged()));
        connect(p->app, SIGNAL(organizationDomainChanged()), SIGNAL(organizationDomainChanged()));
        connect(p->app, SIGNAL(applicationNameChanged())   , SIGNAL(applicationNameChanged()));
        connect(p->app, SIGNAL(applicationVersionChanged()), SIGNAL(applicationVersionChanged()));
        break;
#endif
#ifdef QT_GUI_LIB
    case GuiApplication:
        p->app = new QGuiApplication(argc, argv);
        connect(p->app, SIGNAL(lastWindowClosed()), SIGNAL(lastWindowClosed()));
        break;
#endif
#ifdef QT_WIDGETS_LIB
    case WidgetApplication:
        p->app = new QtSingleApplication(argc, argv);
        connect(p->app, SIGNAL(messageReceived(QString)), SIGNAL(messageReceived(QString)));
        break;
#endif
    default:
        p->app = 0;
        break;
    }
}

QString AsemanApplication::homePath()
{
    QString result;

#ifdef Q_OS_ANDROID
    result = QDir::homePath();
#else
#ifdef Q_OS_IOS
    result = QDir::homePath();
#else
#ifdef Q_OS_WIN
    result = QDir::homePath() + "/AppData/Local/" + QCoreApplication::applicationName();
#else
    result = QDir::homePath() + "/.config/" + QCoreApplication::applicationName();
#endif
#endif
#endif

    return result;
}

QString AsemanApplication::appPath()
{
    return QCoreApplication::applicationDirPath();
}

QString AsemanApplication::appFilePath()
{
    return QCoreApplication::applicationFilePath();
}

QString AsemanApplication::logPath()
{
#ifdef Q_OS_ANDROID
    return "/sdcard/" + QCoreApplication::organizationDomain() + "/" + QCoreApplication::applicationName() + "/log";
#else
    return homePath()+"/log";
#endif
}

QString AsemanApplication::confsPath()
{
    return homePath() + "/config.ini";
}

QString AsemanApplication::tempPath()
{
#ifdef Q_OS_ANDROID
    return "/sdcard/" + QCoreApplication::organizationDomain() + "/" + QCoreApplication::applicationName() + "/temp";
#else
#ifdef Q_OS_IOS
    return QDir::homePath() + "/tmp/";
#else
    return QDir::tempPath();
#endif
#endif
}

QString AsemanApplication::backupsPath()
{
#ifdef Q_OS_ANDROID
    return "/sdcard/" + QCoreApplication::organizationDomain() + "/" + QCoreApplication::applicationName() + "/backups";
#else
#ifdef Q_OS_IOS
    return QDir::homePath() + "/backups/";
#else
    return homePath() + "/backups";
#endif
#endif
}

QString AsemanApplication::cameraPath()
{
#ifdef Q_OS_ANDROID
    return "/sdcard/DCIM";
#else
#ifdef Q_OS_IOS
    return QDir::homePath() + "/camera/";
#else
    return QDir::homePath() + "/Pictures/Camera";
#endif
#endif
}

QString AsemanApplication::applicationDirPath()
{
    return QCoreApplication::applicationDirPath();
}

QString AsemanApplication::applicationFilePath()
{
    return QCoreApplication::applicationFilePath();
}

qint64 AsemanApplication::applicationPid()
{
    return QCoreApplication::applicationPid();
}

void AsemanApplication::setOrganizationDomain(const QString &orgDomain)
{
    QCoreApplication::setOrganizationDomain(orgDomain);
}

QString AsemanApplication::organizationDomain()
{
    return QCoreApplication::organizationDomain();
}

void AsemanApplication::setOrganizationName(const QString &orgName)
{
    QCoreApplication::setOrganizationName(orgName);
}

QString AsemanApplication::organizationName()
{
    return QCoreApplication::organizationName();
}

void AsemanApplication::setApplicationName(const QString &application)
{
    QCoreApplication::setApplicationName(application);
}

QString AsemanApplication::applicationName()
{
    return QCoreApplication::applicationName();
}

void AsemanApplication::setApplicationVersion(const QString &version)
{
    QCoreApplication::setApplicationVersion(version);
}

QString AsemanApplication::applicationVersion()
{
    return QCoreApplication::applicationVersion();
}

void AsemanApplication::setApplicationDisplayName(const QString &name)
{
#ifdef QT_GUI_LIB
    if(aseman_app_singleton->p->appType == GuiApplication)
        static_cast<QGuiApplication*>(QCoreApplication::instance())->setApplicationDisplayName(name);
#else
    Q_UNUSED(name)
#endif
}

QString AsemanApplication::applicationDisplayName()
{
#ifdef QT_GUI_LIB
    if(aseman_app_singleton->p->appType == GuiApplication)
        return static_cast<QGuiApplication*>(QCoreApplication::instance())->applicationDisplayName();
#endif

    return QString();
}

QString AsemanApplication::platformName()
{
#ifdef QT_GUI_LIB
    if(aseman_app_singleton->p->appType == GuiApplication)
        return static_cast<QGuiApplication*>(QCoreApplication::instance())->platformName();
#endif

    return QString();
}

QStringList AsemanApplication::arguments()
{
    return QCoreApplication::arguments();
}

void AsemanApplication::setQuitOnLastWindowClosed(bool quit)
{
#ifdef QT_GUI_LIB
    if(aseman_app_singleton->p->appType == GuiApplication)
        static_cast<QGuiApplication*>(QCoreApplication::instance())->setQuitOnLastWindowClosed(quit);
#else
    Q_UNUSED(name)
#endif
}

bool AsemanApplication::quitOnLastWindowClosed()
{
#ifdef QT_GUI_LIB
    if(aseman_app_singleton->p->appType == GuiApplication)
        return static_cast<QGuiApplication*>(QCoreApplication::instance())->quitOnLastWindowClosed();
#endif

    return false;
}

QClipboard *AsemanApplication::clipboard()
{
#ifdef QT_GUI_LIB
    if(aseman_app_singleton->p->appType == GuiApplication)
        return QGuiApplication::clipboard();
#endif

    return 0;
}

#ifdef QT_GUI_LIB
void AsemanApplication::setWindowIcon(const QIcon &icon)
{
    if(aseman_app_singleton->p->appType == GuiApplication)
        static_cast<QGuiApplication*>(QCoreApplication::instance())->setWindowIcon(icon);
}

QIcon AsemanApplication::windowIcon()
{
    if(aseman_app_singleton->p->appType == GuiApplication)
        return static_cast<QGuiApplication*>(QCoreApplication::instance())->windowIcon();

    return QIcon();
}
#endif

bool AsemanApplication::isRunning() const
{
    if(aseman_app_singleton->p->appType == WidgetApplication)
        return static_cast<QtSingleApplication*>(QCoreApplication::instance())->isRunning();

    return false;
}

void AsemanApplication::sendMessage(const QString &msg)
{
    if(aseman_app_singleton->p->appType == GuiApplication)
        static_cast<QtSingleApplication*>(QCoreApplication::instance())->sendMessage(msg);
}

AsemanApplication *AsemanApplication::instance()
{
    return aseman_app_singleton;
}

QCoreApplication *AsemanApplication::qapp()
{
    return QCoreApplication::instance();
}

void AsemanApplication::setGlobalFont(const QFont &font)
{
    if(p->globalFont == font)
        return;

    p->globalFont = font;
    emit globalFontChanged();
}

QFont AsemanApplication::globalFont() const
{
    return p->globalFont;
}

QSettings *AsemanApplication::settings()
{
    if( !app_global_settings )
    {
        QDir().mkpath(AsemanApplication::homePath());
        app_global_settings = new QSettings( AsemanApplication::homePath() + "/config.ini", QSettings::IniFormat );
    }

    return app_global_settings;
}

void AsemanApplication::refreshTranslations()
{
    emit languageUpdated();
}

void AsemanApplication::back()
{
    emit backRequest();
}

int AsemanApplication::exec()
{
    return p->app->exec();
}

void AsemanApplication::exit(int retcode)
{
    aseman_app_singleton->p->app->exit(retcode);
}

void AsemanApplication::sleep(quint64 ms)
{
    QThread::msleep(ms);
}

void AsemanApplication::setSetting(const QString &key, const QVariant &value)
{
    settings()->setValue(key, value);
}

QVariant AsemanApplication::readSetting(const QString &key, const QVariant &defaultValue)
{
    return settings()->value(key, defaultValue);
}

bool AsemanApplication::event(QEvent *e)
{
#ifdef Q_OS_MAC
    switch(e->type())
    {
    case QEvent::ApplicationActivate:
        clickedOnDock();
        break;

    default:
        break;
    }
#endif

    return QObject::event(e);
}

AsemanApplication::~AsemanApplication()
{
    if(aseman_app_singleton == this)
        aseman_app_singleton = 0;

    delete p;
}
