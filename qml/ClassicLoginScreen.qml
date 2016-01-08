import QtQuick 2.0
import AsemanTools 1.0
import QtGraphicalEffects 1.0

Rectangle {
    id: classic_login
    width: 100
    height: 62
    color: "#000000"

    property int step: 0
    property int lastStep: 0

    onStepChanged: {
        if(step > lastStep)
            BackHandler.pushHandler(classic_login, function(){step--})
        if(step == 1) {
            cls_number.start()
        }
        if(step == 2) {
            cls_code.start()
            cls_number.stopProgress()
        }
        if(step < lastStep) {
            cls_number.stopProgress()
            cls_code.stopProgress()
            core.reinitTelegram()
        }

        lastStep = step
    }

    Behavior on y {
        NumberAnimation{easing.type: Easing.OutCubic; duration: 400}
    }

    ClassicLoginScreenStart {
        width: parent.width
        height: parent.height
        scale: step<1? 1 : 0.9
        transformOrigin: Item.Bottom
        onStart: {
            stg.pushAction("login-start")
            moveToNumber()
        }

        Behavior on scale {
            NumberAnimation {easing.type: Easing.OutCubic; duration: 400}
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: step<1? 0 : 0.5

        Behavior on opacity {
            NumberAnimation {easing.type: Easing.OutCubic; duration: 400}
        }
    }

    ClassicLoginScreenNumber {
        id: cls_number
        width: parent.width
        height: parent.height
        y: step<1? height: 0
        scale: step<2? 1 : 0.9
        transformOrigin: Item.Bottom
        visible: !init_timer.running
        onDone: {
            moveToCode(countryCode + phoneNumber)
            stg.pushAction("login-phone-done")
        }

        Behavior on y {
            NumberAnimation {easing.type: Easing.OutCubic; duration: 400}
        }
        Behavior on scale {
            NumberAnimation {easing.type: Easing.OutCubic; duration: 400}
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: step<2? 0 : 0.5

        Behavior on opacity {
            NumberAnimation {easing.type: Easing.OutCubic; duration: 400}
        }
    }

    ClassicLoginScreenCode {
        id: cls_code
        width: parent.width
        height: parent.height
        y: step<2? height: 0
        visible: !init_timer.running
        onDone: {
            telegram.authSignIn(code)
            stg.pushAction("login-code-done")
        }

        Behavior on y {
            NumberAnimation {easing.type: Easing.OutCubic; duration: 400}
        }
        Behavior on scale {
            NumberAnimation {easing.type: Easing.OutCubic; duration: 400}
        }
    }

    Timer {
        id: init_timer
        interval: 400
        Component.onCompleted: restart()
    }

    Timer {
        id: destroy_timer
        interval: 400
        onTriggered: classic_login.destroy()
    }

    function moveToStart() {
        visible = true
        step = 0
    }

    function moveToNumber() {
        visible = true
        step = 1
    }

    function moveToCode(phoneNumber) {
        visible = true
        step = 2
        cls_number.stop()
        cls_code.phoneNumber = phoneNumber
    }

    function finish() {
        y = height
        destroy_timer.restart()
    }

    Component.onCompleted: {
        stg.pushAction("login-begin")
    }
}

