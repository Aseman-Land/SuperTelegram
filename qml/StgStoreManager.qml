import QtQuick 2.0
import AsemanTools 1.0
import SuperTelegram 1.0
import TelegramQmlLib 1.0

StgStoreManagerCore {
    property SuperTelegram stg
    property Telegram telegram

    property bool isPremiumNumber: stg && telegram? stg.checkPremiumNumber(telegram.phoneNumber) : false
    property bool is30DayTrialNumber: stg && telegram? stg.check30DayTrialNumber(telegram.phoneNumber) : false

    property bool premium: isPremiumNumber || (stg_premium_pack == StoreManager.InventoryStatePurchased) ||
                           (stg && stg.freeStore)

    onInventoryPurchased: stg.pushAction("store-purchased-"+sku)
}

