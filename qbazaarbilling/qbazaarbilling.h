#ifndef QBAZAARBILLING_H
#define QBAZAARBILLING_H

#include <QObject>
#include <QAndroidJniObject>

typedef QAndroidJniObject QAndroidBundle;

class QBazaarBillingPrivate;
class QBazaarBilling: public QObject
{
    Q_OBJECT
public:
    QBazaarBilling(QObject *parent = 0);
    ~QBazaarBilling();

    int isBillingSupported(int apiVersion, const QString &packageName, const QString &type);
    QAndroidBundle getSkuDetails(int apiVersion, const QString &packageName, const QString &type, const QAndroidBundle &skusBundle);
    QAndroidBundle getBuyIntent(int apiVersion, const QString &packageName, const QString &sku, const QString &type, const QString &developerPayload);
    QAndroidBundle getPurchases(int apiVersion, const QString &packageName, const QString &type, const QString &continuationToken);
    int consumePurchase(int apiVersion, const QString &packageName, const QString &purchaseToken);

private:
    QBazaarBillingPrivate *p;
};

#endif // QBAZAARBILLING_H
