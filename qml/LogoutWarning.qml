import QtQuick 2.0
import AsemanTools 1.0

Column {
    id: column
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.right: parent.right

    Text {
        width: main.width - 40*Devices.density
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 10*Devices.density
        font.family: AsemanApp.globalFont.family
        font.pixelSize: 9*fontRatio*Devices.fontDensity
        color: "#333333"
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: qsTr("<b>SuperTelegram</b><br /><br />" +
                   "Are you sure you want to log out?<br /><br />" +
                   "Note that you can seamlessly use Telegram on all your devices" +
                   "at once.")
    }

    Row {
        anchors.right: parent.right
        Button {
            textFont.family: AsemanApp.globalFont.family
            textFont.pixelSize: 10*fontRatio*Devices.fontDensity
            textColor: "#0d80ec"
            normalColor: "#00000000"
            highlightColor: "#660d80ec"
            text: qsTr("Cancel")
            onClicked: {
                AsemanApp.back()
            }
        }

        Button {
            textFont.family: AsemanApp.globalFont.family
            textFont.pixelSize: 10*fontRatio*Devices.fontDensity
            textColor: "#0d80ec"
            normalColor: "#00000000"
            highlightColor: "#660d80ec"
            text: qsTr("OK")
            onClicked: tg.authLogout()
        }
    }
}
