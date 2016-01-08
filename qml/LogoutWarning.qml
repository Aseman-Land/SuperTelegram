import QtQuick 2.0
import AsemanTools 1.0

MessageDialogOkCancelWarning {
    message: qsTr("<b>SuperTelegram</b><br /><br />" +
                  "Are you sure you want to log out?<br /><br />" +
                  "Note that you can seamlessly use Telegram on all your devices" +
                  "at once.")
    onOk: telegram.authLogout()
}
