import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQml 1.0
import "../"

PageManagerItem {
    id: fpt_item
    headerY: View.statusBarHeight + standardTitleBarHeight
    anchors.fill: parent
    headColor: main.color
    backgroundColor: "#fefefe"

    property bool autoAddDialog: false
    property alias editMode: mbtn.opened
    property alias addMode: add_dialog.addMode

    property Component editDelegate
    property alias itemDelegate: listv.delegate
    property alias model: listv.model

    property alias currentDialog: add_dialog.currentDialog
    property alias dialogIsNull: add_dialog.dialogIsNull
    property alias dialogId: add_dialog.dialogId
    property alias dialogName: add_dialog.dialogName

    property alias text: header_txt.text

    property bool activeIndicator: false

    onActiveIndicatorChanged: {
        if(activeIndicator)
            indicator.start()
        else
            indicator.stop()
    }

    onEditModeChanged: {
        if(!editMode)
            add_dialog.currentDialog = telegram.nullDialog

        backButtonColor = editMode? "#333333" : "#ffffff"
    }

    Rectangle {
        color: fpt_item.backgroundColor
        anchors.fill: parent
    }

    Timer {
        id: add_timer
        interval: 300
        onTriggered: addMode = true
    }

    Timer {
        id: close_timer
        interval: 300
        onTriggered: editMode = false
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
            height: standardTitleBarHeight
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
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#55000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    AddDialog {
        id: add_dialog
        anchors.fill: parent
        onAddModeChanged: if(!addMode && currentDialog == telegram.nullDialog && autoAddDialog) close_timer.restart()
        z: 11
    }

    ListView {
        id: listv
        anchors.fill: parent
        anchors.topMargin: headerY
        maximumFlickVelocity: View.flickVelocity
        boundsBehavior: Flickable.StopAtBounds
        rebound: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 0
            }
        }
    }

    MaterialDesignButton {
        id: mbtn
        anchors.topMargin: headerY
        anchors.fill: parent
        flickable: listv
        color: headColor
        background: "#000000"
        onClicked: if(opened && autoAddDialog) add_timer.restart()
    }
}

