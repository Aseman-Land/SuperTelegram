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

    property alias stg: s_tg
    property alias telegram: tg

    property real standardTitleBarHeight: Devices.standardTitleBarHeight*1.2

    SuperTelegram {
        id: s_tg
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

    Component.onCompleted: {
//        if(anything)
            login_component.createObject(main)
    }
}
