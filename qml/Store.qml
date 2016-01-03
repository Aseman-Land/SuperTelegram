import QtQuick 2.0
import AsemanTools 1.0

Rectangle {
    width: 100
    height: 62
    clip: true

    property bool isPremium: store.premium
    property string highlight

    Image {
        width: height
        height: parent.height
        anchors.centerIn: parent
        sourceSize: Qt.size(width, height)
        opacity: 0.6
        source: isPremium? "img/premium-back.jpg" : ""
        visible: isPremium

        Column {
            anchors.centerIn: parent

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: AsemanApp.globalFont.family
                font.pixelSize: 13*fontRatio*Devices.fontDensity
                text: qsTr("YOU ARE PREMIUM")
                color: "#000000"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: AsemanApp.globalFont.family
                font.pixelSize: 40*fontRatio*Devices.fontDensity
                text: qsTr(";)")
                color: "#000000"
            }
        }
    }

    Rectangle {
        id: title_bar
        width: parent.width
        height: Devices.standardTitleBarHeight + View.statusBarHeight
        color: "#FA8902"

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
            text: qsTr("Store")
        }
    }

    Rectangle {
        height: 4*Devices.density
        width: parent.width
        anchors.top: title_bar.bottom
        z: 10
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#33000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    StoreManagerModel {
        id: smodel
        storeManager: main.store
    }

    Text {
        anchors.centerIn: parent
        width: parent.width - 60*Devices.density
        color: "#555555"
        font.family: AsemanApp.globalFont.family
        font.pixelSize: 11*fontRatio*Devices.fontDensity
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        visible: listv.count==0 && listv.visible
        text: qsTr("Can not connect to the %1. Please check:<ul>" +
                   "<li>%1 is installed in your device.</li>" +
                   "<li>You are logged in to the bazaar.</li>" +
                   "<li>Your device connected to the internet.</li>" +
                   "</ul>").arg(stg.storeName)
    }

    AsemanListView {
        id: listv
        width: parent.width
        anchors.top: title_bar.bottom
        anchors.bottom: parent.bottom
        visible: !isPremium
        model: smodel
        clip: true
        delegate: Item {
            id: item
            width: listv.width
            height: row.height + (premiumItem? 60*Devices.density : 30*Devices.density)
            clip: true

            property bool premiumItem: model.sku == "stg_premium_pack"

            Rectangle {
                id: highlighter
                anchors.fill: parent
                color: "#22bb0000"
                opacity: 0

                Behavior on opacity {
                    NumberAnimation{easing.type: Easing.InOutCubic; duration: 500}
                }

                Timer {
                    interval: 1000
                    repeat: true
                    onTriggered: {
                        if(counter%2==0)
                            highlighter.opacity = 1
                        else
                            highlighter.opacity = 0

                        counter++
                        if(counter > 5)
                            stop()
                    }
                    Component.onCompleted: if(highlight == model.sku) start()
                    property int counter: 0
                }
            }

            Image {
                width: parent.width
                height: width
                anchors.centerIn: parent
                sourceSize: Qt.size(width, height)
                opacity: 0.6
                Component.onCompleted: if(item.premiumItem) source = "img/premium-back.jpg"
            }

            Row {
                id: row
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10*Devices.density
                spacing: 4*Devices.density
                layoutDirection: ttl.horizontalAlignment==Text.AlignRight? Qt.RightToLeft : Qt.LeftToRight

                Image {
                    id: img
                    height: 42*Devices.density
                    width: height
                    y: 10*Devices.density
                    sourceSize: Qt.size(width*1.5, height*1.5)
                    source: "img/store-package.png"
                    visible: !item.premiumItem
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: item.premiumItem? 10*Devices.density : 4*Devices.density

                    Text {
                        id: ttl
                        width: item.premiumItem? row.width : row.width - img.width - buy_frame.width - 8*Devices.density
                        font.family: AsemanApp.globalFont.family
                        font.pixelSize: (item.premiumItem?13:10)*fontRatio*Devices.fontDensity
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.title
                        color: item.premiumItem? "#000000" : "#000000"
                        Component.onCompleted: if(item.premiumItem) horizontalAlignment = Text.AlignHCenter
                    }

                    Text {
                        id: desc
                        width: ttl.width
                        horizontalAlignment: ttl.horizontalAlignment
                        font.family: AsemanApp.globalFont.family
                        font.pixelSize: 9*fontRatio*Devices.fontDensity
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: item.premiumItem? "#444444" : "#888888"
                        text: model.description
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.family: AsemanApp.globalFont.family
                        font.pixelSize: 11*fontRatio*Devices.fontDensity
                        color: "#333333"
                        text: model.price
                        visible: item.premiumItem
                    }

                    Button {
                        width: row.width/2
                        height: 32*Devices.density
                        anchors.horizontalCenter: parent.horizontalCenter
                        normalColor: "#0d80ec"
                        highlightColor: Qt.darker(normalColor, 1.1)
                        textColor: "#ffffff"
                        text: qsTr("BUY PREMIUM")
                        radius: 3*Devices.density
                        visible: item.premiumItem
                        onClicked: model.purchasing = true
                    }
                }

                Item {
                    id: buy_frame
                    y: 10*Devices.density
                    width: 60*Devices.density
                    height: buy_btn.height + price_txt.height + 2*Devices.density
                    visible: !item.premiumItem

                    Button {
                        id: buy_btn
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 40*Devices.density
                        normalColor: "#00000000"
                        highlightColor: "#0d80ec"
                        textColor: press? "#ffffff" :"#0d80ec"
                        border.color: highlightColor
                        border.width: 1*Devices.density
                        text: qsTr("BUY")
                        radius: 3*Devices.density
                        visible: !model.purchased
                        onClicked: model.purchasing = true
                    }

                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: height
                        height: 30*Devices.density
                        sourceSize: Qt.size(width, height)
                        source: "img/ok-blue.png"
                        visible: model.purchased
                    }

                    Text {
                        id: price_txt
                        width: parent.width
                        anchors.bottom: parent.bottom
                        horizontalAlignment: Text.AlignHCenter
                        font.family: AsemanApp.globalFont.family
                        font.pixelSize: 8*fontRatio*Devices.fontDensity
                        color: "#0d80ec"
                        visible: !model.purchased
                        text: model.price
                    }
                }
            }
        }

        section.property: "sku"
        section.criteria: ViewSection.FullString
        section.delegate: Rectangle {
            width: listv.width
            height: show? 42*Devices.density : 0

            property string sku: section
            property bool show: (sku == "stg_sens_msg_3plus")

            Text {
                width: parent.width-20*Devices.density
                anchors.centerIn: parent
                font.family: AsemanApp.globalFont.family
                font.pixelSize: 11*Devices.fontDensity
                color: "#000000"
                text: qsTr("Other Inventories")
                visible: parent.show
            }
        }
    }

    ScrollBar {
        id: scrollbar
        scrollArea: listv; height: listv.height; width: 6*Devices.density
        anchors.top: listv.top; color: title_bar.color
        x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width
    }
}

