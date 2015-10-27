import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0
import "../"

PageManagerItem {
    id: fpt_item
    headerY: View.statusBarHeight + Devices.standardTitleBarHeight
    anchors.fill: parent
    headColor: main.color
    backgroundColor: "#fefefe"

    property Component editDelegate

    property alias text: header_txt.text
    property bool activeIndicator: false
    property bool editMode: false

    onActiveIndicatorChanged: {
        if(activeIndicator)
            indicator.start()
        else
            indicator.stop()
    }

    onEditModeChanged: {
        backButtonColor = editMode? "#333333" : "#ffffff"
        if(editMode)
            BackHandler.pushHandler(fpt_item, function (){fpt_item.editMode = false})
        else
            BackHandler.removeHandler(fpt_item)
    }

    Rectangle {
        color: fpt_item.backgroundColor
        anchors.fill: parent
    }

    Timer {
        id: close_timer
        interval: 300
        onTriggered: editMode = false
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: editMode? 0.6 : 0
        visible: opacity != 0
        z: 10

        Behavior on opacity {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 400}
        }

        MouseArea {
            anchors.fill: parent
            onClicked: editMode = false
        }
    }

    Rectangle {
        id: header
        width: parent.width
        height: editMode? destHeight : fpt_item.headerY
        color: editMode? "#ffffff" : fpt_item.headColor
        z: 10
        clip: true

        property real destHeight: item? item.height+fpt_item.headerY : fpt_item.headerY+10*Devices.density
        property variant item
        property bool available: height != fpt_item.headerY
        onAvailableChanged: {
            if(available) {
                if(!item)
                    item = editDelegate.createObject(header)
            } else {
                if(item)
                    item.destroy()
            }
        }

        Behavior on height {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 400}
        }
        Behavior on color {
            ColorAnimation{easing.type: Easing.OutCubic; duration: 400}
        }

        Item {
            width: parent.width - height - 6*Devices.density
            height: Devices.standardTitleBarHeight
            y: View.statusBarHeight
            x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width

            Text {
                id: header_txt
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14*Devices.fontDensity
                color: backButtonColor
                x: View.layoutDirection==Qt.RightToLeft? parent.width-width : 0
            }

            Indicator {
                id: indicator
                height: parent.height
                width: height
                x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width
                indicatorSize: 22*Devices.density
                modern: true
                light: !editMode
            }
        }
    }

    Rectangle {
        height: 3*Devices.density
        width: header.width
        anchors.top: header.bottom
        z: 10
        visible: editMode
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#55000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }
}

