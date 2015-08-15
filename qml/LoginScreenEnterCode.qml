import QtQuick 2.0
import QtQuick.Controls 1.2 as QtControls
import AsemanTools.Controls 1.0 as Controls
import AsemanTools.Controls.Styles 1.0
import AsemanTools 1.0

Item {
    id: lsec

    property string code
    property variant code_field

    onCodeChanged: {
        if(code.length == 0)
            BackHandler.removeHandler(lsec)
        else
            BackHandler.pushHandler(lsec, lsec.back)
    }

    Column {
        id: column
        y: 40*Devices.density
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width*0.8
        spacing: 8*Devices.density

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width*0.5
            height: width
            sourceSize: Qt.size(width, height)
            source: "img/code.png"
        }

        Item {
            id: phone_field_scene
            width: parent.width
            height: code_field? code_field.height : 30*Devices.density

            Component.onCompleted: {
                if(Devices.isDesktop)
                    code_field = desktop_field.createObject(phone_field_scene)
                else
                    code_field = mobile_field.createObject(phone_field_scene)
            }
        }

        Controls.Button {
            width: parent.width
            height: 42*Devices.density
            text: qsTr("Login")
            style: ButtonStyle {
                fontPixelSize: 10*Devices.fontDensity
                buttonColor: "#0d80ec"
            }
            onClicked: column.accept()
        }

        function accept() {
            var code = code_field.text
            if(code.length == 0) {
                lsec.code = code
                showTooltip(qsTr("Invalid code!"))
                return
            }

            lsec.code = code
        }
    }

    function back() {
        code = ""
    }

    Component {
        id: desktop_field
        Controls.TextField {
            width: parent.width
            placeholderText: qsTr("Code")
            font.pixelSize: 10*Devices.fontDensity
            validator: RegExpValidator{regExp: /\d*/}
            onAccepted: column.accept()
        }
    }

    Component {
        id: mobile_field
        QtControls.TextField {
            width: parent.width
            placeholderText: qsTr("Code")
            textColor: "#ffffff"
            font.pixelSize: 10*Devices.fontDensity
            validator: RegExpValidator{regExp: /\d*/}
            onAccepted: column.accept()
        }
    }
}

