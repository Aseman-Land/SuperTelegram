#ifndef STGHBCLIENT_H
#define STGHBCLIENT_H

#include <QObject>

class StgHBClientPrivate;
class StgHBClient : public QObject
{
    Q_OBJECT
    Q_ENUMS(UpdateReasons)

public:
    enum UpdateReasons {
        UpdateAutoMessageReason = 0
    };

    StgHBClient(QObject *parent = 0);
    ~StgHBClient();

public slots:
    void update(int reason);

private:
    void init();

private:
    StgHBClientPrivate *p;
};

class StgHBClientCore : public QObject
{
    Q_OBJECT
public:
    StgHBClientCore(QObject *parent = 0);
    ~StgHBClientCore();

public slots:
    void update(int reason);
};

#endif // STGHBCLIENT_H
