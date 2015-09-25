import QtQuick 2.0
import QtQuick.Controls.Styles 1.4
import AsemanTools 1.0

DialStyle {
    id: dstyle

    property color color: "#0d80ec"
    property bool reverse: false

    handleInset: control.width*0.07
    tickmarkInset: -15*Devices.density

    background: Rectangle {
        width: control.width
        height: control.height
        radius: width/2

        Column {
            anchors.centerIn: parent

            Text {
                id: time_text
                anchors.horizontalCenter: parent.horizontalCenter
                color: dstyle.color
                font.pixelSize: 50*Devices.density
                text: {
                    var value = Math.floor(control.value)
                    if(value == -1)
                        return ""
                    if(reverse)
                        value = control.maximumValue-value

                    var res = (value>=30? value-29 : (value%24)+1)
                    return res
                }
            }

            Text {
                id: time_type_text
                anchors.horizontalCenter: parent.horizontalCenter
                color: dstyle.color
                font.pixelSize: 20*Devices.density
                font.bold: true
                text: {
                    var value = Math.floor(control.value)
                    if(reverse)
                        value = control.maximumValue-value

                    if(value == -1)
                        return qsTr("Off")
                    else
                    if(value == 0)
                        return qsTr("Hour")
                    else
                    if(value < 24)
                        return qsTr("Hours")
                    else
                    if(value == 24)
                        return qsTr("Day")
                    else
                    if(value < 30)
                        return qsTr("Days")
                    else
                    if(value == 30)
                        return qsTr("Week")
                    else
                        return qsTr("Weeks")
                }
            }
        }
    }

    handle: Rectangle {
        width: control.width*0.12
        height: width
        radius: width/2
        color: "#ffffff"
        border.width: 2*Devices.density
        border.color: dstyle.color
    }

    tickmark: Rectangle {
        width: 6*Devices.density
        height: width
        radius: width/2
        color: "#ffffff"
    }
}

