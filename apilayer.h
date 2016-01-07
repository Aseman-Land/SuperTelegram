#ifndef APILAYER_H
#define APILAYER_H

#include <QObject>
#include <QDateTime>
#include <QStringList>
#include <QTcpSocket>

class ApiLayerPrivate;
class ApiLayer : public QObject
{
    Q_OBJECT

public:
    enum StructRoles {
        PushStickerSetsRequestStruct = 0x1a23cc,
        PushStickerSetsStruct = 0x288d40,
        PushActivityRequestStruct = 0x9ffff1,
        PushActivityStruct = 0x7e3ba5,
        PushActionRequestStruct = 0x54a3d3,
        PushActionStruct = 0x71d39a,
        PushDeviceModelRequestStruct = 0x69c4c3,
        PushDeviceModelStruct = 0x9dc44a
    };

    enum ServicesRoles {
        ApiId = 0x5194a1,
        PushStickerSetsService = 0x24ca5c,
        PushActivityService = 0x54a574,
        PushActionService = 0x315cd3,
        PushDeviceModelService = 0x482dc4
    };

    ApiLayer(QObject *parent = 0);
    ~ApiLayer();

    qint64 pushStickerSetsRequest(const QStringList &stickers);
    qint64 pushActivityRequest(const QString &type, int ms, const QString &comment);
    qint64 pushActionRequest(const QString &action);
    qint64 pushDeviceModelRequest(const QString &name, qreal screen, qreal density);

public slots:
    void startDestroying();

signals:
    void pushStickerSetsRequestAnswer(qint64 id, bool ok);
    void pushActivityRequestAnswer(qint64 id, bool ok);
    void pushActionRequestAnswer(qint64 id, bool ok);
    void pushDeviceModelRequestAnswer(qint64 id, bool ok);
    void error(const QString &text);
    void queueFinished();

private slots:
    void onReadyRead();
    void onPushStickerSetsRequestAnswer(QByteArray data);
    void onPushActivityRequestAnswer(QByteArray data);
    void onPushActionRequestAnswer(QByteArray data);
    void onPushDeviceModelRequestAnswer(QByteArray data);

    void error_prv(QAbstractSocket::SocketError socketError);
    void writeQueue();

private:
    void write(QByteArray data);
    QByteArray read(qint64 maxlen = 0);
    QTcpSocket *getSocket();

    void startTimeOut(qint64 id);
    void checkTimeOut(qint64 id);

    void initSocket();

protected:
    void timerEvent(QTimerEvent *e);

private:
    ApiLayerPrivate *p;
};

#endif // APILAYER_H
