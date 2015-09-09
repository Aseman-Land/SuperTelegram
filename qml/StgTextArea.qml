import QtQuick 2.0
import QtQuick.Controls 1.2
import AsemanTools 1.0

Item {
    width: 200
    height: 100

    property alias placeholder: txt.text
    property alias text: tarea.text

    TextArea {
        id: tarea
        anchors.fill: parent
        anchors.topMargin: txt.height + 14*Devices.density
    }

    Text {
        id: txt
        font.pixelSize: 10*Devices.fontDensity
        color: "#888888"
        x: {
            var result = 8*Devices.density
            if(tarea.focus || tarea.text.length != 0)
                result = 0
            if(View.layoutDirection == Qt.RightToLeft)
                result = parent.width - width - result
            return result
        }
        y: tarea.focus || tarea.text.length != 0? tarea.y - height : tarea.y + 8*Devices.density

        Behavior on y {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
        }
        Behavior on x {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
        }
    }

    Row {
        height: 22*Devices.density
        anchors.bottom: tarea.top
        anchors.bottomMargin: 2*Devices.density
        spacing: 8*Devices.density
        x: {
            var result = parent.width - width
            if(View.layoutDirection == Qt.RightToLeft)
                result = 0

            return result
        }
        visible: tarea.focus

        Image {
            height: parent.height
            width: height
            sourceSize: Qt.size(width, height)
            source: "img/copy.png"

            MouseArea {
                anchors.fill: parent
                onClicked: tarea.copy()
            }
        }

        Image {
            height: parent.height
            width: height
            sourceSize: Qt.size(width, height)
            source: "img/paste.png"

            MouseArea {
                anchors.fill: parent
                onClicked: tarea.paste()
            }
        }
    }
}

