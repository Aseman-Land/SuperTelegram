import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls.Styles 1.0 as Styles
import QtQuick.Controls 1.2 as QtControls

Rectangle {
    id: item
    width: 100
    height: 62

    property string phoneNumber
    property alias countryCode: country_code_field.text

    signal done()

    onDone: phone_field.focus = false

    CountriesModel {
        id: countries_model
    }

    Header {
        id: header
        width: parent.width
        statusBar: true
        backButton: false
        shadow: true
        color: "#2CA5E0"

        Row {
            anchors.fill: parent
            anchors.topMargin: View.statusBarHeight
            layoutDirection: View.layoutDirection

            Item {width: 20*Devices.density; height: 1}

            Text {
                id: title
                verticalAlignment: Text.AlignVCenter
                height: parent.height
                width: parent.width - parent.height - 20*Devices.density
                font.family: AsemanApp.globalFont.family
                font.pixelSize: 13*Devices.fontDensity
                color: "#ffffff"
            }

            Button {
                height: parent.height
                width: height
                normalColor: "#00000000"
                highlightColor: "#66ffffff"
                icon: "img/ok-light.png"
                iconHeight: height/2
                onClicked: phone_field.accepted()
            }
        }
    }

    Column {
        id: column
        anchors.top: header.bottom
        anchors.topMargin: 30*Devices.density
        width: parent.width - 40*Devices.density
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4*Devices.density

        QtControls.ComboBox {
            id: countries_combo
            width: parent.width
            model: countries_model
            textRole: "name"
            Component.onCompleted: {
                currentIndex = countries_model.indexOf("iran")
                if(Devices.isDesktop)
                    style = combobox_style_component
            }
        }

        Row {
            width: parent.width
            spacing: 4*Devices.density

            QtControls.TextField {
                id: country_code_field
                width: height*2
                text: "+" + countries_model.get(countries_combo.currentIndex, CountriesModel.CallingCodeRole)
                readOnly: true
                Component.onCompleted: if(Devices.isDesktop) style = textfield_style_component
            }

            QtControls.TextField {
                id: phone_field
                width: parent.width - country_code_field.width - parent.spacing
//                inputMask: "D99 D99 9999;-"
                validator: RegExpValidator{regExp: /\d*/}
                inputMethodHints: Qt.ImhDigitsOnly
                Component.onCompleted: if(Devices.isDesktop) style = textfield_style_component
                onAccepted: {
                    var firstZero = true
                    var newText = ""
                    for(var i=0; i<text.length; i++) {
                        var ch = text[i]
                        if(firstZero) {
                            if(ch != "0") {
                                if(ch != " ")
                                    newText += ch
                                firstZero = false
                            }
                        } else {
                            if(ch != " ")
                                newText += ch
                        }
                    }

                    phoneNumber = newText

                    if(newText.length!=10) {
                        messageDialog.show(invalid_phone_component)
                    } else {
                        var number = countryCode + phoneNumber
                        telegram.phoneNumber = number
                        Tools.deleteFile(telegram.configPath + "/" + number + "/auth" )
                        wait_rect.visible = true
                    }
                }
            }
        }

        Item { width: 2; height: 10*Devices.density }

        Text {
            id: example_txt
            width: parent.width
            font.family: AsemanApp.globalFont.family
            font.pixelSize: 9*Devices.fontDensity
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Text {
            id: please_txt
            width: parent.width
            font.family: AsemanApp.globalFont.family
            font.pixelSize: 9*Devices.fontDensity
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "#666666"
        }
    }

    Rectangle {
        id: wait_rect
        anchors.fill: parent
        color: "#88000000"
        visible: false

        MouseArea {
            anchors.fill: parent
        }

        Rectangle {
            width: wait_row.width + 40*Devices.density
            height: wait_row.height + 40*Devices.density
            radius: 5*Devices.density
            anchors.centerIn: parent

            Row {
                id: wait_row
                anchors.centerIn: parent
                spacing: 8*Devices.density

                Indicator {
                    id: wait_indict
                    height: 22*Devices.density
                    width: height
                    indicatorSize: height
                    light: false
                    modern: true
                    running: wait_rect.visible
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: wait
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#333333"
                }
            }
        }
    }

    function start() {
        phone_field.forceActiveFocus()
        phone_field.cursorPosition = 0
    }

    function stop() {
        wait_rect.visible = false
    }

    Component {
        id: combobox_style_component
        Styles.ComboBoxStyle{}
    }

    Component {
        id: textfield_style_component
        Styles.TextFieldStyle{}
    }

    Component {
        id: invalid_phone_component

        Column {
            id: column
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right

            Text {
                id: invalid_error
                width: main.width - 40*Devices.density
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 10*Devices.density
                font.family: AsemanApp.globalFont.family
                font.pixelSize: 9*fontRatio*Devices.fontDensity
                color: "#333333"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTr("Invalid phone number!")
            }

            Row {
                anchors.right: parent.right

                Button {
                    id: ok_btn
                    textFont.family: AsemanApp.globalFont.family
                    textFont.pixelSize: 10*fontRatio*Devices.fontDensity
                    textColor: "#0d80ec"
                    normalColor: "#00000000"
                    highlightColor: "#660d80ec"
                    onClicked: messageDialog.hide()
                    text: qsTr("OK")
                }
            }
        }
    }

    Connections {
        target: stg
        onCurrentLanguageChanged: initTranslations()
    }

    function initTranslations(){
        wait.text = qsTr("Requesting code. Please wait...")
        title.text = qsTr("Your phone")
        please_txt.text = qsTr("Please confirm your country code and enter your phone number.")
        example_txt.text = qsTr("Example: 912 345 6789")
    }

    Component.onCompleted: {
        initTranslations()
    }
}

