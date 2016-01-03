import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls.Styles 1.0 as Styles
import QtQuick.Controls 1.2 as QtControls

Rectangle {
    width: 100
    height: 62

    property alias code: code_field.text
    property string phoneNumber

    signal done()

    onDone: {
        wait_rect.visible = true
        code_field.focus = false
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
                onClicked: done()
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

        Text {
            id: desc_txt
            width: parent.width
            font.family: AsemanApp.globalFont.family
            font.pixelSize: 9*Devices.fontDensity
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "#666666"
        }

        Item { width: 2; height: 10*Devices.density }

        QtControls.TextField {
            id: code_field
            width: parent.width
            validator: RegExpValidator{regExp: /\d*/}
            inputMethodHints: Qt.ImhDigitsOnly
            onAccepted: done()
            Component.onCompleted: if(Devices.isDesktop) style = textfield_style_component
        }

        Item { width: 2; height: 10*Devices.density }

        Text {
            width: parent.width
            font.family: AsemanApp.globalFont.family
            font.pixelSize: 9*Devices.fontDensity
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "#666666"
            text: qsTr("Timeout: <b>%1</b>").arg(time())
            function time() {
                var second = timer.second%60
                var minute = Math.floor(timer.second/60)
                if(second < 10)
                    second = "0" + second
                return minute + ":" + second
            }
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
                    id: sending
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: AsemanApp.globalFont.family
                    font.pixelSize: 9*Devices.fontDensity
                    color: "#333333"
                }
            }
        }
    }

    Timer {
        id: timer
        interval: 1000
        repeat: true
        onTriggered: {
            second--
            if(second <= 0)
                stop()
        }

        property int second: 0
    }

    function start() {
        code_field.forceActiveFocus()
        code_field.cursorPosition = 0
        timer.second = 2*60
        timer.restart()
    }

    Component {
        id: textfield_style_component
        Styles.TextFieldStyle{}
    }

    Connections {
        target: stg
        onCurrentLanguageChanged: initTranslations()
    }

    function initTranslations(){
        sending.text = qsTr("Sending code. Please wait...")
        desc_txt.text = qsTr("We've sent a SMS with an activation code to your phone <b>%1</b>").arg(phoneNumber)
        title.text = qsTr("Your code")
    }

    Component.onCompleted: {
        initTranslations()
    }
}

