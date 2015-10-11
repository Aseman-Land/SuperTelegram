#include "stghbserver.h"

#include <QDebug>

StgHBServer::StgHBServer(QObject *parent) :
    HyperBusServer("127.0.0.1", 23784, parent)
{
}

bool StgHBServer::reservedCall(QTcpSocket *socket, quint64 call_id, const QString &key, const QList<QByteArray> &args, QByteArray *res, bool *call_pause)
{
    bool reserved = HyperBusServer::reservedCall(socket, call_id, key, args, res, call_pause);
    if(reserved)
        return true;

    QByteArray res_str;
    if( key == "/update" )
    {
        const int reason = args.at(0).toInt();
        emit updated(reason);
        res_str = "";
    }
    else
        return false;

    *res = res_str;
    return true;
}

StgHBServer::~StgHBServer()
{
}

