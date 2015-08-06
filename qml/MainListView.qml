import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: mainlv
    width: 100
    height: 62
    clip: true

    property alias contentY: listv.contentY
    property real headerHeight: 200
    property alias originY: listv.originY

    ListView {
        id: listv
        width: parent.width
        height: parent.height - y
        model: ListModel{}
        boundsBehavior: Flickable.StopAtBounds
        rebound: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 0
            }
        }
        clip: true

        header: Item {
            width: parent.width
            height: headerHeight
        }

        delegate: Item {
            width: listv.width
            height: 70*Devices.density

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20*Devices.density

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    border.color: Qt.rgba(Math.random(), Math.random(), Math.random())
                    border.width: 1*Devices.density
                    height: 50*Devices.density
                    color: "#00000000"
                    width: height
                    radius: width/2
                }
            }
        }
    }

    ScrollBar {
        scrollArea: listv; height: listv.height-headerHeight; width: 6*Devices.density
        anchors.left: listv.left; anchors.top: listv.top; color: "#333333"
        anchors.topMargin: headerHeight
    }

    Component.onCompleted: {
        for(var i=0; i<12; i++)
            listv.model.insert(i, {"idx": i})
    }
}

