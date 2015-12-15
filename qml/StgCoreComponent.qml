import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0

Item {
    id: core_object

    property alias stg: s_tg
    property alias telegram: tg

    property LoginScreen loginScreen
    property TelegramMain superTelegram

    NetworkSleepManager {
        id: hostChecker
        host: s_tg.defaultHostAddress
        port: s_tg.defaultHostPort
        interval: 5000
    }

    SuperTelegram {
        id: s_tg
        view: View
        onLanguageDirectionChanged: View.layoutDirection = languageDirection
        onCurrentLanguageChanged: refreshFont()
        Component.onDestruction: startService()
        Component.onCompleted: {
            loadFonts()
            refreshFont()
            stopService()
        }

        function refreshFont() {
            if(currentLanguage == "Persian") {
                AsemanApp.globalFont.family = "Iran-Sans"
                View.layoutDirection = languageDirection
                fontRatio = 0.86
            } else {
                AsemanApp.globalFont.family = "Droid Sans"
                View.layoutDirection = languageDirection
                fontRatio = 1
            }
        }

        function loadFonts() {
            if(fontsLoaded)
                return

            var fonts = s_tg.availableFonts()
            for(var i=0; i<fonts.length; i++)
                font_loader_component.createObject(main, {"fontName": fonts[i]})

            fontsLoaded = true
        }
    }

    StgService {
        id: service
    }

    Telegram {
        id: tg
        defaultHostAddress: s_tg.defaultHostAddress
        defaultHostDcId: s_tg.defaultHostDcId
        defaultHostPort: s_tg.defaultHostPort
        appId: s_tg.appId
        appHash: s_tg.appHash
        configPath: AsemanApp.homePath
        publicKeyFile: s_tg.publicKey
        autoCleanUpMessages: true
        autoRewakeInterval: 30*60*1000
        onAuthLoggedInChanged: {
            if(authLoggedIn) {
                s_tg.phoneNumber = phoneNumber
            }

            refresh()
        }
        onAuthCodeRequested: {
            if(loginScreen)
                return

            s_tg.phoneNumber = ""
            refresh()
            loginScreen.moveToCode(phoneNumber)
        }
        onTelegramChanged: if(telegram) service.start(telegram, s_tg, hostChecker)
        onAuthLoggedOut: {
            s_tg.phoneNumber = ""
            View.tryClose()
//            Tools.jsDelayCall(100, main.restart)
        }
    }

    function refresh() {
        var phoneNumber = s_tg.phoneNumber
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

    Component {
        id: font_loader_component
        FontLoader{
            source: Devices.resourcePath + "/fonts/" + fontName + ".ttf"
            property string fontName
        }
    }
}

