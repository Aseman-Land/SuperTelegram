import QtQuick 2.0
import AsemanTools 1.0

Row {
    id: buttons_panel
    spacing: 10*Devices.density
    height: 50*Devices.density
    layoutDirection: View.layoutDirection

    property bool edit

    signal deleteRequest()
    signal cancel()
    signal done()

    Item {
        width: parent.width/2
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: edit? qsTr("DELETE") : qsTr("CANCEL")
            anchors.centerIn: parent
            font.pixelSize: 10*Devices.fontDensity
            font.weight: Font.DemiBold
            color: "#B30D0D"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(edit)
                    deleteRequest()
                else
                    cancel()
            }
        }
    }

    Item {
        width: parent.width/2
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: qsTr("DONE")
            anchors.centerIn: parent
            font.pixelSize: 10*Devices.fontDensity
            font.weight: Font.DemiBold
            color: "#0d80ec"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: done()
        }
    }
}

