#include "apilayer.h"

#include <QTcpSocket>
#include <QDataStream>
#include <QPointer>
#include <QTimerEvent>
#include <QQueue>
#include <QTimer>

class ApiLayerPrivate
{
public:
    qint64 id_counter;
    QPointer<QTcpSocket> socket;

    QHash<qint64, int> waitingList;
    QQueue<QByteArray> queue;

    QTimer *destroyTimer;
};

ApiLayer::ApiLayer(QObject *parent) :
    QObject(parent)
{
    p = new ApiLayerPrivate;
    p->id_counter = 10000;
    p->destroyTimer = new QTimer(this);
    p->destroyTimer->setInterval(2000);
    p->destroyTimer->setSingleShot(true);

    initSocket();

    connect(p->destroyTimer, SIGNAL(timeout()), SLOT(deleteLater()));
}

void ApiLayer::initSocket()
{
    if(p->socket)
        delete p->socket;

    p->socket = new QTcpSocket(this);
//    p->socket->connectToHost("127.0.0.1", 34946);
    p->socket->connectToHost("aseman.land", 34946);

    qRegisterMetaType<QAbstractSocket::SocketError>("QAbstractSocket::SocketError");

    connect(p->socket, SIGNAL(readyRead()), SLOT(onReadyRead()) );
    connect(p->socket, SIGNAL(error(QAbstractSocket::SocketError)),
            SLOT(error_prv(QAbstractSocket::SocketError)), Qt::QueuedConnection);
    connect(p->socket, SIGNAL(connected()), SLOT(writeQueue())  );
}

qint64 ApiLayer::pushStickerSetsRequest(const QStringList &stickers)
{
    p->id_counter++;

    QByteArray structData;
    QDataStream structStream(&structData, QIODevice::WriteOnly);
    structStream << static_cast<int>(PushStickerSetsRequestStruct);
    structStream << stickers;
    structStream << p->id_counter;

    QByteArray topData;
    QDataStream topStream(&topData, QIODevice::WriteOnly);
    topStream << static_cast<int>(ApiId);
    topStream << static_cast<int>(PushStickerSetsService);
    topStream << structData;

    write(topData);

    startTimeOut(p->id_counter);
    return p->id_counter;
}

qint64 ApiLayer::pushActivityRequest(const QString &type, int ms, const QString &comment)
{
    p->id_counter++;

    QByteArray structData;
    QDataStream structStream(&structData, QIODevice::WriteOnly);
    structStream << static_cast<int>(PushActivityRequestStruct);
    structStream << type;
    structStream << ms;
    structStream << comment;
    structStream << p->id_counter;

    QByteArray topData;
    QDataStream topStream(&topData, QIODevice::WriteOnly);
    topStream << static_cast<int>(ApiId);
    topStream << static_cast<int>(PushActivityService);
    topStream << structData;

    write(topData);

    startTimeOut(p->id_counter);
    return p->id_counter;
}

qint64 ApiLayer::pushActionRequest(const QString &action)
{
    p->id_counter++;

    QByteArray structData;
    QDataStream structStream(&structData, QIODevice::WriteOnly);
    structStream << static_cast<int>(PushActionRequestStruct);
    structStream << action;
    structStream << p->id_counter;

    QByteArray topData;
    QDataStream topStream(&topData, QIODevice::WriteOnly);
    topStream << static_cast<int>(ApiId);
    topStream << static_cast<int>(PushActionService);
    topStream << structData;

    write(topData);

    startTimeOut(p->id_counter);
    return p->id_counter;
}

qint64 ApiLayer::pushDeviceModelRequest(const QString &name, qreal screen, qreal density)
{
    p->id_counter++;

    QByteArray structData;
    QDataStream structStream(&structData, QIODevice::WriteOnly);
    structStream << static_cast<int>(PushDeviceModelRequestStruct);
    structStream << name;
    structStream << screen;
    structStream << density;
    structStream << p->id_counter;

    QByteArray topData;
    QDataStream topStream(&topData, QIODevice::WriteOnly);
    topStream << static_cast<int>(ApiId);
    topStream << static_cast<int>(PushDeviceModelService);
    topStream << structData;

    write(topData);

    startTimeOut(p->id_counter);
    return p->id_counter;
}

