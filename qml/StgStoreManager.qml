import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0

StoreManager {
    property SuperTelegram stg
    property Telegram telegram

    property int stg_premium_pack
    property int stg_sens_msg_3plus
    property int stg_txt_tags
    property int stg_ppic_6h_plus
    property int stg_ppic_unlimit_plus
    property int stg_by_stg

    property bool isPremiumNumber: stg && telegram? stg.checkPremiumNumber(telegram.phoneNumber) : false
    property bool is30DayTrialNumber: stg && telegram? stg.check30DayTrialNumber(telegram.phoneNumber) : false

    property bool premium: isPremiumNumber || (stg_premium_pack == StoreManager.InventoryStatePurchased)

    Component.onCompleted: setup()
}

