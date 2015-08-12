import QtQuick 2.0
import QtQuick.Controls 1.2 as QtControls
import AsemanTools.Controls 1.0 as Controls
import AsemanTools.Controls.Styles 1.0
import AsemanTools 1.0

Item {
    id: lspn
    width: 100
    height: 62

    property string callingCode
    property string number
    property variant phone_field

    onCallingCodeChanged: if(callingCode.length != 0) phone_field.focus = true

    onNumberChanged: {
        if(number.length == 0)
            BackHandler.removeHandler(lspn)
        else
            BackHandler.pushHandler(lspn, lspn.back)
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
            source: "img/phone.png"
        }

        Text {
            id: code_txt
            width: parent.width
            color: "#ffffff"
            font.pixelSize: 30*Devices.fontDensity
            text: "+" + callingCode
        }

        Item {
            id: phone_field_scene
            width: parent.width
            height: phone_field? phone_field.height : 30*Devices.density

            Component.onCompleted: {
                if(Devices.isDesktop)
                    phone_field = desktop_field.createObject(phone_field_scene)
                else
                    phone_field = mobile_field.createObject(phone_field_scene)
            }
        }

        Controls.Button {
            width: parent.width
            height: 42*Devices.density
            text: qsTr("Request Code")
            style: ButtonStyle {
                fontPixelSize: 10*Devices.fontDensity
                buttonColor: "#0d80ec"
            }
            onClicked: column.accept()
        }

        function accept() {
            var number = phone_field.text
            while(number.slice(0,1) == "0")
                number = number.slice(1,number.length)
            if(number.length == 0) {
                lspn.number = number
                showTooltip(qsTr("Invalid phone number!"))
                return
            }

            number = callingCode + number
            lspn.number = number
        }
    }

    function back() {
        number = ""
    }

    Component {
        id: desktop_field
        Controls.TextField {
            width: parent.width
            placeholderText: qsTr("Phone Number")
            font.pixelSize: 10*Devices.fontDensity
            validator: RegExpValidator{regExp: /\d*/}
            onAccepted: column.accept()
        }
    }

    Component {
        id: mobile_field
        QtControls.TextField {
            width: parent.width
            placeholderText: qsTr("Phone Number")
            textColor: "#ffffff"
            font.pixelSize: 10*Devices.fontDensity
            validator: RegExpValidator{regExp: /\d*/}
            onAccepted: column.accept()
        }
    }
}

