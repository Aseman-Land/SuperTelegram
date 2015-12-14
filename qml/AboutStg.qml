import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0
import QtGraphicalEffects 1.0

Rectangle {
    id: about
    width: 100
    height: 62
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
        font.pixelSize: 14*fontRatio*Devices.fontDensity
        text: qsTr("About Application")
    }

    AsemanFlickable {
        id: flickable
        width: parent.width
        anchors.top: title_txt.bottom
        anchors.bottom: home_btn.top
        anchors.bottomMargin: 4*Devices.density
        flickableDirection: Flickable.VerticalFlick
        clip: true

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10*Devices.density

            Item { width: 1; height: 20*Devices.density }

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: about.width/3
                height: width

                DropShadow {
                    anchors.fill: img_frame
                    source: img_frame
                    horizontalOffset: 1*Devices.density
                    verticalOffset: 1*Devices.density
                    radius: 4*Devices.density
                    samples: 16
                    color: "#aa000000"
                }

                Item {
                    id: img_frame
                    anchors.fill: parent
                    anchors.margins: -10*Devices.density

                    Image {
                        anchors.fill: parent
                        anchors.margins: 10*Devices.density
                        source: "img/stg.png"
                    }
                }
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
    }

    Rectangle {
        height: 4*Devices.density
        width: parent.width
        anchors.top: flickable.top
        z: 10
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#88ff0000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    Component.onCompleted: backButtonColor = "#333333"
    Component.onDestruction: backButtonColor = "#ffffff"
}

