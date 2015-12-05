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
        text: qsTr("About Team")
    }

    AsemanFlickable {
        id: flickable
        width: parent.width
        anchors.top: title_txt.bottom
        anchors.bottom: home_btn.top
        anchors.bottomMargin: 4*Devices.density
        flickableDirection: Flickable.VerticalFlick
        contentHeight: column.height
        clip: true

        Column {
            id: column
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10*Devices.density

            Item { width: 1; height: 20*Devices.density }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: about.width/3
                height: width
                source: "img/nilegroup.png"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#333333"
                font.family: AsemanApp.globalFont.family
                font.pixelSize: 17*Devices.fontDensity
                text: qsTr("Nile Group")
            }

            Text {
                width: about.width - 40*Devices.density
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#333333"
                font.family: AsemanApp.globalFont.family
                font.pixelSize: 10*Devices.fontDensity
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: AsemanApp.applicationAbout
            }
        }
    }

    Button {
        id: home_btn
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10*Devices.density
        height: 36*Devices.density
        width: 150*Devices.density
        text: qsTr("Home Page")
        onClicked: Qt.openUrlExternally("http://nilegroup.org/")
    }

    Rectangle {
        height: 4*Devices.density
        width: parent.width
        anchors.top: flickable.top
        z: 10
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#990d80ec" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    Component.onCompleted: backButtonColor = "#333333"
    Component.onDestruction: backButtonColor = "#ffffff"
}

