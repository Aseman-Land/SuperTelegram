import QtQuick 2.0
import QtQuick.Controls 1.2 as QtControls
import AsemanTools.Controls 1.0 as Controls
import AsemanTools.Controls.Styles 1.0
import AsemanTools 1.0
import TelegramQml 1.0

Item {
    id: dlist

    DialogsModel {
        id: dmodel
        telegram: main.telegram
    }

    ListView {
        id: listv
        anchors.fill: parent
        model: dmodel
        clip: true
        maximumFlickVelocity: View.flickVelocity
        boundsBehavior: Flickable.StopAtBounds
        rebound: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 0
            }
        }

        delegate: Item {
            id: item
            width: listv.width
            height: 64*Devices.density

            property Dialog dialog: model.item

            Row {
                width: parent.width - 40*Devices.density
                anchors.centerIn: parent
                layoutDirection: View.layoutDirection

                ProfilePicture {
                    radius: height/2
                    width: height
                    height: 46*Devices.density
                    sourceSize: Qt.size(width*2, height*2)
                    dialog: item.dialog
                    telegram: dmodel.telegram
                }
            }
        }
    }

    ScrollBar {
        id: scrollbar
        scrollArea: listv; height: listv.height; width: 6*Devices.density
        anchors.top: listv.top; color: main.color
        x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width
    }
}

