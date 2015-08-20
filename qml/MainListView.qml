import QtQuick 2.0
import AsemanTools 1.0
import "features/"

Item {
    id: mainlv
    width: 100
    height: 62
    clip: true

    property alias contentY: listv.contentY
    property real headerHeight: 200
    property alias originY: listv.originY
    property alias interactive: listv.interactive

    property alias scrollColor: scrollbar.color

    signal selected(variant component)

    ListView {
        id: listv
        width: parent.width
        height: parent.height - y
        model: ListModel{}
        maximumFlickVelocity: View.flickVelocity
        boundsBehavior: Flickable.StopAtBounds
        rebound: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 0
            }
        }
        clip: true

        property real itemsHeight: 64*Devices.density
        property bool atBegin: atYBeginning
        onAtBeginChanged: {
            if(atBegin)
                BackHandler.removeHandler(listv)
            else
                BackHandler.pushHandler(listv, listv.gotoBegin)
        }

        header: Item {
            width: parent.width
            height: headerHeight
        }

        footer: Item {
            width: parent.width
            height: {
                var res = mainlv.height-listv.count*listv.itemsHeight-standardTitleBarHeight
                if(res < 0)
                    return 0
                else
                    return res
            }
        }

        delegate: Item {
            width: listv.width
            height: listv.itemsHeight

            Rectangle {
                anchors.fill: parent
                anchors.margins: 6*Devices.density
                radius: 4*Devices.density
                color: "#0d80ec"
                opacity: marea.pressed? 0.2 : 0
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20*Devices.density
                layoutDirection: View.layoutDirection
                spacing: 10*Devices.density

                Rectangle {
                    id: pic_frame
                    anchors.verticalCenter: parent.verticalCenter
                    border.color: "#d5d5d5"
                    border.width: 1*Devices.density
                    height: 46*Devices.density
                    color: "#e5e5e5"
                    width: height
                    radius: width/2

                    Image {
                        anchors.fill: parent
                        anchors.margins: 8*Devices.density
                        source: icon
                        sourceSize: Qt.size(width, height)
                    }
                }

                Column {
                    spacing: 2*Devices.density
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - parent.spacing - pic_frame.width

                    Text {
                        width: parent.width
                        horizontalAlignment: View.layoutDirection==Qt.RightToLeft? Text.AlignRight : Text.AlignLeft
                        text: name
                        font.pixelSize: 11*Devices.fontDensity
                        color: "#333333"
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: View.layoutDirection==Qt.RightToLeft? Text.AlignRight : Text.AlignLeft
                        text: description
                        font.pixelSize: 9*Devices.fontDensity
                        color: "#aaaaaa"
                        wrapMode: Text.WrapAnywhere
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: mainlv.selected(component)
            }
        }

        NumberAnimation { id: anim; target: listv; easing.type: Easing.OutCubic; property: "contentY"; duration: 400 }

        function gotoBegin() {
            anim.from = contentY;
            anim.to = -headerHeight;
            anim.running = true;
        }
    }

    ScrollBar {
        id: scrollbar
        scrollArea: listv; height: listv.height-headerHeight; width: 6*Devices.density
        anchors.topMargin: headerHeight; anchors.top: listv.top; color: "#333333"
        x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width
    }

    Timer {
        interval: 100
        onTriggered: listv.positionViewAtBeginning()
        Component.onCompleted: start()
    }

    function gotoBegin() {
        listv.gotoBegin()
    }

    Component.onCompleted: {
        listv.model.append({"name": qsTr("Timer message")            , "icon": "features/icons/timer-message.png"        ,"component": time_msg_component, "description": qsTr("Send a message in the selected time to any user")})
        listv.model.append({"name": qsTr("Auto message")             , "icon": "features/icons/auto-message.png"         ,"component": time_msg_component, "description": qsTr("Send a message automatically when you have incomming messages.")})
        listv.model.append({"name": qsTr("Content sensitive message"), "icon": "features/icons/content-sens-message.png" ,"component": time_msg_component, "description": qsTr("Send word sensitive messages automatically.")})
        listv.model.append({"name": qsTr("Backup")                   , "icon": "features/icons/backup.png"               ,"component": time_msg_component, "description": qsTr("Backup from a special contacts.")})
        listv.model.append({"name": qsTr("Sticker manager")          , "icon": "features/icons/sticker-manager.png"      ,"component": time_msg_component, "description": qsTr("Manage your installed sticker sets.")})
        listv.model.append({"name": qsTr("Profile picture changer")  , "icon": "features/icons/profile-pic-changer.png"  ,"component": time_msg_component, "description": qsTr("Change your profile picture frequently.")})
        listv.model.append({"name": qsTr("Mute timer")               , "icon": "features/icons/mute-timer.png"           ,"component": time_msg_component, "description": qsTr("Mute a contact in the special day time.")})
        listv.model.append({"name": qsTr("Save avatars")             , "icon": "features/icons/save-avatars.png"         ,"component": time_msg_component, "description": qsTr("Save contact avatars automatically.")})
        listv.model.append({"name": qsTr("Usage info")               , "icon": "features/icons/usage-info.png"           ,"component": time_msg_component, "description": qsTr("Your usage informations.")})
        listv.model.append({"name": qsTr("Auto check-in")            , "icon": "features/icons/auto-checkin.png"         ,"component": time_msg_component, "description": qsTr("Send your geo position to selected contacts automatically.")})
        listv.model.append({"name": qsTr("Send to all")              , "icon": "features/icons/send-to-all.png"          ,"component": time_msg_component, "description": qsTr("Send a message to all or selected contacts.")})
    }

    Component {
        id: time_msg_component
        TimerMessage {}
    }
}

