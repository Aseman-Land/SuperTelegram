import QtQuick 2.0
import AsemanTools 1.0
import TelegramQmlLib 1.0

RoundedImage {
    id: contact_image
    source: handlerSource

    property alias handlerSource: file_handler.thumbPath

    property Telegram telegram
    property Dialog dialog

    property bool isChat: dialog.peer.chatId != 0
    property User user: dialog? telegram.user(dialog.peer.userId) : telegram.nullUser
    property Chat chat: dialog? telegram.chat(dialog.peer.chatId) : telegram.nullChat

    FileHandler {
        id: file_handler
        target: isChat? chat : user
        telegram: contact_image.telegram
        defaultThumbnail: {
            if(isChat)
                return "img/group.png"
            else
                return "img/user.png"
        }
    }

    function refresh() {
        file_handler.refresh()
    }
}

