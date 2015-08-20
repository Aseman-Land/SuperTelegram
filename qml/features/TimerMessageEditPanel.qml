import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0
import AsemanTools.Controls.Styles 1.0
import SuperTelegram 1.0
import TelegramQml 1.0
import "../"

Item {
    id: edit_panel
    width: 100
    height: 62

    Button {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10*Devices.density
        height: 42*Devices.density
        text: qsTr("Add")
        style: ButtonStyle {
            fontPixelSize: 10*Devices.fontDensity
            buttonColor: "#0d80ec"
        }
    }
}

