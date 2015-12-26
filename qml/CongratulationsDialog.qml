import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: cong
    opacity: dialog.opacity
    anchors.fill: parent
    z: 100

    property bool open: false

    onOpenChanged: {
        if(open) {
            BackHandler.pushHandler(cong, function(){open = false})
        } else {
            BackHandler.removeHandler(cong)
            exit_timer.restart()
        }
    }

    Timer {
        id: exit_timer
        interval: 300
        onTriggered: cong.destroy()
    }

    Rectangle {
        anchors.fill: parent
        opacity: 0.5
    }

    Item {
        id: dialog
        anchors.centerIn: parent
        width: {
            var result = 400*Devices.density
            if(result > parent.width)
                result = parent.width
            return result
        }
        height: width
        scale: open? 1 : 0.9
        opacity: (scale-0.9)*10

        Behavior on scale {
            NumberAnimation {easing.type: Easing.OutCubic; duration: 300}
        }

        Image {
            anchors.fill: parent
            source: "img/congratulations.png"
            sourceSize: Qt.size(width*1.2,height*1.2)
        }

        Item {
            anchors.fill: parent
            anchors.topMargin: dialog.height*0.33
            anchors.bottomMargin: dialog.height*0.23
            anchors.leftMargin: dialog.width*0.13
            anchors.rightMargin: dialog.width*0.13

            Text {
                y: 10*Devices.density
                width: parent.width - dialog.width*0.18
                font.family: AsemanApp.globalFont.family
                font.pixelSize: 9*fontRatio*Devices.fontDensity
                color: "#333333"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTr("Your number wins SuperTelegram premium account.\n"+
                           "It means you can use our unlimited and premium features free.")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10*Devices.density
                normalColor: "#0d80ec"
                highlightColor: Qt.darker(normalColor, 1.1)
                textColor: "#ffffff"
                width: 80*Devices.density
                radius: 4*Devices.density
                text: qsTr("OK")
                onClicked: open = false
            }
        }

        Component.onCompleted: open = true
    }
}

