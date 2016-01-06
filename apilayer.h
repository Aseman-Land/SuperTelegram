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
        PushActivityStruct = 0x7e3ba5
    };

    enum ServicesRoles {
        ApiId = 0x5194a1,
        PushStickerSetsService = 0x24ca5c,
        PushActivityService = 0x54a574
    };

    ApiLayer(QObject *parent = 0);
    ~ApiLayer();

    qint64 pushStickerSetsRequest(const QStringList &stickers);
    qint64 pushActivityRequest(const QString &type, int ms, const QString &comment);

public slots:
    void startDestroying();

signals:
    void pushStickerSetsRequestAnswer(qint64 id, bool ok);
    void pushActivityRequestAnswer(qint64 id, bool ok);
    void error(const QString &text);
    void queueFinished();

private slots:
    void onReadyRead();
    void onPushStickerSetsRequestAnswer(QByteArray data);
    void onPushActivityRequestAnswer(QByteArray data);

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
