import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0
import QtQuick.Extras 1.4
import "../"

PageManagerItem {
    headerY: View.statusBarHeight + standardTitleBarHeight + width*0.6
    anchors.fill: parent
    headColor: main.color
    backgroundColor: "#fefefe"

    Rectangle {
        anchors.fill: parent
        color: backgroundColor
    }

    Rectangle {
        width: parent.width
        height: headerY
        color: headColor

        Dial {
            id: time_slider
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20*Devices.density
            anchors.topMargin: 20*Devices.density + standardTitleBarHeight + View.statusBarHeight
            minimumValue: 0
            maximumValue: 32
            style: ProfilePictureDialStyle {color: headColor}
        }

        Rectangle {
            height: 3*Devices.density
            width: parent.width
            anchors.top: parent.bottom
            z: 10
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#55000000" }
                GradientStop { position: 1.0; color: "#00000000" }
            }
        }
    }

    ProfilePicSwitcherModel {
        id: ppmodel
        folder: stg.picturesLocation + "/ProfilePicSwitcher"
    }
}

