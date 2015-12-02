#ifndef SUPERTELEGRAM_MACRO
#define SUPERTELEGRAM_MACRO

#define QML_URI "SuperTelegram"

#ifdef Q_OS_ANDROID
#define TRANSLATIONS_PATH QString("assets:/files/translations")
#else
#ifdef Q_OS_IOS
#define TRANSLATIONS_PATH QString(QCoreApplication::applicationDirPath() + "/files/translations/")
#else
#ifdef Q_OS_WIN
#define TRANSLATIONS_PATH QString(QCoreApplication::applicationDirPath() + "/files/translations/")
#else
#define TRANSLATIONS_PATH QString(QCoreApplication::applicationDirPath() + "/files/translations/")
#endif
#endif
#endif

#endif // SUPERTELEGRAM_MACRO

