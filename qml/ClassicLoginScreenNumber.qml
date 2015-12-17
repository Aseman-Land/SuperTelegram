import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls.Styles 1.0 as Styles
import QtQuick.Controls 1.2 as QtControls

Rectangle {
    width: 100
    height: 62

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

        Text {
            y: View.statusBarHeight
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            height: Devices.standardTitleBarHeight
            width: parent.width - 40*Devices.density
            font.family: AsemanApp.globalFont.family
            font.pixelSize: 13*Devices.fontDensity
            color: "#ffffff"
            text: qsTr("Your phone")
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
                width: parent.width - country_code_field.width - parent.spacing
                Component.onCompleted: if(Devices.isDesktop) style = textfield_style_component
            }
        }

        Text {
            width: parent.width
            font.family: AsemanApp.globalFont.family
            font.pixelSize: 9*Devices.fontDensity
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "#888888"
            text: qsTr("Please confirm your country code and enter your phone number.")
        }
    }

    Component {
        id: combobox_style_component
        Styles.ComboBoxStyle{}
    }

    Component {
        id: textfield_style_component
        Styles.TextFieldStyle{}
    }
}

