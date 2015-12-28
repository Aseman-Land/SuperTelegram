import QtQuick 2.0
import AsemanTools 1.0

Rectangle {
    width: 100
    height: 62
    clip: true

    property bool isPremium: store.premium

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
        width: parent.width - 20*Devices.density
        horizontalAlignment: Text.AlignHCenter
        color: "#555555"
        font.family: AsemanApp.globalFont.family
        font.pixelSize: 11*fontRatio*Devices.fontDensity
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: qsTr("Can't find Logged-in Bazaar on your device!")
        visible: listv.count==0 && listv.visible
    }

    AsemanListView {
        id: listv
        width: parent.width
        anchors.top: title_bar.bottom
        anchors.bottom: parent.bottom
        visible: !isPremium
        model: smodel
        clip: true
        delegate: Rectangle {
            id: item
            width: listv.width
            height: row.height + (premiumItem? 60*Devices.density : 20*Devices.density)
            color: premiumItem? "#00000000" : "#00000000"
            clip: true

            property bool premiumItem: model.sku == "stg_premium_pack"

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
                    anchors.verticalCenter: parent.verticalCenter
                    sourceSize: Qt.size(width*1.5, height*1.5)
                    source: "img/store-bag.png"
                    visible: !item.premiumItem
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: item.premiumItem? 10*Devices.density : 4*Devices.density

                    Text {
                        id: ttl
                        width: item.premiumItem? row.width : row.width - img.width - 4*Devices.density
                        font.family: AsemanApp.globalFont.family
                        font.pixelSize: (item.premiumItem?13:10)*fontRatio*Devices.fontDensity
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

