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
    property real minHeaderHeight: Devices.standardTitleBarHeight + View.statusBarHeight
    property real maxHeaderHeight: ls_country.height
    property real statusBarHeight: View.statusBarHeight

    property bool needLogin: (telegram.authNeeded || telegram.authSignInError.length!=0 ||
              telegram.authSignUpError.length != 0) && telegram.authPhoneChecked

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
        opacity: (1-header.ratio)*0.8*ls_country.opacity
    }

    Rectangle {
        y: minHeaderHeight
        height: 3*Devices.density
        width: parent.width
        opacity: (1-header.ratio)*ls_country.opacity
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#55000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: minHeaderHeight
        clip: true

        LoginScreenCountrySelect {
            id: ls_country
            y: (opacity-1)*100*Devices.density
            width: parent.width
            height: parent.height
            ratio: header.ratio
            opacity: callingCode.length==0? 1 : 0
            visible: opacity != 0

            Behavior on opacity {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
            }
        }

        LoginScreenPhoneNumber {
            id: ls_phone
            width: parent.width
            height: parent.height
            opacity: ls_country.callingCode.length==0 || number.length!=0? 0 : 1
            visible: opacity != 0
            callingCode: ls_country.callingCode
            y: {
                if(ls_country.callingCode.length == 0)
                    return 100*Devices.density
                else
                if(number.length == 0)
                    return 0
                else
                    return -100*Devices.density
            }
            onNumberChanged: {
                Tools.deleteFile(telegram.configPath + "/" + number + "/auth" )
                telegram.phoneNumber = number
            }

            Behavior on opacity {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
            }
            Behavior on y {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
            }
        }

        LoginScreenEnterCode {
            id: ls_code
            width: parent.width
            height: parent.height
            opacity: login_scr.needLogin && code.length == 0? 1 : 0
            visible: opacity != 0
            y: {
                if(code.length != 0)
                    return -100*Devices.density
                else
                if(!login_scr.needLogin)
                    return 100*Devices.density
                else
                    return 0
            }
            onCodeChanged: if(code) telegram.authSignIn(code)

            Behavior on opacity {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
            }
            Behavior on y {
                NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
            }
        }
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
        font.pixelSize: 14*fontRatio*Devices.fontDensity
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
            fontPixelSize: 9*fontRatio*Devices.fontDensity
            buttonColor: "#0d80ec"
            buttonTextColor: "#ffffff"
        }
        onClicked: ls_country.gotoZero()
    }

    Indicator {
        id: indicator
        width: parent.width
        height: parent.height
        light: true
        modern: true
        indicatorSize: 30*Devices.density
        opacity: active? 1 : 0
        y: {
            if(ls_phone.number.length == 0)
                return 100*Devices.density
            else
            if(login_scr.needLogin)
                return -100*Devices.density
            else
                return 0
        }

        property bool active: (ls_phone.number.length != 0 || ls_code.code.length != 0) && !needLogin
        onActiveChanged: {
            if(active)
                start()
            else
                stop()
        }

        Behavior on opacity {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
        }
        Behavior on y {
            NumberAnimation{easing.type: Easing.OutCubic; duration: 300}
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            anchors.topMargin: 25*Devices.density
            font.pixelSize: 11*fontRatio*Devices.fontDensity
            color: "#ffffff"
            text: qsTr("Please Wait...")
        }
    }

    function moveToCode(phone) {
        ls_country.gotoZero()
        ls_country.callingCode = "+"
        ls_phone.number = phone
    }
}

