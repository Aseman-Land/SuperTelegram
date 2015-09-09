import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0
import AsemanTools.Controls.Styles 1.0
import QtQuick.Controls 1.2
import SuperTelegram 1.0
import TelegramQmlLib 1.0
import "../"

Item {
    id: edit_panel
    height: visualHeight

    property real maximumHeight: main.height*0.8
    property real logicalHeight: column.height + buttons_panel.height
    property real visualHeight: {
        if(logicalHeight > maximumHeight)
            return maximumHeight
        else
            return logicalHeight
    }

    property alias text: tarea.text
    property bool edit: false

    signal cancel()
    signal done()
    signal deleteRequest()

    Flickable {
        id: flick
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: buttons_panel.top
        contentWidth: column.width
        contentHeight: column.height
        clip: true

        Column {
            id: column
            width: flick.width

            Item {width: 1; height: 10*Devices.density}

            DateTimeChooser {
                id: datetime
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width*0.9
                height: 160*Devices.density
                textsColor: "#333333"
                separatorColors: "#333333"
                color: "#ffffff"
            }

            Item {width: 1; height: 10*Devices.density}

            StgTextArea {
                id: tarea
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 10*Devices.density
                height: 80*Devices.density
                placeholder: qsTr("Your Message")
            }
        }
    }

    DialogButtons {
        id: buttons_panel
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10*Devices.density
        anchors.bottomMargin: 0
        onDone: edit_panel.done()
        onCancel: edit_panel.cancel()
        onDeleteRequest: edit_panel.deleteRequest()
        edit: edit_panel.edit
    }

    function getDate() {
        return datetime.getDate()
    }
}

