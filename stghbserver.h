#ifndef STGHBSERVER_H
#define STGHBSERVER_H

#include "hyperbus/hyperbusserver.h"

class StgHBServer : public HyperBusServer
{
    Q_OBJECT
public:
    StgHBServer(QObject *parent = 0);
    ~StgHBServer();

signals:
    void updated(int reason);

protected:
    virtual bool reservedCall( QTcpSocket *socket, quint64 call_id, const QString & key, const QList<QByteArray> & args, QByteArray *res, bool *call_pause );
};

#endif // STGHBSERVER_H
