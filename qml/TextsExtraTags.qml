import QtQuick 2.0
import AsemanTools 1.0

Text {
    font.family: AsemanApp.globalFont.family
    font.pixelSize: 8*fontRatio*Devices.fontDensity
    color: "#888888"
    text: {
        var links = ""
        for(var i=0; i<tags.length; i++)
            links += (" <a href=\"%1\">%1</a>").arg(tags[i])
        return qsTr("Available keywords:%1").arg(links)
    }

    property variant tags: ["%location%", "%camera%"]
    property bool unlimited: store.premium || store.stg_txt_tags_IsPurchased

    signal activated(string tag)

    onLinkActivated: {
        if(unlimited) {
            activated(link)
        } else {
            showLimit()
        }
    }

    function checkText(text) {
        if(unlimited)
            return

        for(var i=0; i<tags.length; i++)
            if(text.indexOf(tags[i]) >= 0) {
                showLimit()
                break
            }
    }

    function showLimit() {
        messageDialog.show(limit_warning_component)
    }

    Component {
        id: limit_warning_component
        MessageDialogOkCancelWarning {
            message: qsTr("<b>Store Message</b><br />It's limited. You can buy below package or premium package from the store to using these tags.<br /><br /><b>%1</b><br />%2")
                         .arg(store.stg_txt_tags_Title).arg(store.stg_txt_tags_Description)
            onOk: {
                BackHandler.back()
                showStore(store.stg_txt_tags_Sku)
            }
        }
    }
}

