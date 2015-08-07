import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: hmb
    width: height
    height: standardTitleBarHeight
    property alias color: rect.color

    property alias ratio: menuIcon.ratio
    property alias pressed: marea.pressed

    signal clicked()

    Rectangle {
        id: rect
        anchors.fill: parent
        anchors.margins: 10*Devices.density
        color: pressed? "#33ffffff" : "#00000000"
        radius: 3*Devices.density
    }

    MenuIcon {
        id: menuIcon
        anchors.centerIn: parent
        layoutDirection: View.layoutDirection
    }

    MouseArea {
        id: marea
        anchors.fill: parent
        onClicked: hmb.clicked()
    }
}

