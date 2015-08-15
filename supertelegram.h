#ifndef SUPERTELEGRAM_H
#define SUPERTELEGRAM_H

#include <QObject>

class AsemanQuickView;
class SuperTelegramPrivate;
class SuperTelegram : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString defaultHostAddress READ defaultHostAddress WRITE setDefaultHostAddress NOTIFY defaultHostAddressChanged)
    Q_PROPERTY(int defaultHostPort READ defaultHostPort WRITE setDefaultHostPort NOTIFY defaultHostPortChanged)
    Q_PROPERTY(int defaultHostDcId READ defaultHostDcId WRITE setDefaultHostDcId NOTIFY defaultHostDcIdChanged)
    Q_PROPERTY(int appId READ appId WRITE setAppId NOTIFY appIdChanged)
    Q_PROPERTY(QString appHash READ appHash WRITE setAppHash NOTIFY appHashChanged)
    Q_PROPERTY(QObject* view READ view WRITE setView NOTIFY viewChanged)
    Q_PROPERTY(QString phoneNumber READ phoneNumber WRITE setPhoneNumber NOTIFY phoneNumberChanged)

public:
    SuperTelegram(QObject *parent = 0);
    ~SuperTelegram();

    void setDefaultHostAddress(const QString &host);
    QString defaultHostAddress() const;

    void setDefaultHostPort(int port);
    int defaultHostPort() const;

    void setDefaultHostDcId(int dcId);
    int defaultHostDcId() const;

    void setAppId(int appId);
    int appId() const;

    void setAppHash(const QString &appHash);
    QString appHash() const;

    void setView(QObject *view);
    QObject *view() const;

    void setPhoneNumber(const QString &phoneNumber);
    QString phoneNumber() const;

public slots:
    bool startService();
    bool stopService();

signals:
    void defaultHostAddressChanged();
    void defaultHostPortChanged();
    void defaultHostDcIdChanged();
    void appIdChanged();
    void appHashChanged();
    void viewChanged();
    void phoneNumberChanged();

private:
    SuperTelegramPrivate *p;
};

#endif // SUPERTELEGRAM_H
