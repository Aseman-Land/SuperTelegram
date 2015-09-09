#define ABOUT_TEXT ""
#define INITIALIZE_APP(APP_OBJ) \
    APP_OBJ.setApplicationName("SuperTelegram"); \
    APP_OBJ.setApplicationVersion("1.0.0"); \
    APP_OBJ.setOrganizationDomain("land.aseman"); \
    APP_OBJ.setOrganizationName("Aseman"); \

#include "asemantools/asemanapplication.h"
#include "asemantools/asemanquickview.h"
#include "telegramqmlinitializer.h"
#include "supertelegram.h"
#include "supertelegramservice.h"
#include "supertelegram_macro.h"
#include "commandsdatabase.h"

#include "sensmessagemodel.h"
#include "automessagemodel.h"
#include "timermessagemodel.h"
#include "backupmanager.h"

#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QtQml>

extern "C" int mainService(int argc, char *argv[])
{
    if(AsemanApplication::instance())
    {
        SuperTelegramService service;
        service.start();

        return AsemanApplication::instance()->exec();
    }

    AsemanApplication app(argc, argv, AsemanApplication::CoreApplication);
    INITIALIZE_APP(app);

    SuperTelegramService service;
    service.start();

    return app.exec();
}

int main(int argc, char *argv[])
{
    TelegramQmlInitializer::init("TelegramQmlLib");

    qmlRegisterType<SuperTelegram>(QML_URI, 1, 0, "SuperTelegram");
    qmlRegisterType<CommandsDatabase>(QML_URI, 1, 0, "CommandsDatabase");

    qmlRegisterType<TimerMessageModel>(QML_URI, 1, 0, "TimerMessageModel");
    qmlRegisterType<AutoMessageModel>(QML_URI, 1, 0, "AutoMessageModel");
    qmlRegisterType<SensMessageModel>(QML_URI, 1, 0, "SensMessageModel");
    qmlRegisterType<BackupManager>(QML_URI, 1, 0, "BackupManager");

    AsemanApplication app(argc, argv);
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

    if(!parser.isSet(verboseOption))
        qputenv("QT_LOGGING_RULES", "tg.*=false");
    else
        qputenv("QT_LOGGING_RULES", "tg.core.settings=false\n"
                                    "tg.core.outboundpkt=false\n"
                                    "tg.core.inboundpkt=false");

    AsemanQuickView view;
    view.setBackController(true);
//    view.setLayoutDirection(Qt::RightToLeft);
    view.setSource(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    view.show();

    return app.exec();
}
