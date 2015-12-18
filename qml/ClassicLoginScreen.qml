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
        if(step == 1)
            cls_number.start()
        if(step == 2)
            cls_code.start()

        lastStep = step
    }

    ClassicLoginScreenStart {
        width: parent.width
        height: parent.height
        scale: step<1? 1 : 0.9
        transformOrigin: Item.Bottom
        onStart: step = 1

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
        onDone: moveToCode(countryCode + phoneNumber)

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
        scale: step<3? 1 : 0.9
        transformOrigin: Item.Bottom
        visible: !init_timer.running
        onDone: step++

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

    function moveToStart() {
        visible = true
        step = 1
    }

    function moveToCode(phoneNumber) {
        visible = true
        step = 2
        cls_code.phoneNumber = phoneNumber
    }

    function moveToNumber() {
        visible = true
        step = 3
    }
}

