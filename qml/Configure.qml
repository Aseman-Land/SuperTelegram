import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0 as Controls
import AsemanTools.Controls.Styles 1.0 as Styles

Rectangle {
    id: configure
    color: "#fcfcfc"


    Rectangle {
        id: title_bar
        width: parent.width
        height: Devices.standardTitleBarHeight + View.statusBarHeight
        color: "#333333"

        Text {
            id: title_txt
            width: parent.width - height - 6*Devices.density
            height: Devices.standardTitleBarHeight
            y: View.statusBarHeight
            x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width
            verticalAlignment: Text.AlignVCenter
            color: "#ffffff"
            font.family: AsemanApp.globalFont.family
            font.pixelSize: 14*fontRatio*Devices.fontDensity
        }
    }

    AsemanFlickable {
        id: flickable
        width: parent.width
        anchors.top: title_bar.bottom
        anchors.bottom: parent.bottom
        flickableDirection: Flickable.VerticalFlick
        clip: true
        contentHeight: flick_scene.height
        contentWidth: flick_scene.width

        Item {
            id: flick_scene
            width: flickable.width
            height: {
                var res = logout_btn.height + column.height + 10*Devices.density
                if(res < flickable.height)
                    res = flickable.height
                return res
            }

            Column {
                id: column
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
                    font.pixelSize: 12*fontRatio*Devices.fontDensity
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
                                font.pixelSize: 10*fontRatio*Devices.fontDensity
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

            Controls.Button {
                id: logout_btn
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 10*Devices.density
                width: parent.width*0.7
                height: 40*Devices.density
                text: qsTr("Log out")
                style: Styles.ButtonStyle {
                    fontPixelSize: 9*fontRatio*Devices.fontDensity
                    buttonColor: "#B70D0D"
                    buttonTextColor: "#ffffff"
                }
                onClicked: messageDialog.show(logout_warn_component)
            }
        }
    }

    Rectangle {
        height: 4*Devices.density
        width: parent.width
        anchors.top: flickable.top
        z: 10
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#33000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    Component {
        id: logout_warn_component
        LogoutWarning {}
    }

    Connections {
        target: stg
        onCurrentLanguageChanged: initTranslations()
    }

    function initTranslations(){
        title_txt.text = qsTr("Configure")
        language_txt.text = qsTr("Languages")
    }

    Component.onCompleted: {
        initTranslations()
    }
}

