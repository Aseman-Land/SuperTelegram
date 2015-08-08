import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: pmanager
    clip: true

    property Component mainComponent
    property alias mainItem: scene.itemObject

    property real separatorsWidth: width*3
    property int animationDuration: 700
    property int easingType: Easing.OutCubic
    property alias count: list.count

    onMainComponentChanged: {
        if(mainItem)
            mainItem.destroy()

        mainItem = mainComponent.createObject(scene)
    }

    ListObject {
        id: list

        function lastItem() {
            if(count == 0)
                return scene
            else
                return last()
        }
    }

    Item {
        id: scene
        width: parent.width
        height: parent.height
        clip: true

        Behavior on x {
            NumberAnimation{easing.type: easingType; duration: animationDuration}
        }

        property variant itemObject
    }

    function append(component) {
        var last = list.lastItem()
        var iscene = item_component.createObject(pmanager)

        iscene.itemObject = component.createObject(iscene.itemScene)
        iscene.startLen = last.itemObject.headerY
        iscene.endLen = iscene.itemObject.headerY
        iscene.headerColor = last.itemObject.headColor
        iscene.background = last.itemObject.backgroundColor
        last.x = View.layoutDirection==Qt.RightToLeft? iscene.width : -iscene.width

        list.append(iscene)
    }

    Component {
        id: item_component
        Row {
            id: item
            height: parent.height
            x: View.layoutDirection==Qt.RightToLeft? -width : parent.width
            clip: true
            layoutDirection: View.layoutDirection

            property alias itemScene: item_scene
            property variant itemObject
            property alias startLen: separator.startLen
            property alias endLen: separator.endLen
            property alias headerColor: separator.startFillColor
            property alias background: separator.startBackColor

            Behavior on x {
                NumberAnimation{easing.type: easingType; duration: animationDuration}
            }

            PageSeparator {
                id: separator
                height: parent.height
                width: separatorsWidth
                endLen: item.itemObject? item.itemObject.headerY : 0
                endFillColor: item.itemObject? item.itemObject.headColor : startFillColor
                endBackColor: item.itemObject? item.itemObject.backgroundColor : startFillColor
            }

            Item {
                id: item_scene
                width: pmanager.width
                height: parent.height
            }

            Timer {
                id: destroy_timer
                interval: animationDuration
                onTriggered: item.destroy()
            }

            function back() {
                list.removeAll(item)

                x = View.layoutDirection==Qt.RightToLeft? -width : pmanager.width
                list.lastItem().x = 0
                destroy_timer.destroy()
            }

            Component.onCompleted: {
                x = View.layoutDirection==Qt.RightToLeft? 0 : -separator.width
                BackHandler.pushHandler(item, item.back)
            }
        }
    }

    Component {
        id: seprator_component
        PageSeparator {
            height: parent.height
            width: separatorsWidth
        }
    }
}

