import QtQuick 2.0
import AsemanTools 1.0
import QtGraphicalEffects 1.0

Item {
    width: 100
    height: 62

    property alias source: back_img.source
    property alias imageHeight: back_img.height
    property alias color: topRect.color

    Image {
        id: back_img
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        clip: true
        visible: false
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(200*Devices.density, 200*Devices.density)
    }

    FastBlur {
        anchors.fill: source
        source: back_img
        radius: 64

        Rectangle {
            id: topRect
            anchors.fill: parent
            opacity: 0.2
        }
    }
}

