#ifndef SUPERTELEGRAMSERVICE_H
#define SUPERTELEGRAMSERVICE_H

#include <QObject>

class SuperTelegramServicePrivate;
class SuperTelegramService : public QObject
{
    Q_OBJECT
public:
    SuperTelegramService(QObject *parent = 0);
    ~SuperTelegramService();

public slots:
    void start();
    void stop();

private slots:
    void authNeeded();
    void authLoggedIn();

private:
    SuperTelegramServicePrivate *p;
};

#endif // SUPERTELEGRAMSERVICE_H
