import QtQuick 2.4
import QtQuick.Controls 1.3
import AsemanTools 1.0
import AsemanTools.Controls 1.0 as Controls
import TelegramQmlLib 1.0
import SuperTelegram 1.0

AsemanMain {
    id: main
    width: 480
    height: 640
    visible: true
    color: "#CC5633"

    property alias stg: stg_core.stg
    property alias telegram: stg_core.telegram
    property alias core: stg_core
    property alias store: str_mgr
    property alias emojis: emjs
    property alias service: stg_core.service
    property alias hostChecker: stg_core.hostChecker

    property color backButtonColor: "#ffffff"
    property bool fontsLoaded: false

    property real fontRatio: 1

    StgStoreManager {
        id: str_mgr
        stg: main.stg
        telegram: main.telegram

        onIsPremiumNumberChanged: {
            if(!isPremiumNumber)
                return

            var dialogShowed = AsemanApp.readSetting("General/premiumDialog", 0)
            if(dialogShowed != 0)
                return

            var component = congratulations_component.createLocalComponent()
            component.createObject(main)
            AsemanApp.setSetting("General/premiumDialog", 1)
        }
    }

    Emojis {
        id: emjs
        currentTheme: "twitter"
    }

    StgCoreComponent {
        id: stg_core
        anchors.fill: parent
        Component.onCompleted: refresh()
    }

    SmartComponent {
        id: congratulations_component
        source: "CongratulationsDialog.qml"
    }

    function showStore() {
        core.superTelegram.showStore()
    }
}
