import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0
import AsemanTools.Controls.Styles 1.0 as Styles
import QtGraphicalEffects 1.0

Item {
    id: about
    width: 100
    height: 62

    AsemanFlickable {
        id: flickable
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: home_btn.top
        anchors.bottomMargin: 4*Devices.density
        flickableDirection: Flickable.VerticalFlick
        clip: true

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10*Devices.density

            Item { width: 1; height: 20*Devices.density }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: about.width/3
                height: width
                source: "img/stg.png"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#333333"
                font.family: AsemanApp.globalFont.family
                font.pixelSize: 17*fontRatio*Devices.fontDensity
                text: AsemanApp.applicationDisplayName
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
        style: Styles.ButtonStyle {
            buttonColor: "#2CA5E0"
            buttonTextColor: "#ffffff"
        }
    }
}

