import QtQuick 2.0
import QtQuick.Controls 1.3
import AsemanTools 1.0
import AsemanTools.Controls 1.0

Rectangle {
    id: tgmain

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

        SlidePageManager {
            id: page_manager
            width: parent.width
            height: parent.height

            mainComponent: MainPage {
                width: main.width
                height: main.height
                headerSidePad: menu_btn.width - 10*Devices.density
                onHeaderColorChanged: tgmain.color = headerColor
                onSelected: page_manager.append(component)
            }
        }

        MenuController {
            id: menu
            anchors.fill: parent
            source: page_manager
            menuTopMargin: Devices.standardTitleBarHeight + View.statusBarHeight
            component: MenuList {
                anchors.fill: parent
                anchors.topMargin: 30*Devices.density
                onSelected: {
                    if(index == 0)
                        menu.close()
                    else
                        if(component) {
                            slave_scene.item = component.createObject(slave_scene)
                            slave_scene.item.anchors.fill = slave_scene
                        } else {
                            menu.close()
                        }
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

        property variant item
        property variant lastItem
        onItemChanged: {
            if(item)
                BackHandler.pushHandler(slave_scene, slave_scene.back)
            else
                BackHandler.removeHandler(slave_scene)

            if(lastItem)
                Tools.jsDelayCall(item?1:400, lastItem.destroy)

            lastItem = item
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
        color: backButtonColor
        buttonColor: backButtonColor
        height: Devices.standardTitleBarHeight
        ratio: animatedRatio? animatedRatio : menu.ratio
        onClicked: {
            if(menu.isVisible || page_manager.count)
                BackHandler.back()
            else
                menu.show()
        }

        Behavior on color {
            ColorAnimation{easing.type: Easing.OutCubic; duration: 400}
        }

        property real animatedRatio: page_manager.count? 1 : 0
        Behavior on animatedRatio {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 500}
        }
    }
}

