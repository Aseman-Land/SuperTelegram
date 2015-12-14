import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0
import QtQuick.Controls 1.2 as Controls
import "../"

FeaturePageType1 {
    id: smsg
    model: smodel
    description: qsTr("Description of the Timer Message.\n" +
                      "It's important\n" +
                      "Because Because Because.")

    property string editKey
    property string editValue

    SensMessageModel {
        id: smodel
        database: stg.database
    }

    text: {
        if(editMode)
            return qsTr("Add new Message")
        else
            return qsTr("Sensitive Message")
    }

    itemDelegate: Item {
        width: smsg.width
        height: 64*Devices.density

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
            layoutDirection: View.layoutDirection
            spacing: 10*Devices.density

            Rectangle {
                id: pic_frame
                anchors.verticalCenter: parent.verticalCenter
                border.color: "#d5d5d5"
                border.width: 1*Devices.density
                height: 46*Devices.density
                color: "#e5e5e5"
                width: height
                radius: width/2

                Image {
                    anchors.fill: parent
                    anchors.margins: 6*Devices.density
                    source: "../img/swap.png"
                    sourceSize: Qt.size(width, height)
                }
            }

            Column {
                spacing: 2*Devices.density
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - parent.spacing - pic_frame.width

                Text {
                    id: name_text
                    width: parent.width
                    horizontalAlignment: View.layoutDirection==Qt.RightToLeft? Text.AlignRight : Text.AlignLeft
                    font.pixelSize: 11*fontRatio*Devices.fontDensity
                    color: "#333333"
                    text: model.key
                }

                Text {
                    id: desc_text
                    width: parent.width
                    horizontalAlignment: View.layoutDirection==Qt.RightToLeft? Text.AlignRight : Text.AlignLeft
                    font.pixelSize: 9*fontRatio*Devices.fontDensity
                    color: "#aaaaaa"
                    wrapMode: Text.WrapAnywhere
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    text: model.value
                }
            }
        }

        MouseArea {
            id: marea
            anchors.fill: parent
            onClicked: {
                editKey = model.key
                editValue = model.value
                editMode = true
            }
        }
    }

    editDelegate: Item {
        id: item
        height: column.height
        visible: parent.destHeight == parent.height
        width: smsg.width
        y: headerY

        property string key

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*Devices.density

            Controls.TextField {
                id: text_field
                width: parent.width
                placeholderText: qsTr("Keyword")
                inputMethodHints: Qt.ImhNoPredictiveText
            }

            StgTextArea {
                id: text_area
                width: parent.width
                height: 100*Devices.density
                placeholder: qsTr("Your Message")
            }

            Text {
                id: keywords
                font.family: AsemanApp.globalFont.family
                font.pixelSize: 8*fontRatio*Devices.fontDensity
                color: "#888888"
                text: qsTr("Available keywords: %location% %camera%")
            }

            Item {width: 1; height: 10*Devices.density}

            DialogButtons {
                id: buttons_panel
                width: parent.width
                onCancel: editMode = false
                edit: item.key.length != 0
                onDone: {
                    if(item.key.length != 0)
                        smodel.removeItem(item.key)

                    smodel.addItem(text_field.text, text_area.text)
                    editMode = false
                }
                onDeleteRequest: {
                    smodel.removeItem(item.key)
                    editMode = false
                }
            }
        }

        Component.onCompleted: {
            if(editKey.length != 0) {
                key = editKey
                text_field.text = editKey
                text_area.text = editValue
            }

            editKey = ""
            editValue = ""
        }
    }
}

