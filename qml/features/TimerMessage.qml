import QtQuick 2.0
import "../"

PageManagerItem {
    id: timemsg
    headerY: 100
    anchors.fill: parent
    headColor: main.color
    backgroundColor: "#fefefe"

    Rectangle {
        color: timemsg.backgroundColor
        anchors.fill: parent
    }

    Rectangle {
        width: parent.width
        height: timemsg.headerY
        color: timemsg.headColor
    }
}

