import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: header
    width: 100
    height: 62

    property real minHeaderHeight: 0
    property real maxHeaderHeight: 100
    property real statusBarHeight: 0

    property real sidePad: 0

    property real ratio: (header.height-minHeaderHeight)/(maxHeaderHeight-minHeaderHeight)
    property alias source: img.source

    property alias headerColor: tbar.color

    Rectangle {
        height: 3*Devices.density
        width: parent.width
        anchors.top: parent.bottom
        opacity: 1-parent.ratio
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#55000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    Item {
        anchors.fill: parent
        clip: true

        HeaderBluredBackground {
            anchors.fill: parent
            clip: true
            imageHeight: maxHeaderHeight
            source: img.source
            color: "#ffffff"

            Rectangle {
                id: tbar
                anchors.fill: parent
                opacity: (1-header.ratio)*1
                color: {
//                    return "#CC5633"
                    var clr = analizer.color
                    var ratio = 1.1
                    var oRatio = 0.8
                    if(clr.r > clr.g && clr.r > clr.b)
                        clr = Qt.rgba(clr.r*ratio, clr.g*oRatio, clr.b*oRatio)
                    else
                    if(clr.g > clr.r && clr.g > clr.b)
                        clr = Qt.rgba(clr.r*oRatio, clr.g*ratio, clr.b*oRatio)
                    else
                    if(clr.b > clr.g && clr.b > clr.r)
                        clr = Qt.rgba(clr.r*oRatio, clr.g*oRatio, clr.b*ratio)

                    var saturation = Tools.colorSaturation(clr)
                    var lightness = Tools.colorLightness(clr)
                    var hue = Tools.colorHue(clr)
                    if(saturation > 0.6)
                        saturation = 0.6
                    if(lightness < 0.4)
                        lightness = 0.4

                    return Qt.hsla(hue, saturation, lightness, 1)
                }

                ImageColorAnalizor {
                    id: analizer
                    source: img.source
                    method: ImageColorAnalizor.MoreSaturation
                }

                Behavior on color {
                    ColorAnimation{easing.type: Easing.OutCubic; duration: 400}
                }
            }
        }

        Rectangle {
            id: shadow_rct
            height: 80*Devices.density
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -2*Devices.density
            opacity: header.ratio
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00000000" }
                GradientStop { position: 0.9; color: mpage.color }
            }
        }
    }

    Text {
        text: main.telegram.myUser? (main.telegram.myUser.firstName + " " + main.telegram.myUser.lastName).trim() : qsTr("Updating...")
        font.pixelSize: 14*fontRatio*Devices.fontDensity
        color: "#ffffff"
        y: {
            var second = minHeaderHeight/2-height/2+statusBarHeight/2
            var first = parent.height*0.75+statusBarHeight*0.75
            var delta = first-second
            return second + delta*Math.pow(header.ratio, 0.5)
        }
        x: {
            var second = minHeaderHeight + 8*Devices.density - statusBarHeight + sidePad
            if(View.layoutDirection == Qt.RightToLeft)
                second = parent.width - width - second

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
        color: "#ffffff"
        y: parent.height/2 - height/2 + statusBarHeight/2
        x: {
            var second = 10*Devices.density + sidePad
            if(View.layoutDirection == Qt.RightToLeft)
                second = parent.width - width - second

            var first = parent.width/2 - width/2
            var delta = first-second
            return second + delta*header.ratio
        }

        ProfilePicture {
            id: img
            anchors.fill: parent
            anchors.margins: 2*Devices.density
            radius: height/2
            fillMode: Image.PreserveAspectCrop
            telegram: main.telegram
            user: main.telegram.myUser
            isChat: false
            source: {
                if(main.telegram.myUser)
                    return handlerSource
                var cached = AsemanApp.readSetting("General/mypic")
                if(cached == null)
                    return handlerSource
                else
                    return cached
            }

            onSourceChanged: if(main.telegram.myUser) AsemanApp.setSetting("General/mypic", handlerSource)
        }
    }
}

