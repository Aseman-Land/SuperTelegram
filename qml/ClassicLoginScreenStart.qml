import QtQuick 2.0
import AsemanTools 1.0
import QtGraphicalEffects 1.0

Rectangle {
    id: classic_login
    width: 100
    height: 62
    color: "#FAFAFA"

    signal start()

    Column {
        y: img.height - (View.statusBarHeight? 0 : 22*Devices.density)
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            id: img
            anchors.horizontalCenter: parent.horizontalCenter
            width: classic_login.width/3
            height: width
            source: "img/stg.png"
            sourceSize: Qt.size(width*2, height*2)
        }

        Item { width: 2; height: img.width/6 }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#000000"
            font.family: AsemanApp.globalFont.family
            font.pixelSize: img.width/5
            text: AsemanApp.applicationDisplayName
        }

        Item { width: 2; height: img.width/10 }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            color: "#828282"
            font.family: AsemanApp.globalFont.family
            font.pixelSize: img.width/10
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr("The world's fastest messaging app.\nIt is free and secure.")
        }

        Item { width: 2; height: img.width/6 }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: classic_login.width*0.4
            height: width*0.3

            DropShadow {
                anchors.fill: button_scene
                source: button_scene
                radius: 2*Devices.density
                verticalOffset: 2*Devices.density
                samples: 32
                color: "#88888888"
            }

            Item {
                id: button_scene
                anchors.fill: parent

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4*Devices.density
                    color: "#2CA5E0"
                    radius: 3*Devices.density

                    Text {
                        anchors.centerIn: parent
                        color: "#ffffff"
                        font.family: AsemanApp.globalFont.family
                        font.pixelSize: parent.height*0.4
                        text: qsTr("START")
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: start()
                }
            }
        }
    }
}

