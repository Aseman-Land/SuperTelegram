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

    property alias stg: stg_core.stg
    property alias telegram: stg_core.telegram
    property alias core: stg_core
    property alias storeManager: str_mgr
    property alias emojis: emjs

    property color backButtonColor: "#ffffff"
    property bool fontsLoaded: false

    property real fontRatio: 1

    StoreManager {
        id: str_mgr
        publicKey: "MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwCapdy2RlWlw7g5/s0Iw/pSCYNCVnmqvfPTNTNL1VifE5250K4E4zj34JlinmHuzUSSUWVI3InHboBl1UFDb5bJIKX8O/whfXHTVbiXmICJRrAcHKRE3UM6XCgbIMZRUS72GS6VKYNrcKLiajVNMN2E889+XtcEUqpiCMOKsFoNg5iUFewFScKCNxVtai9TpifGhY7Rm7EyW7yKrT2plUBy7IXSW3FEaoD3R8e75k0CAwEAAQ=="
        packageName: "com.farsitel.bazaar"
        bindIntent: "ir.cafebazaar.pardakht.InAppBillingService.BIND"
        cacheSource: AsemanApp.homePath + "/store.cache"

        property int meikade_donate_1000

        property bool isPremiumNumber: stg && telegram? stg.checkPremiumNumber(telegram.phoneNumber) : false
        property bool is30DayTrialNumber: stg && telegram? stg.check30DayTrialNumber(telegram.phoneNumber) : false

        Component.onCompleted: setup()
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
}
