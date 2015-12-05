import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0 as Controls

Rectangle {
    id: configure
    color: "#fcfcfc"

    Text {
        id: title_txt
        width: parent.width - height - 6*Devices.density
        height: Devices.standardTitleBarHeight
        y: View.statusBarHeight
        x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width
        verticalAlignment: Text.AlignVCenter
        color: "#333333"
        font.family: AsemanApp.globalFont.family
        font.pixelSize: 14*Devices.fontDensity
    }

    AsemanFlickable {
        id: flickable
        width: parent.width
        anchors.top: title_txt.bottom
        anchors.bottom: parent.bottom
        flickableDirection: Flickable.VerticalFlick
        clip: true

        Column {
            anchors.horizontalCenter: parent.horizontalCenter

            Item { width: 1; height: 20*Devices.density }

            Text {
                id: language_txt
                anchors.horizontalCenter: parent.horizontalCenter
                width: flickable.width - 20*Devices.density
                height: 40*Devices.density
                verticalAlignment: Text.AlignVCenter
                color: "#333333"
                font.family: AsemanApp.globalFont.family
                font.pixelSize: 12*Devices.fontDensity
            }

            Repeater {
                model: stg.languages.length
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: flickable.width - 20*Devices.density
                    height: 40*Devices.density
                    color: marea.pressed? "#660d80ec" : "#00000000"
                    radius: 5*Devices.density

                    Row {
                        width: flickable.width - 40*Devices.density
                        height: 40*Devices.density
                        anchors.centerIn: parent
                        layoutDirection: View.layoutDirection
                        spacing: 8*Devices.density

                        Controls.CheckBox {
                            id: checkBox
                            anchors.verticalCenter: parent.verticalCenter
                            width: 32*Devices.density
                            height: 32*Devices.density
                            checked: stg.currentLanguage == txt.text
                        }

                        Text {
                            id: txt
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#333333"
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: 10*Devices.fontDensity
                            text: stg.languages[index]
                        }
                    }

                    MouseArea {
                        id: marea
                        anchors.fill: parent
                        onClicked: stg.currentLanguage = txt.text
                    }
                }
            }
        }
    }

    Rectangle {
        height: 4*Devices.density
        width: parent.width
        anchors.top: flickable.top
        z: 10
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#880d80ec" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    Connections {
        target: stg
        onCurrentLanguageChanged: initTranslations()
    }

    function initTranslations(){
        title_txt.text = qsTr("Configure")
        language_txt.text = qsTr("Languages")
    }

    Component.onDestruction: backButtonColor = "#ffffff"
    Component.onCompleted: {
        initTranslations()
        backButtonColor = "#333333"
    }
}

