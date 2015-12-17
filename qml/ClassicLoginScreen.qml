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
        width: parent.width
        height: parent.height
        y: step<1? height: 0

        Behavior on y {
            NumberAnimation {easing.type: Easing.OutCubic; duration: 400}
        }
    }
}

