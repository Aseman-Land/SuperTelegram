TEMPLATE = app
QT += qml quick widgets sql

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
}

server.source = tg-server.pub
server.target = $${DESTDIR}
DEPLOYMENTFOLDERS = server

include(asemantools/asemantools.pri)
include(qmake/qtcAddDeployment.pri)
qtcAddDeployment()

isEmpty(OPENSSL_INCLUDE_PATH): OPENSSL_INCLUDE_PATH = /usr/include/openssl /usr/local/include/openssl
isEmpty(LIBQTELEGRAM_INCLUDE_PATH): LIBQTELEGRAM_INCLUDE_PATH = /usr/include/libqtelegram-ae /usr/local/include/libqtelegram-ae $$[QT_INSTALL_HEADERS]/libqtelegram-ae
isEmpty(TELEGRAMQML_INCLUDE_PATH): TELEGRAMQML_INCLUDE_PATH = /usr/include/telegramqml /usr/local/include/telegramqml $$[QT_INSTALL_HEADERS]/telegramqml
isEmpty(OPENSSL_LIB_DIR) {
    LIBS += -lssl -lcrypto -lz
} else {
    LIBS += -L$${OPENSSL_LIB_DIR} -lssl -lcrypto -lz
}
isEmpty(LIBQTELEGRAM_LIB_DIR) {
    LIBS += -lqtelegram-ae
} else {
    LIBS += -L$${LIBQTELEGRAM_LIB_DIR} -lqtelegram-ae
}
isEmpty(TELEGRAMQML_LIB_DIR) {
    LIBS += -ltelegramqml
} else {
    LIBS += -L$${TELEGRAMQML_LIB_DIR} -ltelegramqml
}

INCLUDEPATH += $${OPENSSL_INCLUDE_PATH} $${LIBQTELEGRAM_INCLUDE_PATH} $${TELEGRAMQML_INCLUDE_PATH}

SOURCES += main.cpp \
    supertelegram.cpp \
    supertelegramservice.cpp \
    commandsdatabase.cpp \
    timermessagemodel.cpp
RESOURCES += \
    resource.qrc

HEADERS += \
    supertelegram.h \
    supertelegramservice.h \
    commandsdatabase.h \
    timermessagemodel.h \
    supertelegram_macro.h
