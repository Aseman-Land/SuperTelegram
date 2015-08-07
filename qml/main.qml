import QtQuick 2.4
import QtQuick.Controls 1.3
import AsemanTools 1.0
import AsemanTools.Controls 1.0

AsemanMain {
    width: 480
    height: 640
    visible: true
    color: main_page.headerColor

    property real standardTitleBarHeight: Devices.standardTitleBarHeight*1.2

    MainPage {
        id: main_page
        width: parent.width
        height: parent.height
        headerSidePad: menu_btn.width - 10*Devices.density
    }

    MenuController {
        id: menu
        anchors.fill: parent
        source: main_page
        menuTopMargin: standardTitleBarHeight + View.statusBarHeight
        component: Item {
            anchors.fill: parent
        }
    }

    HeaderMenuButton {
        id: menu_btn
        y: View.statusBarHeight
        x: View.layoutDirection==Qt.LeftToRight? 0 : parent.width - width
        ratio: menu.ratio
        onClicked: {
            if(menu.isVisible)
                menu.close()
            else
                menu.show()
        }
    }

//    Component.onCompleted: View.layoutDirection = Qt.RightToLeft
}
