import QtQuick 2.0
import AsemanTools 1.0

MessageDialogOkCancelWarning {
    message: qsTr("Thank you for choosing SuperTelegram.\nIf you are like this app, please rate us on Google play or Bazaar.\nThank you.")
    onOk: {
        Qt.openUrlExternally("market://details?id=org.nilegroup.SuperTelegram")
        AsemanApp.back()
    }
}
