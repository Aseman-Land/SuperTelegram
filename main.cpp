#define ABOUT_TEXT ""
#define INITIALIZE_APP(APP_OBJ) \
    APP_OBJ.setApplicationName("SuperTelegram"); \
    APP_OBJ.setApplicationVersion("1.0.0"); \
    APP_OBJ.setOrganizationDomain("land.aseman"); \
    APP_OBJ.setOrganizationName("Aseman"); \

#include "asemantools/asemanapplication.h"
#include "asemantools/asemanquickview.h"
#include "asemantools/asemanqtlogger.h"

#include "supertelegram.h"
#include "supertelegramservice.h"
#include "supertelegram_macro.h"
#include "commandsdatabase.h"
#include "emojis.h"
#include "telegram/libqtelegram/telegram.h"

#include "sensmessagemodel.h"
#include "automessagemodel.h"
#include "timermessagemodel.h"
#include "backupmanager.h"
#include "profilepicswitchermodel.h"
#include "stgstoremanagercore.h"

#include <telegramqmlinitializer.h>

#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QtQml>
#include <QFile>
#include <QStringList>

extern "C" int mainService(int argc, char *argv[])
{
#if defined(Q_OS_ANDROID) && defined(TEST_BUILD)
    AsemanQtLogger logger("/sdcard/stg.log");
    Q_UNUSED(logger)
#endif

    qDebug() << "Service started";
    qputenv("QT_LOGGING_RULES", "tg.core.settings=false\n"
                                "tg.core.outboundpkt=false\n"
                                "tg.core.inboundpkt=false");

    int result = 0;
    if(AsemanApplication::instance())
    {
        SuperTelegramService service;
        service.start();

        result = AsemanApplication::instance()->exec();
    }
    else
    {
        AsemanApplication app(argc, argv, AsemanApplication::CoreApplication);
        INITIALIZE_APP(app);

        SuperTelegramService service;
        service.start();

        result = app.exec();
    }

    qDebug() << "Service closed";
    return result;
}

int main(int argc, char *argv[])
{
    AsemanApplication app(argc, argv);

    app.setWindowIcon(QIcon(":/qml/img/stg.png"));
    app.setApplicationAbout(AsemanApplication::tr("SuperTelegram is a set of tools for Telegram messaging service by NileGroup.<br /><br />"
                                                  "It's based on the Aseman's Telegram developer tools and created using C++/Qt and Qml technologies.<br /><br />"
                                                  "SuperTelegram is a cross-platform application. It's Free and OpenSource and released under the GPLv3 license.<br /><br />"
                                                  "<b>Developer Team:</b><br /> - Bardia Daneshvar<br /> - AmirHossein Mousavi<br />"));
    app.setApplicationDisplayName("Super Telegram");
    INITIALIZE_APP(app);

    QCommandLineOption verboseOption(QStringList() << "V" << "verbose",
            QCoreApplication::translate("main", "Verbose mode."));
    QCommandLineOption serviceOption(QStringList() << "s" << "service",
            QCoreApplication::translate("main", "Run is service mode."));

    QCommandLineParser parser;
    parser.setApplicationDescription(ABOUT_TEXT);
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addOption(serviceOption);
    parser.addOption(verboseOption);
    parser.process(app.arguments());

    if(parser.isSet(serviceOption))
        return mainService(argc, argv);
    else
    {
        TelegramQmlInitializer::init("TelegramQmlLib");

        qRegisterMetaType<Telegram*>("Telegram*");

        qmlRegisterType<SuperTelegram>(QML_URI, 1, 0, "SuperTelegram");
        qmlRegisterType<CommandsDatabase>(QML_URI, 1, 0, "CommandsDatabase");
        qmlRegisterType<SuperTelegramService>(QML_URI, 1, 0, "StgService");
        qmlRegisterType<StgStoreManagerCore>(QML_URI, 1, 0, "StgStoreManagerCore");
        qmlRegisterType<Emojis>(QML_URI, 1, 0, "Emojis");

        qmlRegisterType<TimerMessageModel>(QML_URI, 1, 0, "TimerMessageModel");
        qmlRegisterType<AutoMessageModel>(QML_URI, 1, 0, "AutoMessageModel");
        qmlRegisterType<SensMessageModel>(QML_URI, 1, 0, "SensMessageModel");
        qmlRegisterType<BackupManager>(QML_URI, 1, 0, "BackupManager");
        qmlRegisterType<ProfilePicSwitcherModel>(QML_URI, 1, 0, "ProfilePicSwitcherModel");

#ifndef QT_DEBUG
        if(!parser.isSet(verboseOption))
            qputenv("QT_LOGGING_RULES", "tg.*=false");
        else
#endif
            qputenv("QT_LOGGING_RULES", "tg.core.settings=false\n"
                                        "tg.core.outboundpkt=false\n"
                                        "tg.core.inboundpkt=false");

        AsemanQuickView view;
        view.setBackController(true);
//        view.setLayoutDirection(Qt::RightToLeft);
        view.setSource(QUrl(QStringLiteral("qrc:/qml/main.qml")));
        view.show();

        return app.exec();
    }
}
