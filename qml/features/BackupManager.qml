import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0
import "../"

FeaturePageType1 {
    id: bmng
    model: dmodel
    activeIndicator: dmodel.initializing
    disableMaterialDesign: true

    text: {
        if(editMode)
            return dialogIsNull? qsTr("Create Backup") : dialogName
        else
            return qsTr("Backup Messages")
    }

    BackupManager {
        id: backuper
        telegram: tg
        dialog: bmng.currentDialog
        onProgressChanged: console.debug(progress)
    }

    DialogsModel {
        id: dmodel
        telegram: tg
    }

    itemDelegate: DialogListItem {
        id: item
        width: bmng.width
        dialog: model.item
        telegram: dmodel.telegram
        onClicked: {
            bmng.currentDialog = dialog
            editMode = true
        }
    }

    editDelegate: Column {
        id: edit_panel
        width: bmng.width
        y: standardTitleBarHeight

        DateTimeChooser {
            id: datetime
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*Devices.density
            height: 160*Devices.density
            textsColor: "#333333"
            separatorColors: "#333333"
            color: "#ffffff"
        }

        DialogButtons {
            id: buttons_panel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*Devices.density
            onCancel: edit_panel.cancel()
            onDone: {
                backuper.startDate = datetime.date
                backuper.destination = "/home/bardia/test.txt"
                backuper.start()
            }
        }
    }

    Rectangle {
        id: progress_area
        anchors.fill: parent
        color: "#aa000000"
        z: 20
        visible: indicator.active

        MouseArea {
            anchors.fill: parent
        }

        Indicator {
            id: indicator
            anchors.centerIn: parent
            modern: true
            light: true

            property bool active: backuper.processing
            onActiveChanged: active? start() : stop()
        }
    }
}

