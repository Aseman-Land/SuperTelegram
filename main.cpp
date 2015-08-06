#include "asemantools/asemanapplication.h"
#include "asemantools/asemanquickview.h"

int main(int argc, char *argv[])
{
    AsemanApplication app(argc, argv);
    app.setApplicationName("SuperTelegram");
    app.setApplicationDisplayName("Super Telegram");
    app.setApplicationVersion("2.5.0");
    app.setOrganizationDomain("land.aseman");
    app.setOrganizationName("Aseman");

    AsemanQuickView view(AsemanQuickView::AllExceptLogger);
    view.setSource(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    view.show();

    return app.exec();
}
