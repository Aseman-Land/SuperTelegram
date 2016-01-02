import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0
import QtQuick.XmlListModel 2.0
import QtQuick.Controls 1.2 as Controls
import "../"

FeaturePageType1 {
    id: smp
    width: 100
    height: 62
    model: smodel.installedStickerSets
    disableMaterialDesign: true
    activeIndicator: smodel.initializing

    property string editId

    XmlListModel {
        id: smodel
        query: "/products/item"

        XmlRole { name: "name"; query: "info/@name/string()" }
        XmlRole { name: "shortName"; query: "info/@version/string()" }
        XmlRole { name: "publisher"; query: "info/@publisher/string()" }
        XmlRole { name: "type"; query: "info/@type/string()" }
        XmlRole { name: "description"; query: "description/string()" }
        XmlRole { name: "icon"; query: "icon/@src/string()" }
    }

    text: {
        if(editMode)
            return qsTr("Install Sticker")
        else
            return qsTr("Sticker Store")
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

