import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0
import QtQuick.XmlListModel 2.0
import QtQuick.Controls 1.2 as Controls
import "../"

FeaturePageType1 {
    id: smp
    model: xmlModel
    disableMaterialDesign: true
    activeIndicator: xmlModel.status == XmlListModel.Loading || stickerModel.initializing

    property string editId
    property string editType

    StickersModel {
        id: stickerModel
        telegram: main.telegram
        onInstalledStickerSetsChanged: pushStickers()
    }

    XmlListModel {
        id: xmlModel
        query: "/stickers/item"
        source: stg.stickerBankUrl

        XmlRole { name: "name"; query: "@name/string()" }
        XmlRole { name: "shortName"; query: "@shortName/string()" }
        XmlRole { name: "type"; query: "@type/string()" }
        XmlRole { name: "icon"; query: "@icon/string()" }
    }

    Connections {
        target: stickerModel.telegram
        onStickerInstalled: {
            if(ok)
                showTooltip(qsTr("Installed Successfully :)"))
            else
                showTooltip(qsTr("Installation Faild!"))

            wait_rect.visible = false
            editMode = false
        }
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
                    sourceSize: Qt.size(width*2, height*2)
                    source: model.icon==""? "" : Tools.fileParent(xmlModel.source) + "/" + model.icon
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: model.name
                color: "#333333"
                font.pixelSize: 11*Devices.fontDensity
            }
        }

        Text {
            x: parent.width-width-20*Devices.density
            anchors.verticalCenter: parent.verticalCenter
            color: installed? "#0d80ec" : "#aa0000"
            font.pixelSize: 9*Devices.fontDensity
            text: installed? "INSTALLED" : model.type.toUpperCase()

            property bool installed: checkInstall(model.shortName)
        }

        MouseArea {
            id: marea
            anchors.fill: parent
            onClicked: {
                editId = model.shortName
                editType = model.type
                stickerModel.currentStickerSet = model.shortName
                editMode = true
            }
        }
    }

    section.property: "type"
    section.criteria: ViewSection.FullString
    section.delegate: Rectangle {
        width: smp.width
        height: 42*Devices.density

        Text {
            width: parent.width-20*Devices.density
            anchors.centerIn: parent
            font.family: AsemanApp.globalFont.family
            font.pixelSize: 11*Devices.fontDensity
            color: "#000000"
            text: {
                var txt = section.slice(0,1).toUpperCase() + section.slice(1)
                return ("%1 stickers").arg(txt)
            }
        }
    }

    editDelegate: Column {
        id: edit_panel
        width: smp.width
        y: Devices.standardTitleBarHeight + View.statusBarHeight
        visible: parent.destHeight == parent.height

        property string stickerId
        property string type

        Item {
            height: smp.height*0.5
            width: parent.width
            clip: true

            AsemanGridView {
                id: gview
                anchors.fill: parent
                model: stickerModel
                cellHeight: cellWidth
                cellWidth: width/Math.floor(width/(64*Devices.density))
                delegate: Item {
                    id: item
                    width: gview.cellWidth
                    height: gview.cellHeight

                    property Document document: model.document

                    FileHandler {
                        id: handler
                        target: item.document
                        telegram: stickerModel.telegram
                        Component.onCompleted: download()
                    }

                    Image {
                        anchors.fill: parent
                        anchors.margins: 4*Devices.density
                        height: parent.height
                        width: height
                        fillMode: Image.PreserveAspectFit
                        sourceSize: Qt.size(width*2, height*2)
                        source: handler.downloaded? handler.filePath : handler.thumbPath
                    }
                }
            }


            ScrollBar {
                scrollArea: gview; height: gview.height; width: 6*Devices.density
                anchors.top: gview.top; color: main.color
                x: parent.width-width
            }
        }

        DialogButtons {
            id: buttons_panel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*Devices.density
            doneText: edit? qsTr("DONE") : qsTr("INSTALL")
            edit: checkInstall(stickerId)
            onCancel: editMode = false
            onDeleteRequest: {
                tg.uninstallStickerSet(stickerId)
                editMode = false
            }
            onDone: {
                if(!edit) {
                    if(type == "paid" && !store.premium) {
                        messageDialog.show(limit_warning_component)
                        return
                    }
                    wait_rect.visible = true
                    tg.installStickerSet(stickerId)
                }

                editMode = false
            }
        }

        Component.onCompleted: {
            if(editId.length != 0) {
                stickerId = editId
                type = editType
            }

            editId = ""
            editType = ""
        }
    }

    Rectangle {
        id: wait_rect
        anchors.fill: parent
        color: "#88000000"
        visible: false

        MouseArea {
            anchors.fill: parent
        }

        Rectangle {
            width: wait_row.width + 40*Devices.density
            height: wait_row.height + 40*Devices.density
            radius: 5*Devices.density
            anchors.centerIn: parent

            Row {
                id: wait_row
                anchors.centerIn: parent
                spacing: 8*Devices.density

                Indicator {
                    height: 22*Devices.density
                    width: height
                    indicatorSize: height
                    light: false
                    modern: true
                    running: wait_rect.visible
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#333333"
                    text: qsTr("Installing...")
                }
            }
        }
    }

    function checkInstall(shortName) {
        var sets = stickerModel.installedStickerSets
        for(var i=0 ;i<sets.length; i++)
            if(stickerModel.stickerSetItem(sets[i]).shortName == shortName)
                return true
        return false
    }

    function pushStickers() {
        var sets = stickerModel.installedStickerSets
        var shortNames = new Array
        for(var i=0 ;i<sets.length; i++)
            shortNames[i] = stickerModel.stickerSetItem(sets[i]).shortName

        stg.pushStickers(shortNames)

    }

    Component {
        id: limit_warning_component
        MessageDialogOkCancelWarning {
            message: qsTr("<b>Store Message</b><br />It's paid sticker. You need premium package to buy paid stickers.<br /><br /><b>%1</b><br />%2")
                         .arg(store.stg_premium_pack_Title).arg(store.stg_premium_pack_Description)
            onOk: {
                BackHandler.back()
                showStore("")
            }
        }
    }
}

