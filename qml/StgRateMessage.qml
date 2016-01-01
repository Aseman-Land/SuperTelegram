import QtQuick 2.0
import AsemanTools 1.0

MessageDialogOkCancelWarning {
    message: qsTr("<b>Thank you for choosing SuperTelegram</b><br /><br />" +
                  "SuperTelegram is a newly released application. If you like it please rate us on the Bazaar.<br />" +
                  "You can also send your feature request as comment. We'll add them in the future.<br />" +
                  "Thank you for your kindness.")
    onOk: {
        Qt.openUrlExternally("market://details?id=org.nilegroup.SuperTelegram")
        AsemanApp.back()
    }
}

