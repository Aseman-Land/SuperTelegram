import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0

Rectangle {
    id: about
    color: "#fcfcfc"

    Text {
        id: title_txt
        width: parent.width - height - 6*Devices.density
        height: Devices.standardTitleBarHeight
        y: View.statusBarHeight
        x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width
        verticalAlignment: Text.AlignVCenter
        color: "#333333"
        font.family: AsemanApp.globalFont.family
        font.pixelSize: 14*Devices.fontDensity
        text: qsTr("Donate")
    }

    AsemanFlickable {
        id: flickable
        width: parent.width
        anchors.top: title_txt.bottom
        anchors.bottom: parent.bottom
        flickableDirection: Flickable.VerticalFlick
        clip: true

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10*Devices.density

            Item { width: 1; height: 20*Devices.density }
        }
    }

    Rectangle {
        height: 4*Devices.density
        width: parent.width
        anchors.top: flickable.top
        z: 10
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#33000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    Component.onCompleted: backButtonColor = "#333333"
    Component.onDestruction: backButtonColor = "#ffffff"
}

