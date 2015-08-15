import QtQuick 2.4
import QtQuick.Controls 1.3
import AsemanTools 1.0
import AsemanTools.Controls 1.0
import TelegramQml 1.0
import SuperTelegram 1.0

AsemanMain {
    id: main
    width: 480
    height: 640
    visible: true
    color: "#CC5633"

    property alias stg: s_tg
    property alias telegram: tg

    property variant loginScreen
    property variant superTelegram

    property real standardTitleBarHeight: Devices.standardTitleBarHeight*1.2

    SuperTelegram {
        id: s_tg
        view: View
    }

    Telegram {
        id: tg
        defaultHostAddress: stg.defaultHostAddress
        defaultHostDcId: stg.defaultHostDcId
        defaultHostPort: stg.defaultHostPort
        appId: stg.appId
        appHash: stg.appHash
        configPath: AsemanApp.homePath
        publicKeyFile: Devices.resourcePath + "/tg-server.pub"
        autoCleanUpMessages: true
        onAuthLoggedInChanged: {
            if(authLoggedIn) {
                stg.phoneNumber = phoneNumber
                stg.startService()
            }

            main.refresh()
        }
        onAuthCodeRequested: {
            if(loginScreen)
                return

            stg.phoneNumber = null
            main.refresh()
            loginScreen.moveToCode(phoneNumber)
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

    function refresh() {
        var phoneNumber = stg.phoneNumber
        if(phoneNumber == null) {
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

    Component.onCompleted: refresh()
}
