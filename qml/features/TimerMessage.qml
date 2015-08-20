import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQml 1.0
import "../"

PageManagerItem {
    id: timemsg
    headerY: View.statusBarHeight + standardTitleBarHeight
    anchors.fill: parent
    headColor: main.color
    backgroundColor: "#fefefe"

    property alias editMode: mbtn.opened
    property alias addMode: add_dialog.addMode

    Rectangle {
        color: timemsg.backgroundColor
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
        height: editMode? parent.height*0.7 : timemsg.headerY
        color: editMode? "#ffffff" : timemsg.headColor
        z: 10

        property variant item
        property bool available: height == parent.height*0.7
        onAvailableChanged: {
            if(available) {
                if(!item)
                    item = tm_edit_component.createObject(header)
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

        Rectangle {
            height: 3*Devices.density
            width: parent.width
            anchors.top: parent.bottom
            opacity: 1
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#55000000" }
                GradientStop { position: 1.0; color: "#00000000" }
            }
        }
    }

    AddDialog {
        id: add_dialog
        anchors.fill: parent
        onAddModeChanged: if(!addMode && currentDialog == telegram.nullDialog) close_timer.restart()
        z: 11
    }

    TimerMessageModel {
        id: tmodel
        database: stg.database
        telegram: main.telegram
    }

    ListView {
        id: listv
        width: parent.width
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        model: tmodel
        delegate: Item {
            id: item
            width: listv.width
            height: 52*Devices.density

            property User user: telegram.user(model.peerId)
            property Chat chat: telegram.chat(model.peerId)

            Row {
                width: parent.width - 40*Devices.density
                anchors.centerIn: parent
                layoutDirection: View.layoutDirection

                ProfilePicture {
                    radius: height/2
                    width: height
                    height: 46*Devices.density
                    sourceSize: Qt.size(width*2, height*2)
                    isChat: model.peerIsChat
                    user: item.user
                    chat: item.chat
                    telegram: dmodel.telegram
                }
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
        onClicked: if(opened) add_timer.restart()
    }

    Component {
        id: tm_edit_component
        TimerMessageEditPanel {
            anchors.fill: parent
            anchors.topMargin: headerY
        }
    }
}

