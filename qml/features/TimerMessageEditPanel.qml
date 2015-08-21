import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0
import AsemanTools.Controls.Styles 1.0
import QtQuick.Controls 1.2
import SuperTelegram 1.0
import TelegramQml 1.0
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
        maximumFlickVelocity: View.flickVelocity
        boundsBehavior: Flickable.StopAtBounds
        rebound: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 0
            }
        }
        clip: true

        Column {
            id: column
            width: flick.width

            DateTimeChooser {
                id: datetime
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width*0.9
                height: 140*Devices.density
                textsColor: "#333333"
                separatorColors: "#333333"
                color: "#ffffff"
            }

            Item {width: 1; height: 10*Devices.density}

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 10*Devices.density
                height: 80*Devices.density

                TextArea {
                    id: tarea
                    anchors.fill: parent
                    anchors.topMargin: txt.height + 4*Devices.density
                }

                Text {
                    id: txt
                    font.pixelSize: 10*Devices.fontDensity
                    color: "#333333"
                    text: qsTr("Your Message")
                    x: {
                        var result = 8*Devices.density
                        if(tarea.focus || tarea.text.length != 0)
                            result = 0
                        if(View.layoutDirection == Qt.RightToLeft)
                            result = parent.width - width - result
                        return result
                    }
                    y: tarea.focus || tarea.text.length != 0? 0 : tarea.y + 8*Devices.density

                    Behavior on y {
                        NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
                    }
                    Behavior on x {
                        NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
                    }
                }
            }
        }
    }

    Row {
        id: buttons_panel
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10*Devices.density
        anchors.bottomMargin: 0
        spacing: 10*Devices.density
        height: 50*Devices.density
        layoutDirection: View.layoutDirection

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

    function getDate() {
        return datetime.getDate()
    }
}

