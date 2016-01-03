import QtQuick 2.0
import QtQuick.Controls 1.2 as QtControls
import AsemanTools.Controls 1.0 as Controls
import AsemanTools.Controls.Styles 1.0
import AsemanTools 1.0
import TelegramQmlLib 1.0

Item {
    id: dlist

    signal selected(variant dialog)

    DialogsModel {
        id: dmodel
        telegram: main.telegram
    }

    AsemanListView {
        id: listv
        anchors.fill: parent
        model: dmodel
        clip: true

        delegate: DialogListItem {
            id: item
            width: listv.width
            dialog: model.item
            telegram: main.telegram
            onClicked: dlist.selected(item.dialog)
        }
    }

    ScrollBar {
        id: scrollbar
        scrollArea: listv; height: listv.height; width: 6*Devices.density
        anchors.top: listv.top; color: main.color
        x: View.layoutDirection==Qt.RightToLeft? 0 : parent.width-width
    }
}

