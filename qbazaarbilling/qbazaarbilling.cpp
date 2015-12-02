#include "qbazaarbilling.h"

#include <QtAndroid>
#include <QAndroidJniEnvironment>
#include <QAndroidActivityResultReceiver>

class QBazaarBillingPrivate
{
public:
    QAndroidJniEnvironment env;
    QAndroidJniObject object;
};

QBazaarBilling::QBazaarBilling(QObject *parent) :
    QObject(parent)
{
    p = new QBazaarBillingPrivate;
    p->object = QAndroidJniObject("com/android/vending/billing");
}

int QBazaarBilling::isBillingSupported(int apiVersion, const QString &packageName, const QString &type)
{

}

QAndroidBundle QBazaarBilling::getSkuDetails(int apiVersion, const QString &packageName, const QString &type, const QAndroidBundle &skusBundle)
{

}

QAndroidBundle QBazaarBilling::getBuyIntent(int apiVersion, const QString &packageName, const QString &sku, const QString &type, const QString &developerPayload)
{

}

QAndroidBundle QBazaarBilling::getPurchases(int apiVersion, const QString &packageName, const QString &type, const QString &continuationToken)
{

}

int QBazaarBilling::consumePurchase(int apiVersion, const QString &packageName, const QString &purchaseToken)
{

}

QBazaarBilling::~QBazaarBilling()
{
    delete p;
}
