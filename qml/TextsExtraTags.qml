import QtQuick 2.0
import AsemanTools 1.0

Text {
    font.family: AsemanApp.globalFont.family
    font.pixelSize: 8*fontRatio*Devices.fontDensity
    color: "#888888"
    text: qsTr("Available keywords: %1").arg(
              "<a href=\"%location%\">%location%</a> " +
              "<a href=\"%camera%\">%camera%</a>")

    property bool unlimited: store.premium || store.stg_txt_tags_IsPurchased

    signal activated(string tag)

    onLinkActivated: {
        if(unlimited) {
            activated(link)
        } else {
            messageDialog.show(limit_warning_component)
        }
    }

    Component {
        id: limit_warning_component
        MessageDialogOkCancelWarning {
            message: qsTr("<b>Store Message</b><br />It's limited. You can buy below package or premium package from the store to create more than 3 item.<br /><br /><b>%1</b><br />%2")
                         .arg(store.stg_txt_tags_Title).arg(store.stg_txt_tags_Description)
            onOk: {
                BackHandler.back()
                showStore(store.stg_txt_tags_Sku)
            }
        }
    }
}

