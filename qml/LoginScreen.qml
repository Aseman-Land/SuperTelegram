import QtQuick 2.0
import QtQuick.Controls 1.2 as QtControls
import AsemanTools.Controls 1.0 as Controls
import AsemanTools.Controls.Styles 1.0
import AsemanTools 1.0

Rectangle {
    id: login_scr
    width: 100
    height: 62

    property int steps: 0
    property real minHeaderHeight: standardTitleBarHeight + View.statusBarHeight
    property real maxHeaderHeight: ls_country.height
    property real statusBarHeight: View.statusBarHeight

    Item {
        id: header
        width: parent.height
        height: {
            var logicalHeight = -ls_country.contentY - ls_country.originY - maxHeaderHeight
            if(logicalHeight > maxHeaderHeight)
                return maxHeaderHeight
            else
            if(logicalHeight < minHeaderHeight)
                return minHeaderHeight
            else
                return logicalHeight
        }

        property real ratio: (header.height-minHeaderHeight)/(maxHeaderHeight-minHeaderHeight)
    }

    Image {
        id: back_img
        width: parent.width
        height: parent.height*1.1
        y: (header.ratio-1)*parent.height*0.1
        fillMode: Image.PreserveAspectCrop
        source: "img/login-back.jpg"
        sourceSize: Qt.size(width,height)
    }

    Rectangle {
        id: white_glass
        anchors.fill: parent
        anchors.topMargin: minHeaderHeight
        opacity: (1-header.ratio)*0.8
    }

    Rectangle {
        y: minHeaderHeight
        height: 3*Devices.density
        width: parent.width
        opacity: 1-header.ratio
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#55000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    LoginScreenCountrySelect {
        id: ls_country
        anchors.fill: parent
        anchors.topMargin: minHeaderHeight
        ratio: header.ratio
    }

    Image {
        width: height
        source: "img/stg.png"
        x: {
            var second = 10*Devices.density
            if(View.layoutDirection == Qt.RightToLeft)
                second = parent.width - width - second

            var first = parent.width/2 - width/2
            var delta = first-second
            return second + delta*header.ratio
        }
        y: {
            var second = minHeaderHeight/2-height/2+statusBarHeight/2
            var first = (parent.height-height)*0.5 - 10*Devices.density
            var delta = first-second
            return second + delta*header.ratio
        }
        height: {
            var second = minHeaderHeight*0.6
            var first = parent.width*0.4
            var delta = first-second
            return second + delta*header.ratio
        }
    }

    Text {
        text: "Super Telegram"
        font.pixelSize: 14*Devices.fontDensity
        color: "#ffffff"
        y: {
            var second = minHeaderHeight/2-height/2+statusBarHeight/2
            var first = parent.height*0.5+parent.width*0.2-10*Devices.density
            var delta = first-second
            return second + delta*Math.pow(header.ratio, 1)
        }
        x: {
            var second = minHeaderHeight + 8*Devices.density - statusBarHeight
            if(View.layoutDirection == Qt.RightToLeft)
                second = parent.width - width - second

            var first = parent.width/2 - width/2
            var delta = first-second
            return second + delta*Math.pow(header.ratio, 1)
        }
    }

    Controls.Button {
        id: try_btn
        y: parent.height - (50*Devices.density + height)*Math.pow(header.ratio,2)
        anchors.horizontalCenter: parent.horizontalCenter
        width: login_scr.width*0.5
        height: 42*Devices.density
        text: qsTr("Try It")
        style: ButtonStyle {
            fontPixelSize: 10*Devices.fontDensity
            buttonColor: "#0d80ec"
        }
        onClicked: ls_country.gotoZero()
    }

    Indicator {
        anchors.fill: parent
        light: false
        modern: true
        indicatorSize: 26*Devices.density

        property bool active: false
        onActiveChanged: {
            if(active)
                start()
            else
                stop()
        }
    }
}

