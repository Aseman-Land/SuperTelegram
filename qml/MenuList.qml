import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: mlist
    width: 100
    height: 62

    signal selected(int index, variant component)

    AsemanListView {
        id: listv
        anchors.fill: parent
        clip: true
        model: ListModel{}
        section.property: "type"
        section.delegate: Item {
            width: listv.width
            height: section==0? 1 : 10*Devices.density

            Rectangle {
                width: parent.width - 30*Devices.density
                height: 1*Devices.density
                color: "#ffffff"
                opacity: 0.2
                visible: section != 0
                anchors.centerIn: parent
            }
        }

        delegate: Item {
            width: listv.width
            height: 38*Devices.density

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4*Devices.density
                anchors.leftMargin: 10*Devices.density
                anchors.rightMargin: 10*Devices.density
                radius: 4*Devices.density
                color: "#ffffff"
                opacity: marea.pressed? 0.2 : 0
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                x: View.layoutDirection==Qt.RightToLeft? parent.width - width - marg : marg

                property real marg: 15*Devices.density

                Text {
                    color: "#ffffff"
                    text: name
                    font.pixelSize: 11*Devices.fontDensity
                }
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: mlist.selected(index,0)
            }
        }

        Component.onCompleted: refresh()

        function refresh() {
            model.clear()
            model.append({"name":qsTr("Home"), "type": 0})
            model.append({"name":qsTr("Configure"), "type": 0})
            model.append({"name":qsTr("Donate"), "type": 1})
            model.append({"name":qsTr("OpenSource Projects"), "type": 1})
            model.append({"name":qsTr("About Nile Group"), "type": 1})
            model.append({"name":qsTr("About Application"), "type": 1})
        }
    }
}

