import QtQuick 2.0
import QtQuick.Controls 1.2 as QtControls
import AsemanTools.Controls 1.0 as Controls
import AsemanTools.Controls.Styles 1.0
import AsemanTools 1.0

Item {
    id: country_select
    width: 100
    height: 62

    property real ratio: 1
    property alias contentY: listv.contentY
    property alias originY: listv.originY
    property string callingCode

    onCallingCodeChanged: {
        if(callingCode == "")
            BackHandler.removeHandler(country_select)
        else
            BackHandler.pushHandler(country_select, country_select.back)
    }

    AsemanListView {
        id: listv
        anchors.fill: parent
        model: CountriesModel{}
        clip: true

        property bool atBegin: atYBeginning
        onAtBeginChanged: {
            if(atBegin)
                BackHandler.removeHandler(listv)
            else
                BackHandler.pushHandler(listv, country_select.gotoBegin)
        }

        header: Item {
            width: listv.width
            height: listv.height
        }

        delegate: Item {
            width: listv.width
            height: 50*Devices.density
            clip: true

            Rectangle {
                anchors.fill: parent
                anchors.margins: 6*Devices.density
                radius: 4*Devices.density
                color: "#0d80ec"
                opacity: marea.pressed? 0.2 : 0
            }

            Text {
                anchors.centerIn: parent
                color: "#333333"
                font.pixelSize: 10*fontRatio*Devices.fontDensity
                text: name
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: country_select.callingCode = model.callingCode
            }
        }

        NumberAnimation { id: anim; target: listv; easing.type: Easing.OutCubic; property: "contentY"; duration: 300 }

        Timer {
            interval: 100
            onTriggered: listv.positionViewAtBeginning()
            Component.onCompleted: start()
        }
    }

    ScrollBar {
        id: scrollbar
        scrollArea: listv; height: listv.height; width: 6*Devices.density
        anchors.top: listv.top; color: "#333333"
        x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height*0.1
        spacing: 4*Devices.density
        opacity: ratio

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ffffff"
            font.pixelSize: 17*fontRatio*Devices.fontDensity
            text: qsTr("Make Telegram Easier")
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ffffff"
            font.pixelSize: 11*fontRatio*Devices.fontDensity
            text: qsTr("Many useful tools for telegram")
        }
    }

    function gotoBegin() {
        anim.from = contentY;
        anim.to = -height;
        anim.running = true;
    }

    function gotoZero() {
        anim.from = contentY;
        anim.to = 0;
        anim.running = true;
    }

    function positionViewAtBeginning() {
        listv.positionViewAtBeginning()
    }

    function back() {
        callingCode = ""
    }
}

