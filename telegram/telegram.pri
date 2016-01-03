
LIBQTELEGRAM_INCLUDE_PATH = $$PWD/libqtelegram
INCLUDEPATH += $$PWD/telegramqml

include(libqtelegram/libqtelegram-ae.pri)

LIBS_TEMP = $$LIBS
include(telegramqml/telegramqml.pri)
LIBS = $$LIBS_TEMP
