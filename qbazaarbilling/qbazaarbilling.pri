android {

QT += androidextras

SOURCES += \
    $$PWD/qbazaarbilling.cpp

HEADERS += \
    $$PWD/qbazaarbilling.h

DISTFILES += \
    $$PWD/src/com/example/android/trivialdrivesample/util/Base64.java \
    $$PWD/src/com/example/android/trivialdrivesample/util/Base64DecoderException.java \
    $$PWD/src/com/example/android/trivialdrivesample/util/IabException.java \
    $$PWD/src/com/example/android/trivialdrivesample/util/IabHelper.java \
    $$PWD/src/com/example/android/trivialdrivesample/util/IabResult.java \
    $$PWD/src/com/example/android/trivialdrivesample/util/Inventory.java \
    $$PWD/src/com/example/android/trivialdrivesample/util/Purchase.java \
    $$PWD/src/com/example/android/trivialdrivesample/util/Security.java \
    $$PWD/src/com/example/android/trivialdrivesample/util/SkuDetails.java \
    $$PWD/src/land/aseman/billing/QBazaarBilling.java \
    $$PWD/src/com/android/vending/billing/IInAppBillingService.aidl
}
