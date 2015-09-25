TEMPLATE = app
QT += qml quick sql

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
} else {
    QT += widgets
}

server.source = tg-server.pub
server.target = $${DESTDIR}
DEPLOYMENTFOLDERS = server

include(asemantools/asemantools.pri)
include(qmake/qtcAddDeployment.pri)
qtcAddDeployment()

isEmpty(OPENSSL_INCLUDE_PATH): OPENSSL_INCLUDE_PATH = /usr/include/openssl /usr/local/include/openssl
isEmpty(OPENSSL_LIB_DIR) {
    LIBS += -lssl -lcrypto -lz
} else {
    LIBS += -L$${OPENSSL_LIB_DIR} -lssl -lcrypto -lz
}

INCLUDEPATH += $${OPENSSL_INCLUDE_PATH} $${OPENSSL_INCLUDE_PATH}/openssl

include(telegram/telegram.pri)

SOURCES += main.cpp \
    supertelegram.cpp \
    supertelegramservice.cpp \
    commandsdatabase.cpp \
    timermessagemodel.cpp \
    automessagemodel.cpp \
    sensmessagemodel.cpp \
    backupmanager.cpp \
    profilepicswitchermodel.cpp
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
    profilepicswitchermodel.h

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = \
        $$OPENSSL_LIB_DIR/libcrypto.so \
        $$OPENSSL_LIB_DIR/libssl.so
}
