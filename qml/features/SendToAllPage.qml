import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0
import "../"

FeaturePageType1 {
    id: bmng
    model: dmodel
    activeIndicator: dmodel.initializing
    disableMaterialDesign: true

    text: {
        if(editMode)
            return dialogIsNull? qsTr("Insert Message") : dialogName
        else
            return qsTr("Send To All")
    }

    ListObject {
        id: list
    }

    HashObject {
        id: hash
    }

    ContactsModel {
        id: dmodel
        telegram: tg
    }

    Button {
        y: View.statusBarHeight
        x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width
        height: Devices.standardTitleBarHeight
        width: height
        normalColor: "#00000000"
        highlightColor: "#66ffffff"
        icon: "../img/ok-light.png"
        iconHeight: height/2
        visible: !editMode && !activeIndicator && list.count>0 && !indicator.running
        z: 100
        onClicked: editMode = true
    }

    itemDelegate: DialogListItem {
        id: item
        width: bmng.width
        user: dmodel.telegram.user(model.item.userId)
        isChat: false
        telegram: dmodel.telegram
        selected: list.contains(user)
        onClicked: {
            selected = !selected
            if(selected)
                list.append(user)
            else
                list.removeAll(user)
        }

        Connections {
            target: list
            onCountChanged: item.selected = list.contains(item.user)
        }
    }

    editDelegate: Column {
        id: edit_panel
        width: bmng.width
        y: Devices.standardTitleBarHeight + View.statusBarHeight
        visible: parent.destHeight == parent.height

        StgTextArea {
            id: txt
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*Devices.density
            height: 160*Devices.density
        }

        DialogButtons {
            id: buttons_panel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*Devices.density
            onCancel: editMode = false
            onDone: {
                progress_area.start(txt.text)
                editMode = false
            }
        }
    }

    Rectangle {
        id: progress_area
        anchors.fill: parent
        color: "#aa000000"
        z: 20
        visible: indicator.running

        property string message
        property int startCount

        function start(msg) {
            if(msg.trim() == "")
                return

            indicator.running = true
            startCount = list.count
            message = msg
            next()
        }

        function next() {
            if(list.count == 0) {
                indicator.running = false
                return
            }

            var user = list.takeFirst()
            pbar_txt.text = (user.firstName + " " + user.lastName).trim()

            var reqId = dmodel.telegram.sendMessage(user.id, message)
            hash.insert(reqId, user)
            timout.restart()
        }

        Connections {
            target: dmodel.telegram
            onMessageSent: {
                if(!hash.contains(reqId))
                    return

                progress_area.next()
            }
        }

        Timer {
            id: timout
            interval: 5000
            onTriggered: progress_area.next()
        }

        MouseArea {
            anchors.fill: parent
        }

        Indicator {
            id: indicator
            anchors.centerIn: parent
            modern: true
            light: true
            indicatorSize: 22*Devices.density
            running: false
        }

        Text {
            id: pbar_txt
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: pbar.top
            anchors.bottomMargin: 10*Devices.density
            font.pixelSize: 9*fontRatio*Devices.fontDensity
            font.family: AsemanApp.globalFont.family
            color: "#ffffff"
        }

        ProgressBar {
            id: pbar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 20*Devices.density
            percent: 100*(progress_area.startCount-list.count-hash.count)/progress_area.startCount
            topColor: "#0d80ec"
        }
    }
}

