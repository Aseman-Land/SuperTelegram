TEMPLATE = app
QT += qml quick sql positioning

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
} else {
    QT += widgets
}

server.source = tg-server.pub
server.target = $${DESTDIR}
translationFiles.source = translations
translationFiles.target = files
DEPLOYMENTFOLDERS = server translationFiles

include(asemantools/asemantools.pri)
include(qmake/qtcAddDeployment.pri)
qtcAddDeployment()

include(telegram/telegram.pri)
include(hyperbus/hyperbus.pri)
include(qbazaarbilling/qbazaarbilling.pri)

SOURCES += main.cpp \
    supertelegram.cpp \
    supertelegramservice.cpp \
    commandsdatabase.cpp \
    timermessagemodel.cpp \
    automessagemodel.cpp \
    sensmessagemodel.cpp \
    backupmanager.cpp \
    profilepicswitchermodel.cpp \
    stghbserver.cpp \
    stghbclient.cpp \
    servicedatabase.cpp
RESOURCES += \
    resource.qrc

HEADERS += \
    supertelegram.h \
    supertelegramservice.h \
    commandsdatabase.h \
    timermessagemodel.h \
    supertelegram_macro.h \
    automessagemodel.h \
    sensmessagemodel.h \
    backupmanager.h \
    profilepicswitchermodel.h \
    stghbserver.h \
    stghbclient.h \
    servicedatabase.h

DISTFILES += \
    android/AndroidManifest.xml
