import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0
import AsemanTools.Controls.Styles 1.0 as Styles

Rectangle {
    id: about
    color: "#fcfcfc"

    AsemanFlickable {
        id: flickable
        width: parent.width
        anchors.top: parent.top
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
                font.pixelSize: 17*fontRatio*Devices.fontDensity
                text: qsTr("Nile Group")
            }

            Text {
                width: about.width - 40*Devices.density
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#333333"
                font.family: AsemanApp.globalFont.family
                font.pixelSize: 10*fontRatio*Devices.fontDensity
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
        style: Styles.ButtonStyle {
            buttonColor: "#00A0E3"
            buttonTextColor: "#ffffff"
        }
    }
}

