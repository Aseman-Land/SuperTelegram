import QtQuick 2.4
import QtQuick.Controls 1.3
import AsemanTools 1.0
import AsemanTools.Controls 1.0

AsemanMain {
    id: main
    width: 480
    height: 640
    visible: true

    property real standardTitleBarHeight: Devices.standardTitleBarHeight*1.2

    Item {
        id: main_scene
        width: parent.width
        height: parent.height
        x: slave_scene.item? (View.layoutDirection==Qt.RightToLeft?-width/4:width/4) : 0
        scale: slave_scene.item? 0.7 : 1
        transformOrigin: View.layoutDirection==Qt.RightToLeft? Item.Left : Item.Right

        Behavior on scale {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
        }
        Behavior on x {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
        }

        PageManager {
            id: page_manager
            width: parent.width
            height: parent.height

            mainComponent: MainPage {
                width: main.width
                height: main.height
                headerSidePad: menu_btn.width - 10*Devices.density
                onHeaderColorChanged: main.color = headerColor
                onSelected: page_manager.append(component)
            }
        }

        MenuController {
            id: menu
            anchors.fill: parent
            source: page_manager
            menuTopMargin: standardTitleBarHeight + View.statusBarHeight
            component: MenuList {
                anchors.fill: parent
                anchors.topMargin: 30*Devices.density
                onSelected: {
                    slave_scene.item = index==0? false : true
                    if(index == 0)
                        BackHandler.back()
                }
            }
        }
    }

    Rectangle {
        id: slave_scene
        color: "#111111"
        x: item? 0 : (View.layoutDirection==Qt.RightToLeft?width:-width)
        width: parent.width
        height: parent.height

        property bool item: false
        onItemChanged: {
            if(item)
                BackHandler.pushHandler(slave_scene, slave_scene.back)
            else
                BackHandler.removeHandler(slave_scene)
        }

        Behavior on x {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
        }

        function back() {
            item = false
        }
    }

    HeaderMenuButton {
        id: menu_btn
        y: View.statusBarHeight
        x: View.layoutDirection==Qt.LeftToRight? 0 : parent.width - width
        ratio: animatedRatio? animatedRatio : menu.ratio
        onClicked: {
            if(menu.isVisible || page_manager.count)
                BackHandler.back()
            else
                menu.show()
        }

        property real animatedRatio: page_manager.count? 1 : 0
        Behavior on animatedRatio {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 500}
        }
    }

    Component {
        id: login_component
        LoginScreen {
            anchors.fill: parent
        }
    }

    Component.onCompleted: {
//        if(anything)
            login_component.createObject(main)
    }
}
