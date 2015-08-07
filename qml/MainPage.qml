import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: mpage
    width: 100
    height: 62

    property alias headerSidePad: profile.sidePad
    property alias headerColor: profile.headerColor
    property alias color: back.color

    Rectangle {
        id: back
        width: parent.width
        height: parent.height - profile.height + 2*Devices.density
        anchors.bottom: parent.bottom
        color: "#fefefe"
    }

    MainListView {
        id: listv
        anchors.fill: parent
        headerHeight: profile.maxHeaderHeight
        scrollColor: profile.headerColor
    }

    MouseArea {
        anchors.fill: profile
        onClicked: listv.gotoBegin()
        visible: profile.ratio == 0
    }

    MainHeader {
        id: profile
        minHeaderHeight: standardTitleBarHeight + View.statusBarHeight
        maxHeaderHeight: mpage.height*0.6
        statusBarHeight: View.statusBarHeight
        width: parent.width
        source: "img/img.jpg"
        height: {
            var logicalHeight = -listv.contentY - listv.originY - maxHeaderHeight
            if(logicalHeight > maxHeaderHeight)
                return maxHeaderHeight
            else
            if(logicalHeight < minHeaderHeight)
                return minHeaderHeight
            else
                return logicalHeight
        }
    }
}

