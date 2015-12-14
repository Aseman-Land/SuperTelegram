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
    property alias storeManager: str_mgr
    property alias emojis: emjs

    property LoginScreen loginScreen
    property TelegramMain superTelegram

    property color backButtonColor: "#ffffff"
    property bool fontsLoaded: false

    property real fontRatio: 1

    SuperTelegram {
        id: s_tg
        view: View
        onLanguageDirectionChanged: View.layoutDirection = languageDirection
        onCurrentLanguageChanged: refreshFont()
        Component.onDestruction: startService()
        Component.onCompleted: {
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
    }

    NetworkSleepManager {
        id: hostChecker
        host: stg.defaultHostAddress
        port: stg.defaultHostPort
        interval: 5000
    }

    StoreManager {
        id: str_mgr
        publicKey: "MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwCapdy2RlWlw7g5/s0Iw/pSCYNCVnmqvfPTNTNL1VifE5250K4E4zj34JlinmHuzUSSUWVI3InHboBl1UFDb5bJIKX8O/whfXHTVbiXmICJRrAcHKRE3UM6XCgbIMZRUS72GS6VKYNrcKLiajVNMN2E889+XtcEUqpiCMOKsFoNg5iUFewFScKCNxVtai9TpifGhY7Rm7EyW7yKrT2plUBy7IXSW3FEaoD3R8e75k0CAwEAAQ=="
        packageName: "com.farsitel.bazaar"
        bindIntent: "ir.cafebazaar.pardakht.InAppBillingService.BIND"
        cacheSource: AsemanApp.homePath + "/store.cache"

        property int meikade_donate_1000

        property bool isPremiumNumber: stg.checkPremiumNumber(tg.phoneNumber)
        property bool is30DayTrialNumber: stg.check30DayTrialNumber(tg.phoneNumber)

        Component.onCompleted: setup()
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
        onAuthLoggedOut: {
            stg.phoneNumber = ""
            View.tryClose()
        }
    }

    Emojis {
        id: emjs
        currentTheme: "twitter"
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

    function loadFonts() {
        if(fontsLoaded)
            return

        var fonts = stg.availableFonts()
        for(var i=0; i<fonts.length; i++)
            font_loader_component.createObject(main, {"fontName": fonts[i]})

        fontsLoaded = true
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
        loadFonts()
        refresh()
    }
}
