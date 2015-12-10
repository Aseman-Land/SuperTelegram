#define ABOUT_TEXT ""
#define INITIALIZE_APP(APP_OBJ) \
    APP_OBJ.setApplicationName("SuperTelegram"); \
    APP_OBJ.setApplicationVersion("1.0.0"); \
    APP_OBJ.setOrganizationDomain("land.aseman"); \
    APP_OBJ.setOrganizationName("Aseman"); \

#include "asemantools/asemanapplication.h"
#include "asemantools/asemanquickview.h"
#include "asemantools/asemanqtlogger.h"
#include "asemantools/private/asemanandroidstoremangercore.h"

#include "supertelegram.h"
#include "supertelegramservice.h"
#include "supertelegram_macro.h"
#include "commandsdatabase.h"
#include "stghbclient.h"
#include "telegram/libqtelegram/telegram.h"

#include "sensmessagemodel.h"
#include "automessagemodel.h"
#include "timermessagemodel.h"
#include "backupmanager.h"
#include "profilepicswitchermodel.h"

#include <telegramqmlinitializer.h>

#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QtQml>
#include <QFile>
#include <QStringList>

extern "C" int mainService(int argc, char *argv[])
{
#ifdef Q_OS_ANDROID
    new AsemanQtLogger("/sdcard/stg.log");
#endif

    if(AsemanApplication::instance())
    {
        SuperTelegramService service;
        service.start();

        return AsemanApplication::instance()->exec();
    }
    else
    {
        AsemanApplication app(argc, argv, AsemanApplication::CoreApplication);
        INITIALIZE_APP(app);

        SuperTelegramService service;
        service.start();

        return app.exec();
    }
}

int main(int argc, char *argv[])
{
    AsemanApplication app(argc, argv);

    app.setWindowIcon(QIcon(":/qml/img/stg.png"));
    app.setApplicationAbout(AsemanApplication::tr("It's super telegram application, contains many advance tools, works under the telegram."));
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

    AsemanAndroidStoreMangerCore storeManager;
    storeManager.setup("MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwCapdy2RlWlw7g5/s0Iw/pSCYNCVnmqvfPTNTNL1VifE5250K4E4zj34JlinmHuzUSSUWVI3InHboBl1UFDb5bJIKX8O/whfXHTVbiXmICJRrAcHKRE3UM6XCgbIMZRUS72GS6VKYNrcKLiajVNMN2E889+XtcEUqpiCMOKsFoNg5iUFewFScKCNxVtai9TpifGhY7Rm7EyW7yKrT2plUBy7IXSW3FEaoD3R8e75k0CAwEAAQ==",
                       "com.farsitel.bazaar", "ir.cafebazaar.pardakht.InAppBillingService.BIND");

    if(parser.isSet(serviceOption))
        return mainService(argc, argv);
    else
    {
        TelegramQmlInitializer::init("TelegramQmlLib");

        qRegisterMetaType<Telegram*>("Telegram*");

        qmlRegisterType<SuperTelegram>(QML_URI, 1, 0, "SuperTelegram");
        qmlRegisterType<CommandsDatabase>(QML_URI, 1, 0, "CommandsDatabase");
        qmlRegisterType<StgHBClient>(QML_URI, 1, 0, "StgHBClient");
        qmlRegisterType<SuperTelegramService>(QML_URI, 1, 0, "StgService");

        qmlRegisterType<TimerMessageModel>(QML_URI, 1, 0, "TimerMessageModel");
        qmlRegisterType<AutoMessageModel>(QML_URI, 1, 0, "AutoMessageModel");
        qmlRegisterType<SensMessageModel>(QML_URI, 1, 0, "SensMessageModel");
        qmlRegisterType<BackupManager>(QML_URI, 1, 0, "BackupManager");
        qmlRegisterType<ProfilePicSwitcherModel>(QML_URI, 1, 0, "ProfilePicSwitcherModel");

        if(!parser.isSet(verboseOption))
            qputenv("QT_LOGGING_RULES", "tg.*=false");
        else
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
