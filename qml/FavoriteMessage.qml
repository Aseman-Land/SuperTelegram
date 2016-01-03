import QtQuick 2.0
import AsemanTools 1.0

MessageDialogOkCancelWarning {
    message: qsTr("Thank you for choosing SuperTelegram.\nIf you are like this app, please rate us on the %1.\nThank you.").arg(stg.storeName)
    onOk: {
        Qt.openUrlExternally("market://details?id=org.nilegroup.SuperTelegram")
        AsemanApp.back()
    }
}