void ApiLayer::startDestroying()
{
    p->destroyTimer->stop();
    if(p->queue.isEmpty())
        p->destroyTimer->start();
}

void ApiLayer::onReadyRead()
{
    while(p->socket->canReadLine())
    {
        QByteArray data = read();
        QDataStream stream(&data, QIODevice::ReadOnly);

        qint64 serviceId = 0;
        stream >> serviceId;
        if(stream.atEnd())
            return;

        QByteArray serviceData;
        stream >> serviceData;

        switch(serviceId)
        {
        case PushStickerSetsService:
            onPushStickerSetsRequestAnswer(serviceData);
            break;

        case PushActivityService:
            onPushActivityRequestAnswer(serviceData);
            break;
        }
    }
}

void ApiLayer::onPushStickerSetsRequestAnswer(QByteArray data)
{
    bool ok = false;
    int structId = 0;
    qint64 id = 0;
    int count = 0;

    QDataStream stream(&data, QIODevice::ReadOnly);
    stream >> structId;
    if(structId != PushStickerSetsStruct)
        return;

    stream >> id;
    checkTimeOut(id);

    if(stream.atEnd())
        return;

    stream >> count;

    for(int i=0; i<count; i++)
    {
        if(stream.atEnd())
            return;

        stream >> ok;
    }

    emit pushStickerSetsRequestAnswer(id, ok);
}

void ApiLayer::onPushActivityRequestAnswer(QByteArray data)
{
    bool ok = false;
    int structId = 0;
    qint64 id = 0;
    int count = 0;

    QDataStream stream(&data, QIODevice::ReadOnly);
    stream >> structId;
    if(structId != PushActivityStruct)
        return;

    stream >> id;
    checkTimeOut(id);

    if(stream.atEnd())
        return;

    stream >> count;

    for(int i=0; i<count; i++)
    {
        if(stream.atEnd())
            return;

        stream >> ok;
    }

    emit pushActivityRequestAnswer(id, ok);
}

void ApiLayer::onPushActionRequestAnswer(QByteArray data)
{
    bool ok = false;
    int structId = 0;
    qint64 id = 0;
    int count = 0;

    QDataStream stream(&data, QIODevice::ReadOnly);
    stream >> structId;
    if(structId != PushActionStruct)
        return;

    stream >> id;
    checkTimeOut(id);

    if(stream.atEnd())
        return;

    stream >> count;

    for(int i=0; i<count; i++)
    {
        if(stream.atEnd())
            return;

        stream >> ok;
    }

    emit pushActionRequestAnswer(id, ok);
}

void ApiLayer::onPushDeviceModelRequestAnswer(QByteArray data)
{
    bool ok = false;
    int structId = 0;
    qint64 id = 0;
    int count = 0;

    QDataStream stream(&data, QIODevice::ReadOnly);
    stream >> structId;
    if(structId != PushDeviceModelStruct)
        return;

    stream >> id;
    checkTimeOut(id);

    if(stream.atEnd())
        return;

    stream >> count;

    for(int i=0; i<count; i++)
    {
        if(stream.atEnd())
            return;

        stream >> ok;
    }

    emit pushDeviceModelRequestAnswer(id, ok);
}

