import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0
import QtQuick.Controls 1.2 as Controls
import "../"

FeaturePageType1 {
    id: amp
    model: amodel
    descriptionVisiblity: amodel.count <= 1
    description: qsTr("Send a message to the friends automatically when they send a message to you.\n" +
                      "When you're at meeting, driving or …, you can enable auto message to" +
                      " send an auto message to your friends.")

    property string editGuid
    property string editMessage

    AutoMessageModel {
        id: amodel
        database: stg.database
    }

    text: {
        if(editMode)
            return qsTr("Add new Message")
        else
            return qsTr("Auto Message")
    }

    itemDelegate: Item {
        width: amp.width
        height: 52*Devices.density

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6*Devices.density
            radius: 4*Devices.density
            color: "#0d80ec"
            opacity: marea.pressed? 0.2 : 0
        }

        Row {
            width: parent.width - 40*Devices.density
            anchors.centerIn: parent
            spacing: 10*Devices.density
            layoutDirection: View.layoutDirection

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: 22*Devices.density
                height: width

                Image {
                    anchors.fill: parent
                    source: "../img/ok.png"
                    sourceSize: Qt.size(width, height)
                    visible: amodel.active == model.guid
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: model.message
                color: "#333333"
                font.pixelSize: 11*fontRatio*Devices.fontDensity
                font.family: AsemanApp.globalFont.family
            }
        }

        MouseArea {
            id: marea
            anchors.fill: parent
            onPressed: edit_timer.restart()
            onReleased: {
                if(edit_timer.running)
                    amodel.active = model.guid

                edit_timer.stop()
            }
        }

        Timer {
            id: edit_timer
            interval: 1000
            onTriggered: {
                editGuid = model.guid
                editMessage = model.message
                editMode = true
            }
        }
    }

    editDelegate: Item {
        id: item
        height: column.height
        visible: parent.destHeight == parent.height
        width: amp.width
        y: headerY

        property string guid

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*Devices.density

            StgTextArea {
                id: text_area
                width: parent.width
                height: 100*Devices.density
                placeholder: qsTr("Your Message")
            }

            TextsExtraTags {
                id: keywords
                width: parent.width
                onActivated: text_area.text += (" " + tag + " ")
            }

            Item {width: 1; height: 10*Devices.density}

            DialogButtons {
                id: buttons_panel
                width: parent.width
                onCancel: editMode = false
                edit: item.guid.length != 0
                onDone: {
                    if(item.guid.length == 0)
                        amodel.addItem(text_area.text)
                    else
                        amodel.updateItem(item.guid, text_area.text)
                    editMode = false
                }
                onDeleteRequest: {
                    amodel.deleteItem(item.guid)
                    editMode = false
                }
            }
        }

        Component.onCompleted: {
            if(editGuid.length != 0) {
                guid = editGuid
                text_area.text = editMessage
            }

            editGuid = ""
            editMessage = ""
        }
    }
}

