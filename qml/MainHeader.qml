import QtQuick 2.0
import AsemanTools 1.0

Rectangle {
    id: header
    width: 100
    height: 62

    property real minHeaderHeight: 0
    property real maxHeaderHeight: 100
    property real statusBarHeight: 0

    property real ratio: (header.height-minHeaderHeight)/(maxHeaderHeight-minHeaderHeight)
    property alias source: img.source

    HeaderBluredBackground {
        anchors.fill: parent
        clip: true
        imageHeight: maxHeaderHeight
        source: img.source

        Rectangle {
            anchors.fill: parent
            opacity: (1-header.ratio)/2
            color: analizer.color

            ImageColorAnalizor {
                id: analizer
                source: img.source
                method: ImageColorAnalizor.MoreSaturation
            }
        }
    }

    Rectangle {
        id: shadow_rct
        height: 80*Devices.density
        width: parent.width
        anchors.bottom: parent.bottom
        opacity: header.ratio
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 0.9; color: mpage.color }
        }
    }

    Text {
        text: "Rosabell Sellers"
        font.pixelSize: 14*Devices.fontDensity
        color: "#ffffff"
        y: {
            var second = minHeaderHeight/2-height/2+statusBarHeight/2
            var first = parent.height*0.75+statusBarHeight*0.75
            var delta = first-second
            return second + delta*Math.pow(header.ratio, 0.5)
        }
        x: {
            var second = minHeaderHeight + 14*Devices.density - statusBarHeight
            var first = parent.width/2 - width/2
            var delta = first-second
            return second + delta*Math.pow(header.ratio, 1)
        }
    }

    Rectangle {
        id: rct
        width: height
        height: (parent.height-statusBarHeight)*(1 - 0.5*header.ratio) - 14*Devices.density
        radius: height/2
        x: 10*Devices.density + (parent.width/2 - width/2 - 10*Devices.density)*header.ratio
        color: mpage.color
        y: parent.height/2 - height/2 + statusBarHeight/2

        RoundedImage {
            id: img
            anchors.fill: parent
            anchors.margins: 2*Devices.density
            radius: height/2
            fillMode: Image.PreserveAspectCrop
        }
    }
}

