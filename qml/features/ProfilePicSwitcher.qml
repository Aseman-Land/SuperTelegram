import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0
import QtQuick.Extras 1.4
import "../"

PageManagerItem {
    headerY: headerHeight + titleBarHeight
    anchors.fill: parent
    headColor: main.color
    backgroundColor: "#fefefe"

    property real headerHeight: width*0.6
    property real titleBarHeight: View.statusBarHeight + standardTitleBarHeight

    Rectangle {
        anchors.fill: parent
        color: backgroundColor
    }

    ProfilePicSwitcherModel {
        id: ppmodel
        folder: stg.picturesLocation + "/ProfilePicSwitcher"
        database: stg.database
        onTimerChanged: time_slider.value = timer
    }

    AsemanGridView {
        id: listv
        anchors.fill: parent
        anchors.topMargin: titleBarHeight
        model: ppmodel
        header: Item {width: listv.width; height: headerHeight}
        cellHeight: cellWidth
        cellWidth: width/Math.floor(width/(128*Devices.density))

        property real ratio: {
            if(headerHeight == 0)
                return 0
            var res = -contentY/headerHeight
            if(res < 0)
                res = 0
            return res
        }

        delegate: Image {
            width: listv.cellWidth
            height: width
            source: path
            sourceSize: Qt.size(width*2, height*2)
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
        }
        Component.onCompleted: positionViewAtBeginning()
    }

    ScrollBar {
        scrollArea: listv; width: 6*Devices.density
        x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width;
        anchors.top: listv.top; color: main.color
        anchors.topMargin: headerHeight; anchors.bottom: listv.bottom
    }

    MaterialDesignButton {
        anchors.fill: parent
        flickable: listv
        color: headColor
        hasMenu: false
        onClicked: {
            if(Devices.isDesktop) {
                var path = Desktop.getOpenFileName(0, qsTr("Select file"));
                ppmodel.add(path)
            } else {

            }
        }
    }

    Rectangle {
        width: parent.width
        height: titleBarHeight + headerHeight*listv.ratio
        color: headColor

        Item {
            anchors.fill: parent
            anchors.topMargin: titleBarHeight

            Dial {
                id: time_slider
                height: headerHeight*0.8
                width: height
                anchors.centerIn: parent
                minimumValue: -1
                maximumValue: 32
                style: ProfilePictureDialStyle {color: headColor}
                onValueChanged: ppmodel.timer = Math.floor(value)
                scale: parent.height/headerHeight
                opacity: scale
                visible: opacity != 0
            }
        }

        Item {
            width: parent.width - height - 6*Devices.density
            height: standardTitleBarHeight
            y: View.statusBarHeight
            x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width

            Text {
                id: header_txt
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14*Devices.fontDensity
                color: backButtonColor
                x: View.layoutDirection==Qt.RightToLeft? parent.width-width : 0
                text: qsTr("Picture switcher")
            }
        }

        Rectangle {
            height: 3*Devices.density
            width: parent.width
            anchors.top: parent.bottom
            z: 10
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#55000000" }
                GradientStop { position: 1.0; color: "#00000000" }
            }
        }
    }
}

