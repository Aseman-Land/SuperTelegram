#ifndef SUPERTELEGRAM_H
#define SUPERTELEGRAM_H

#include <QObject>
#include <QStringList>

class CommandsDatabase;
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
    Q_PROPERTY(CommandsDatabase* database READ database NOTIFY databaseChanged)
    Q_PROPERTY(QString picturesLocation READ picturesLocation NOTIFY picturesLocationChanged)
    Q_PROPERTY(QString publicKey READ publicKey NOTIFY publicKeyChanged)

    Q_PROPERTY(QStringList languages READ languages NOTIFY languagesChanged)
    Q_PROPERTY(QString currentLanguage READ currentLanguage WRITE setCurrentLanguage NOTIFY currentLanguageChanged)
    Q_PROPERTY(int languageDirection READ languageDirection NOTIFY languageDirectionChanged)

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

    QString publicKey() const;

    QString picturesLocation() const;

    CommandsDatabase *database() const;
    Q_INVOKABLE QString getTimeString( const QDateTime & dt );
    Q_INVOKABLE QString getTimesDiff(const QDateTime &a, const QDateTime &b);

    int languageDirection() const;

    QStringList languages() const;
    void setCurrentLanguage( const QString & lang );
    QString currentLanguage() const;

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
    void databaseChanged();
    void picturesLocationChanged();
    void publicKeyChanged();

    void currentLanguageChanged();
    void languageDirectionChanged();
    void languagesChanged();

private:
    void init_languages();

private:
    SuperTelegramPrivate *p;
};

#endif // SUPERTELEGRAM_H
