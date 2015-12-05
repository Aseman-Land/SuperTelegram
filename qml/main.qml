import QtQuick 2.4
import QtQuick.Controls 1.3
import AsemanTools 1.0
import AsemanTools.Controls 1.0
import TelegramQmlLib 1.0
import SuperTelegram 1.0

AsemanMain {
    id: main
    width: 480
    height: 640
    visible: true
    color: "#CC5633"

    property alias stg: s_tg
    property alias telegram: tg

    property LoginScreen loginScreen
    property TelegramMain superTelegram

    property color backButtonColor: "#ffffff"

    SuperTelegram {
        id: s_tg
        view: View
        onCurrentLanguageChanged: if(currentLanguage == "Persian") AsemanApp.globalFont.family = "IranSans"
        onLanguageDirectionChanged: View.layoutDirection = languageDirection
        Component.onDestruction: startService()
        Component.onCompleted: {
            AsemanApp.globalFont.family = "IranSans"
            View.layoutDirection = languageDirection
            stopService()
        }
    }

    HostChecker {
        id: hostChecker
        host: stg.defaultHostAddress
        port: stg.defaultHostPort
        interval: 5000
    }

    StgService {
        id: service
    }

    Telegram {
        id: tg
        defaultHostAddress: stg.defaultHostAddress
        defaultHostDcId: stg.defaultHostDcId
        defaultHostPort: stg.defaultHostPort
        appId: stg.appId
        appHash: stg.appHash
        configPath: AsemanApp.homePath
        publicKeyFile: s_tg.publicKey
        autoCleanUpMessages: true
        autoRewakeInterval: 30*60*1000
        onAuthLoggedInChanged: {
            if(authLoggedIn) {
                stg.phoneNumber = phoneNumber
            }

            main.refresh()
        }
        onAuthCodeRequested: {
            if(loginScreen)
                return

            stg.phoneNumber = ""
            main.refresh()
            loginScreen.moveToCode(phoneNumber)
        }
        onTelegramChanged: if(telegram) service.start(telegram, stg, hostChecker)
    }

    Component {
        id: login_component
        LoginScreen {
            anchors.fill: parent
        }
    }

    Component {
        id: tgmain_component
        TelegramMain {
            anchors.fill: parent
            onColorChanged: main.color = color
        }
    }

    function refresh() {
        var phoneNumber = stg.phoneNumber
        if(phoneNumber == null || phoneNumber == "") {
            if(loginScreen)
                return
            if(superTelegram)
                superTelegram.destroy()

            loginScreen = login_component.createObject(main)
        } else {
            if(superTelegram)
                return
            if(loginScreen)
                loginScreen.destroy()

            tg.phoneNumber = phoneNumber
            superTelegram = tgmain_component.createObject(main)
        }
    }

    Component.onCompleted: {
        refresh()
    }
}
