#define ABOUT_TEXT ""

#include "asemantools/asemanapplication.h"
#include "asemantools/asemanquickview.h"
#include "telegramqmlinitializer.h"
#include "supertelegram.h"

#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QtQml>

int main(int argc, char *argv[])
{
    TelegramQmlInitializer::init("TelegramQml");
    qmlRegisterType<SuperTelegram>("SuperTelegram", 1, 0, "SuperTelegram");

    AsemanApplication app(argc, argv);
    app.setApplicationName("SuperTelegram");
    app.setApplicationDisplayName("Super Telegram");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationDomain("land.aseman");
    app.setOrganizationName("Aseman");

    QCommandLineOption verboseOption(QStringList() << "V" << "verbose",
            QCoreApplication::translate("main", "Verbose Mode."));

    QCommandLineParser parser;
    parser.setApplicationDescription(ABOUT_TEXT);
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addOption(verboseOption);
    parser.process(app);

//    if(!parser.isSet(verboseOption))
//        qputenv("QT_LOGGING_RULES", "tg.*=false");
//    else
//        qputenv("QT_LOGGING_RULES", "tg.core.settings=false\n"
//                                    "tg.core.outboundpkt=false\n"
//                                    "tg.core.inboundpkt=false");

    AsemanQuickView view(AsemanQuickView::AllExceptLogger);
    view.setBackController(true);
//    view.setLayoutDirection(Qt::RightToLeft);
    view.setSource(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    view.show();

    return app.exec();
}
