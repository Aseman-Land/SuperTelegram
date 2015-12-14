import QtQuick 2.0
import AsemanTools 1.0

Rectangle {
    width: 100
    height: 62

    Rectangle {
        id: title_bar
        width: parent.width
        height: Devices.standardTitleBarHeight + View.statusBarHeight
        color: "#FF8112"

        Text {
            id: title_txt
            width: parent.width - height - 6*Devices.density
            height: Devices.standardTitleBarHeight
            y: View.statusBarHeight
            x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width
            verticalAlignment: Text.AlignVCenter
            color: "#ffffff"
            font.family: AsemanApp.globalFont.family
            font.pixelSize: 14*fontRatio*Devices.fontDensity
            text: qsTr("Store")
        }
    }

    Rectangle {
        height: 4*Devices.density
        width: parent.width
        anchors.top: title_bar.bottom
        z: 10
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#33000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }
}