void ApiLayer::error_prv(QAbstractSocket::SocketError socketError)
{
    QString text;
    switch(static_cast<int>(socketError))
    {
    case QAbstractSocket::ConnectionRefusedError:
        text = "The connection was refused by the peer (or timed out).";
        initSocket();
        break;

    case QAbstractSocket::RemoteHostClosedError:
        text = "The remote host closed the connection.";
        initSocket();
        break;

    case QAbstractSocket::HostNotFoundError:
        text = "The host address was not found.";
        break;

    case QAbstractSocket::SocketAccessError:
        text = "The socket operation failed because the application lacked the required privileges.";
        break;

    case QAbstractSocket::SocketResourceError:
        text = "The local system ran out of resources.";
        break;

    case QAbstractSocket::SocketTimeoutError:
        text = "The socket operation timed out.";
        break;

    case QAbstractSocket::DatagramTooLargeError:
        text = "The datagram was larger than the operating system's limit.";
        break;

    case QAbstractSocket::NetworkError:
        text = "An error occurred with the network.";
        initSocket();
        break;

    case QAbstractSocket::AddressInUseError:
        text = "The bound address is already in use and was set to be exclusive.";
        break;

    case QAbstractSocket::SocketAddressNotAvailableError:
        text = "The bound address does not belong to the host.";
        break;

    case QAbstractSocket::UnsupportedSocketOperationError:
        text = "The requested socket operation is not supported by the local operating system.";
        break;

    case QAbstractSocket::UnfinishedSocketOperationError:
        text = "The last operation attempted has not finished yet (still in progress in the background).";
        break;

    case QAbstractSocket::ProxyAuthenticationRequiredError:
        text = "The socket is using a proxy, and the proxy requires authentication.";
        break;

    case QAbstractSocket::SslHandshakeFailedError:
        text = "The SSL/TLS handshake failed, so the connection was closed";
        break;

    case QAbstractSocket::ProxyConnectionRefusedError:
        text = "Could not contact the proxy server because the connection to that server was denied.";
        break;

    case QAbstractSocket::ProxyConnectionClosedError:
        text = "The connection to the proxy server was closed unexpectedly (before the connection to the final peer was established)";
        break;

    case QAbstractSocket::ProxyConnectionTimeoutError:
        text = "The connection to the proxy server timed out or the proxy server stopped responding in the authentication phase.";
        break;

    case QAbstractSocket::ProxyNotFoundError:
        text = "The proxy address was not found.";
        break;

    case QAbstractSocket::ProxyProtocolError:
        text = "The connection negotiation with the proxy server failed, because the response from the proxy server could not be understood.";
        break;

    case QAbstractSocket::OperationError:
        text = "An operation was attempted while the socket was in a state that did not permit it.";
        break;

    case QAbstractSocket::SslInternalError:
        text = "The SSL library being used reported an internal error. This is probably the result of a bad installation or misconfiguration of the library.";
        break;

    case QAbstractSocket::SslInvalidUserDataError:
        text = "Invalid data (certificate, key, cypher, etc.) was provided and its use resulted in an error in the SSL library.";
        break;

    case QAbstractSocket::TemporaryError:
        text = "A temporary error occurred.";
        break;

    case QAbstractSocket::UnknownSocketError:
        text = "An unidentified error occurred.";
        break;
    }

    QHashIterator<qint64, int> i(p->waitingList);
    while(i.hasNext())
    {
        i.next();
        killTimer(i.value());
    }

    p->waitingList.clear();
    emit error(text);
}

void ApiLayer::writeQueue()
{
    while(!p->queue.isEmpty())
        write(p->queue.takeFirst());

    emit queueFinished();
}

void ApiLayer::write(QByteArray data)
{
    p->destroyTimer->stop();

    if(p->socket->state() == QAbstractSocket::ConnectedState)
    {
        p->socket->write(data.replace("\n", "\r\t\t\r") + "\n");
        p->socket->flush();
    }
    else
    {
        p->queue.append(data);
    }

    if(p->queue.isEmpty())
        emit queueFinished();
}

QByteArray ApiLayer::read(qint64 maxlen)
{
    QByteArray data = p->socket->readLine(maxlen);
    data.replace("\n", "");
    data.replace("\r\t\t\r", "\n");

    return data;
}

void ApiLayer::startTimeOut(qint64 id)
{
    const int timerId = startTimer(20000);
    p->waitingList.insert(id, timerId);
}

void ApiLayer::checkTimeOut(qint64 id)
{
    if(!p->waitingList.contains(id))
        return;

    const int timerId = p->waitingList.value(id);
    killTimer(timerId);
    p->waitingList.remove(id);
}

void ApiLayer::timerEvent(QTimerEvent *e)
{
    qint64 reqId = p->waitingList.key(e->timerId());
    if(reqId)
    {
        p->waitingList.remove(reqId);
        killTimer(e->timerId());

        emit error("The connection was refused by the peer (or timed out).");
    }
}

ApiLayer::~ApiLayer()
{
    delete p;
}
