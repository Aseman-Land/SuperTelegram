import QtQuick 2.0
import AsemanTools 1.0
import TelegramQmlLib 1.0

Item {
    id: item
    width: 100
    height: 64*Devices.density

    property alias telegram: pic_frame.telegram
    property alias dialog: pic_frame.dialog

    property alias isChat: pic_frame.isChat
    property alias user: pic_frame.user
    property alias chat: pic_frame.chat

    property alias description: desc_text.text
    property alias name: name_text.text

    property real typeUserStatusOffline: 0x8c703f
    property real typeUserStatusEmpty: 0x9d05049
    property real typeUserStatusOnline: 0xedb93949
    property real typeUserStatusRecently: 0xe26f42f1
    property real typeUserStatusLastWeek: 0x7bf09fc
    property real typeUserStatusLastMonth: 0x77ebc742

    property bool selected: false

    signal clicked()

    Rectangle {
        anchors.fill: parent
        anchors.margins: 6*Devices.density
        radius: 4*Devices.density
        color: "#0d80ec"
        opacity: marea.pressed || selected? 0.2 : 0
    }

    Row {
        width: parent.width - 40*Devices.density
        anchors.centerIn: parent
        layoutDirection: View.layoutDirection
        spacing: 10*Devices.density
        height: parent.height

        ProfilePicture {
            id: pic_frame
            radius: height/2
            width: height
            height: 46*Devices.density
            anchors.verticalCenter: parent.verticalCenter
            sourceSize: Qt.size(width*2, height*2)
        }

        Column {
            spacing: 2*Devices.density
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - parent.spacing - pic_frame.width
            height: parent.height

            Text {
                id: name_text
                width: parent.width
                height: parent.height/2
                verticalAlignment: Text.AlignBottom
                horizontalAlignment: View.layoutDirection==Qt.RightToLeft? Text.AlignRight : Text.AlignLeft
                font.pixelSize: 11*fontRatio*Devices.fontDensity
                font.family: AsemanApp.globalFont.family
                color: "#333333"
                textFormat: Text.RichText
                text: {
                    var result = ""
                    if(pic_frame.isChat)
                        result = pic_frame.chat.title
                    else
                        result = pic_frame.user.firstName + " " + pic_frame.user.lastName
                    result = result.trim()
                    return emojis.textToEmojiText(result,16*Devices.density,true,Devices.isAndroid)
                }
            }

            Text {
                id: desc_text
                width: parent.width
                height: parent.height/2
                verticalAlignment: Text.AlignTop
                horizontalAlignment: View.layoutDirection==Qt.RightToLeft? Text.AlignRight : Text.AlignLeft
                font.pixelSize: 9*fontRatio*Devices.fontDensity
                font.family: AsemanApp.globalFont.family
                color: "#aaaaaa"
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideRight
                maximumLineCount: 1
                text: {
                    var result = ""
                    if( pic_frame.isChat ) {
                        result += qsTr("%1 participants").arg(pic_frame.chat.participantsCount)
                    } else {
                        switch(pic_frame.user.status.classType)
                        {
                        case typeUserStatusRecently:
                            result = qsTr("Recently")
                            break;
                        case typeUserStatusLastMonth:
                            result = qsTr("Last Month")
                            break;
                        case typeUserStatusLastWeek:
                            result = qsTr("Last Week")
                            break;
                        case typeUserStatusOnline:
                            result = qsTr("Online")
                            break;
                        case typeUserStatusOffline:
                            result = qsTr("%1 was online").arg(stg.getTimeString(CalendarConv.fromTime_t(pic_frame.user.status.wasOnline)))
                            break;
                        }
                    }

                    return result
                }
            }
        }
    }

    MouseArea {
        id: marea
        anchors.fill: parent
        onClicked: item.clicked()
    }
}

