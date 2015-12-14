import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0
import "../"

FeaturePageType1 {
    id: tmsg
    model: tmodel
    activeIndicator: tmodel.initializing
    autoAddDialog: true
    description: qsTr("Description of the Timer Message.\n" +
                      "It's important\n" +
                      "Because Because Because.")

    property string editText
    property string editGuid
    property variant editDate

    text: {
        if(addMode)
            return qsTr("Select Contact")
        else
        if(editMode)
            return dialogIsNull? qsTr("Add Timer") : dialogName
        else
            return qsTr("Timer Message")
    }

    editDelegate: TimerMessageEditPanel {
        y: headerY
        width: parent.width
        anchors.topMargin: headerY
        visible: parent.destHeight == parent.height
        onCancel: editMode = false
        onDone: {
            if(text.trim().length == 0) {
                showTooltip(qsTr("Please fill message."))
                return
            }

            var date = getDate()
            if(date <= (new Date)) {
                showTooltip(qsTr("Wrong Date/Time!"))
                return
            }

            if(guid.length == 0)
                tmodel.createItem(tmsg.dialogId, getDate(), text)
            else
                tmodel.updateItem(guid, tmsg.dialogId, getDate(), text)
            editMode = false
        }
        onDeleteRequest: {
            tmodel.deleteItem(guid)
            editMode = false
        }

        property string guid
        property variant date

        Component.onCompleted: {
            if(tmsg.editGuid.length == 0)
                return

            text = editText
            guid = editGuid
            date = editDate
            edit = true

            editText = ""
            editGuid = ""
            editDate = null
        }
    }

    itemDelegate: DialogListItem {
        id: item
        width: tmsg.width
        isChat: model.peerIsChat
        user: telegram.user(model.peerId)
        chat: telegram.chat(model.peerId)
        telegram: tmsg.model.telegram
        description: model.message

        Text {
            anchors.verticalCenter: parent.verticalCenter
            x: View.layoutDirection==Qt.RightToLeft? 10*Devices.density : parent.width-width-10*Devices.density
            font.pixelSize: 10*fontRatio*Devices.fontDensity
            font.weight: Font.DemiBold
            color: "#ff5555"
            text: stg.getTimesDiff(new Date, model.dateTime)
        }

        onClicked: {
            currentDialog = telegram.dialog(isChat?chat.id:user.id)
            editText = model.message
            editGuid = model.guid
            editDate = model.dateTime
            editMode = true
        }
    }

    TimerMessageModel {
        id: tmodel
        database: stg.database
        telegram: main.telegram
    }
}

