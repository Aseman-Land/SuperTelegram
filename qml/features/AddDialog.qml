import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0
import "../"

Item {
    id: add_dlg
    width: 100
    height: 62

    property bool addMode: false
    property Dialog currentDialog: telegram.nullDialog

    property bool dialogIsNull: currentDialog == telegram.nullDialog
    property bool isChat: currentDialog.peer.chatId != 0
    property int dialogId: isChat? currentDialog.peer.chatId : currentDialog.peer.userId
    property User user: !dialogIsNull? telegram.user(currentDialog.peer.userId) : telegram.nullUser
    property Chat chat: !dialogIsNull? telegram.chat(currentDialog.peer.chatId) : telegram.nullChat

    property string dialogName: {
        var result = ""
        if(dialogIsNull)
            return result
        if(isChat)
            result = chat.title
        else
            result = user.firstName + " " + user.lastName
        result = result.trim()
        return result
    }

    onAddModeChanged: {
        if(addMode)
            BackHandler.pushHandler(add_dlg, add_dlg.back)
        else
            BackHandler.removeHandler(add_dlg)
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: View.statusBarHeight + standardTitleBarHeight
        clip: true

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: addMode? 0.2 : 0

            Behavior on opacity {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 400}
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*Devices.density
            y: -radius
            height: addMode? parent.height - 10*Devices.density + radius : 0
            radius: 4*Devices.density

            Behavior on height {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 400}
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            Item {
                id: main_scene
                y: parent.radius
                width: parent.width
                height: parent.height - parent.radius

                property bool available: shadow.opacity == 1
                property variant dialogList

                onAvailableChanged: {
                    if(available) {
                        if(!dialogList)
                            dialogList = dialog_list_component.createObject(main_scene)
                    } else {
                        if(dialogList)
                            dialogList.destroy()
                    }

                }
            }
        }

        Rectangle {
            id: shadow
            height: 3*Devices.density
            width: parent.width
            opacity: addMode? 1 : 0
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#55000000" }
                GradientStop { position: 1.0; color: "#00000000" }
            }

            Behavior on opacity {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 400}
            }
        }
    }

    function back() {
        addMode = false
    }

    Component {
        id: dialog_list_component
        DialogList {
            anchors.fill: parent
            onSelected: {
                currentDialog = dialog
                addMode = false
            }
        }
    }
}

