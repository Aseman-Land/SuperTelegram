import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0
import QtQuick.Controls 1.2 as Controls
import "../"

FeaturePageType1 {
    id: smp
    width: 100
    height: 62
    model: smodel.stickerSets
    disableMaterialDesign: true
    activeIndicator: smodel.initializing
    description: qsTr("Installed sticker manager.\n" +
                      "It provides to you tools to show " +
                      "and remove installed stickers on your telegram account.")

    property string editId

    StickersModel {
        id: smodel
        telegram: tg
    }

    text: {
        if(editMode)
            return qsTr("Delete Sticker")
        else
            return qsTr("Sticker Manager")
    }

    itemDelegate: Item {
        id: sitem
        width: smp.width
        height: 64*Devices.density

        property string stickerId: smodel.stickerSets[index]
        property StickerSet stickerSet: smodel.stickerSetItem(stickerId)

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6*Devices.density
            radius: 4*Devices.density
            color: "#0d80ec"
            opacity: marea.pressed? 0.2 : 0
        }

        FileHandler {
            id: fileHandler
            telegram: tg
            target: smodel.stickerSetThumbnailDocument(sitem.stickerId)
            Component.onCompleted: download()
        }

        Row {
            width: parent.width - 40*Devices.density
            anchors.centerIn: parent
            spacing: 10*Devices.density
            layoutDirection: View.layoutDirection

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
                    anchors.margins: 8*Devices.density
                    sourceSize: Qt.size(width, height)
                    source: fileHandler.filePath
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: sitem.stickerSet.title
                color: "#333333"
                font.pixelSize: 11*fontRatio*Devices.fontDensity
                font.family: AsemanApp.globalFont.family
            }
        }

        MouseArea {
            id: marea
            anchors.fill: parent
            onClicked: {
                editId = sitem.stickerSet.shortName
                editMode = true
            }
        }
    }

    editDelegate: Item {
        id: item
        height: column.height
        visible: parent.destHeight == parent.height
        width: smp.width
        y: headerY

        property string stickerId

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*Devices.density

            Text {
                id: text_area
                width: parent.width
                text: qsTr("Are you sure about removing this sticker set?")
                font.pixelSize: 11*fontRatio*Devices.fontDensity
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: "#333333"
            }

            Item {width: 1; height: 10*Devices.density}

            DialogButtons {
                id: buttons_panel
                width: parent.width
                edit: true
                onDone: {
                    editMode = false
                }
                onDeleteRequest: {
                    tg.uninstallStickerSet(item.stickerId)
                    editMode = false
                }
            }
        }

        Component.onCompleted: {
            if(editId.length != 0) {
                stickerId = editId
            }

            editId = ""
        }
    }
}

