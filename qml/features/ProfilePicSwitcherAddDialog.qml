import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: add_item

    signal clickedOnFile(variant fileUrl)

    ListObject {
        id: back_stack
    }

    Rectangle {
        id: back_rect
        anchors.fill: parent
        color: "#000000"
        opacity: 0

        Behavior on opacity {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 400}
        }
    }

    Rectangle {
        id: add_scene
        width: parent.width
        height: parent.height
        y: parent.height

        Behavior on y {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 400}
        }

        FileSystemView {
            width: parent.width
            anchors.top: add_header.bottom
            anchors.bottom: parent.bottom
            root: AsemanApp.startPath
            gridWidth: 100*Devices.density
            onClickedOnFile: add_item.clickedOnFile(fileUrl)
            onRootChanged: {
                if(root == startRoot)
                    return

                back_stack.append(root)
            }

            property string startRoot: AsemanApp.startPath
        }

        Rectangle {
            id: add_header
            width: parent.width
            height: View.statusBarHeight + Devices.standardTitleBarHeight
            color: main.color

            Rectangle {
                height: 3*Devices.density
                width: parent.width
                anchors.top: parent.bottom
                z: 10
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#55000000" }
                    GradientStop { position: 1.0; color: "#00000000" }
                }
            }
        }

        Timer {
            id: destroy_timer
            interval: 400
            onTriggered: add_item.destroy()
        }

        function back() {
            y = height
            back_rect.opacity = 0
            destroy_timer.restart()
            BackHandler.removeHandler(add_scene)
        }

        Component.onCompleted: {
            y = 0
            back_rect.opacity = 0.7
            BackHandler.pushHandler(add_scene, add_scene.back)
        }
    }

    function close() {
        add_scene.back()
    }
}

