import QtQuick 2.0
import AsemanTools 1.0

MessageDialogOkCancelWarning {
    message: qsTr("<b>Thank you for choosing SuperTelegram</b><br /><br />" +
                  "SuperTelegram is a newly released application. If you like it please rate us on the %1.<br />" +
                  "You can also send your feature request as comment. We'll add them in the future.<br />" +
                  "Thank you for your kindness.").arg(stg.storeName)
    onOk: {
        Qt.openUrlExternally("market://details?id=org.nilegroup.SuperTelegram")
        stg.pushAction("rate-ok")
        AsemanApp.back()
    }
    onCanceled: {
        stg.pushAction("rate-cancel")
    }
}

