import QtQuick 2.0
import AsemanTools 1.0
import AsemanTools.Controls 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0
import QtQuick.Extras 1.4
import "../"

FeaturePageType2 {
    id: ppic_switcher
    headerY: titleBarHeight
    anchors.fill: parent
    headColor: main.color
    backgroundColor: "#fefefe"
    property string description: qsTr("Switch you telegram profile picture automatically.\n" +
                                      "It switch your telegram profile picture in the" +
                                      " selected period and from the selected photos.")

    property real headerHeight: width*0.6
    property real titleBarHeight: View.statusBarHeight + Devices.standardTitleBarHeight
    property string editId

    property bool unlimited: store.premium || store.stg_ppic_unlimit_plus_IsPurchased

    text: {
        if(editMode)
            return qsTr("Delete Picture")
        else
            return qsTr("Picture switcher")
    }

    Rectangle {
        anchors.fill: parent
        color: backgroundColor
    }

    ProfilePicSwitcherModel {
        id: ppmodel
        folder: stg.profilePicSwitcherLocation
        database: stg.database
        onTimerChanged: time_slider.value = timer
    }

    AsemanGridView {
        id: listv
        anchors.fill: parent
        anchors.topMargin: titleBarHeight
        model: ppmodel
        header: Item {width: listv.width; height: headerHeight}
        cellHeight: cellWidth
        cellWidth: width/Math.floor(width/(128*Devices.density))

        property real ratio: {
            if(headerHeight == 0)
                return 0
            var res = -contentY/headerHeight
            if(res < 0)
                res = 0
            return res
        }

        delegate: Image {
            width: listv.cellWidth
            height: width
            source: path
            sourceSize: Qt.size(width*2, height*2)
            asynchronous: true
            fillMode: Image.PreserveAspectCrop

            Rectangle {
                anchors.fill: parent
                color: "#0d80ec"
                opacity: marea.pressed? 0.3 : 0
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: {
                    editId = path
                    editMode = true
                }
            }
        }
        Component.onCompleted: positionViewAtBeginning()
    }

    ScrollBar {
        scrollArea: listv; width: 6*Devices.density
        x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width;
        anchors.top: listv.top; color: main.color
        anchors.topMargin: headerHeight; anchors.bottom: listv.bottom
    }

    MaterialDesignButton {
        anchors.fill: parent
        flickable: listv
        color: headColor
        hasMenu: false
        onClicked: {
            if(Devices.isDesktop) {
                var path = Desktop.getOpenFileName(0, qsTr("Select file"));
                ppmodel.add(path)
            } else {
                add_component.createObject(ppic_switcher)
            }
        }
    }

    Timer {
        id: show_limit_msg_timer
        interval: 500
        onTriggered: if(time_slider.value > 9) messageDialog.show(limit_warning_component)
    }

    Rectangle {
        width: parent.width
        height: titleBarHeight + headerHeight*listv.ratio
        color: headColor

        Item {
            anchors.fill: parent
            anchors.topMargin: titleBarHeight

            Dial {
                id: time_slider
                height: headerHeight*0.8
                width: height
                anchors.centerIn: parent
                minimumValue: -1
                maximumValue: 32
                style: ProfilePictureDialStyle {color: headColor}
                scale: parent.height/headerHeight
                opacity: scale
                visible: opacity != 0
                onValueChanged: {
                    if(!unlimited && value>11) {
                        value = 11
                        show_limit_msg_timer.restart()
                    }

                    ppmodel.timer = Math.floor(value)
                    service.updateProfilePictureEstimatedTime()
                }
            }

            Text {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 4*Devices.density
                font.family: AsemanApp.globalFont.family
                font.pixelSize: 8*fontRatio*Devices.fontDensity
                color: "#ffffff"
                scale: time_slider.scale
                opacity: time_slider.opacity
                text: {
                    var m = service.profilePictureEstimatedTime
                    if(time_slider.value < 0)
                        return ""

                    var minute = (m%60)
                    var hour = Math.floor(m/60)

                    if(minute<10)
                        minute = "0" + minute
                    if(hour<10)
                        hour = "0" + hour
                    return qsTr("Estimated Time: %1").arg(hour + ":" + minute)
                }
            }
        }

        Item {
            width: parent.width - height - 6*Devices.density
            height: Devices.standardTitleBarHeight
            y: View.statusBarHeight
            x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width

            Text {
                id: header_txt
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14*fontRatio*Devices.fontDensity
                font.family: AsemanApp.globalFont.family
                color: backButtonColor
                x: View.layoutDirection==Qt.RightToLeft? parent.width-width : 0
                text: qsTr("Picture switcher")
            }
        }

        Rectangle {
            height: 3*Devices.density
            width: parent.width
            anchors.top: parent.bottom
            z: 10
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#55000000" }
                GradientStop { position: 1.0; color: "#00000000" }
            }
        }
    }

    editDelegate: Item {
        id: item
        height: column.height
        visible: parent.destHeight == parent.height
        width: ppic_switcher.width
        y: headerY

        property string filePath

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*Devices.density

            Text {
                id: text_area
                width: parent.width
                text: qsTr("Are you sure about removing this sticker set?")
                font.pixelSize: 11*fontRatio*Devices.fontDensity
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: "#333333"
            }

            Item {width: 1; height: 10*Devices.density}

            DialogButtons {
                id: buttons_panel
                width: parent.width
                edit: true
                onDone: {
                    editMode = false
                }
                onDeleteRequest: {
                    ppmodel.remove(item.filePath)
                    editMode = false
                }
            }
        }

        Component.onCompleted: {
            if(editId.length != 0) {
                filePath = editId
            }

            editId = ""
        }
    }

    Text {
        id: desc_txt
        y: headerHeight/2 + parent.height/2 - height/2
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width-40*Devices.density
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        color: "#888888"
        font.family: AsemanApp.globalFont.family
        font.pixelSize: 9*fontRatio*Devices.fontDensity
        visible: listv.count == 0
        text: description
    }

    Component {
        id: add_component
        ProfilePicSwitcherAddDialog {
            anchors.fill: parent
            z: 20
            onClickedOnFile: {
                ppmodel.add(fileUrl)
                close()
            }
        }
    }

    Component {
        id: limit_warning_component
        MessageDialogOkCancelWarning {
            message: qsTr("<b>Store Message</b><br />It's limited. You can buy below package or premium package from the store to set time to the more than 12 hours.<br /><br /><b>%1</b><br />%2")
                         .arg(store.stg_ppic_unlimit_plus_Title).arg(store.stg_ppic_unlimit_plus_Description)
            onOk: {
                BackHandler.back()
                showStore(store.stg_ppic_unlimit_plus_Sku)
            }
        }
    }

    ActivityAnalizer { object: ppic_switcher; comment: ppmodel.count }
}

