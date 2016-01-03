import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0

Item {
    id: core_object

    property alias stg: s_tg
    property alias telegram: tg
    property alias service: stgService
    property alias hostChecker: host_checker

    property ClassicLoginScreen loginScreen
    property TelegramMain superTelegram

    NetworkSleepManager {
        id: host_checker
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
        id: stgService
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
                if(loginScreen)
                    loginScreen.finish()
            }

            refresh()
        }
        onAuthCodeRequested: {
            if(!loginScreen) {
                s_tg.phoneNumber = ""
                refresh()
            }

            loginScreen.moveToCode(phoneNumber)
        }
        onAuthLoggedOut: {
            s_tg.phoneNumber = ""
            View.tryClose()
//            Tools.jsDelayCall(100, main.restart)
        }
        onTelegramChanged: if(telegram) service.start(telegram, s_tg, hostChecker, store)
        onDatabaseChanged: if(database) database.readFullDialogs()
    }

    function refresh() {
        var phoneNumber = s_tg.phoneNumber
        if(phoneNumber == null || phoneNumber == "") {
            if(loginScreen)
                return
            if(superTelegram)
                superTelegram.destroy()

            var login_component = login_component_path.createLocalComponent()
            loginScreen = login_component.createObject(main)
            loginScreen.anchors.fill = main
        } else {
            if(superTelegram)
                return
            if(loginScreen)
                loginScreen.destroy()

            tg.phoneNumber = phoneNumber
            var component = tgmain_component.createLocalComponent()
            superTelegram = component.createObject(main)
        }
    }

    SmartComponent {
        id: login_component_path
        source: "ClassicLoginScreen.qml"
    }

    SmartComponent {
        id: tgmain_component
        source: "TelegramMain.qml"
    }

    Component {
        id: font_loader_component
        FontLoader {
            source: Devices.resourcePath + "/fonts/" + fontName + ".ttf"
            property string fontName
        }
    }

    Component {
        id: activity_connections_component
        Connections {
            target: JavaLayer
            onActivityStopped: {
                service.sleep()
                s_tg.startService()
                console.debug("Activity Stopped")
            }
            onActivityStarted: {
                s_tg.stopService()
                service.wake()
                console.debug("Activity Started")
            }
        }
    }

    Component.onCompleted: {
        if(Devices.isAndroid)
            activity_connections_component.createObject(core_object)
    }
}

