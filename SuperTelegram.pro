TEMPLATE = app

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
}

QT += qml quick widgets

include(asemantools/asemantools.pri)

SOURCES += main.cpp

RESOURCES += qml.qrc
