import QtQuick 2.0
import AsemanTools 1.0

Rectangle {
    id: mpage
    width: 100
    height: 62
    color: "#fefefe"

    property alias headerSidePad: profile.sidePad
    property alias headerColor: profile.headerColor

    MainListView {
        id: listv
        anchors.fill: parent
        headerHeight: profile.maxHeaderHeight
        scrollColor: profile.headerColor
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

