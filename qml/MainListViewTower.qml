import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: tower
    width: 100
    height: 62

    property int minimumHeight: 30*Devices.density
    property int maximumHeight: 120*Devices.density
    property color color: "#0d80ec"

    onHeightChanged: refresh_timer.restart()

    Timer {
        id: refresh_timer
        interval: 100
        onTriggered: tower.refresh()
    }

    ListObject {
        id: list
    }

    Item {
        id: tscene
        anchors.fill: parent
    }

    function refresh() {
        while(list.count)
            list.takeFirst().destroy()

        var currentY = 0
        var available = tower.height
        var delta = maximumHeight-minimumHeight
        while(available > 0) {
            var h = Math.random()*delta + minimumHeight
            if(available < maximumHeight)
                h = available

            var map = {"height": h, "y": currentY}
            var obj = rect_component.createObject(tscene, map)
            list.append(obj)

            available -= h
            currentY += h
        }
    }

    Component {
        id: rect_component
        Rectangle {
            width: tower.width*(widthRandome*0.9 + 0.1)
            color: tower.color
            anchors.right: parent.right

            property real widthRandome: 1

            Component.onCompleted: {
                widthRandome = Math.random()
            }
        }
    }
}

