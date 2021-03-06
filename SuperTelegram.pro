TEMPLATE = app
CONFIG += debug_and_release
QT += qml quick sql positioning

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
} else {
    QT += widgets
}

DEFINES += QT_MESSAGELOGCONTEXT LQTG_DISABLE_ASSERTS

server.source = tg-server.pub
server.target = $${DESTDIR}
translationFiles.source = translations
translationFiles.target = files
fonts.source = fonts
fonts.target = .
emojis.source = emojis
emojis.target = $${DESTDIR}
DEPLOYMENTFOLDERS = server translationFiles fonts emojis

include(asemantools/asemantools.pri)
include(qmake/qtcAddDeployment.pri)
qtcAddDeployment()

include(telegram/telegram.pri)

android {
    contains(STORE,google) {
#        DEFINES += STG_STORE_GOOGLE
        DEFINES += STG_STORE_DISABLED
        message(Google store is not supported currently. Faledback to disable mod.)
    } else: contains(STORE,bazaar) {
        DEFINES += STG_STORE_BAZAAR
    } else: {
        DEFINES += STG_STORE_DISABLED
    }
} else {
    DEFINES += STG_STORE_DISABLED
}

!isEmpty(STICKER_BANK): {
    DEFINES += STICKER_BANK_URL=\\\"$$STICKER_BANK\\\"
}

SOURCES += main.cpp \
    supertelegram.cpp \
    supertelegramservice.cpp \
    commandsdatabase.cpp \
    timermessagemodel.cpp \
    automessagemodel.cpp \
    sensmessagemodel.cpp \
    backupmanager.cpp \
    profilepicswitchermodel.cpp \
    servicedatabase.cpp \
    abstractstgaction.cpp \
    stgactiongetgeo.cpp \
    stgactioncaptureimage.cpp \
    emojis.cpp \
    stgstoremanagercore.cpp \
    apilayer.cpp

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
    servicedatabase.h \
    abstractstgaction.h \
    stgactiongetgeo.h \
    stgactioncaptureimage.h \
    emojis.h \
    stgstoremanagercore.h \
    apilayer.h

DISTFILES += \
    android/AndroidManifest.xml \
    android/src/j7zip/Common/BoolVector.java \
    android/src/j7zip/Common/ByteBuffer.java \
    android/src/j7zip/Common/CRC.java \
    android/src/j7zip/Common/IntVector.java \
    android/src/j7zip/Common/LimitedSequentialInStream.java \
    android/src/j7zip/Common/LockedInStream.java \
    android/src/j7zip/Common/LockedSequentialInStreamImp.java \
    android/src/j7zip/Common/LongVector.java \
    android/src/j7zip/Common/ObjectVector.java \
    android/src/j7zip/Common/RecordVector.java
