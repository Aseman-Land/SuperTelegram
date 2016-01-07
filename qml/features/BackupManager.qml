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
    description: qsTr("Make a backup from your conversations history.\n" +
                      "You can make a backup from a specified converstion " +
                      "from a date and time using this tools and keep it in a safe place.")

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
        onProcessingChanged: {
            if(processing)
                return

            editMode = false
            showTooltip(qsTr("Saved to \"%1\"").arg(destination))
        }
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
            stg.pushAction("backup-addnew")
        }
    }

    editDelegate: Column {
        id: edit_panel
        width: bmng.width
        y: Devices.standardTitleBarHeight + View.statusBarHeight
        visible: parent.destHeight == parent.height

        DateTimeChooser {
            id: datetime
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*Devices.density
            height: 160*Devices.density
            textsColor: "#333333"
            separatorColors: "#0d80ec"
            color: "#ffffff"
        }

        DialogButtons {
            id: buttons_panel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*Devices.density
            onCancel: editMode = false
            onDone: {
                var dateName = CalendarConv.convertDateTimeToString(datetime.date, "yyyy.MM.dd - hh.mm.ss")
                backuper.startDate = datetime.date
                backuper.destination = Devices.downloadsLocation + "/" + dialogName + " - " + dateName + ".txt"
                backuper.start()
                stg.pushAction("backup-start-create")
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
            indicatorSize: 22*Devices.density

            property bool active: backuper.processing
            onActiveChanged: active? start() : stop()
        }

        ProgressBar {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 20*Devices.density
            percent: backuper.progress
            topColor: "#0d80ec"
        }
    }

    ActivityAnalizer { object: bmng; comment: dmodel.count }
}

