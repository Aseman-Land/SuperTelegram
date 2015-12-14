#include "stgactioncaptureimage.h"
#include "supertelegramservice.h"
#include "asemantools/asemancameracapture.h"
#include "asemantools/asemanapplication.h"
#include "asemantools/asemantools.h"
#include "telegram.h"

#include <QPointer>
#include <QCameraInfo>
#include <QCamera>
#include <QCameraImageCapture>
#include <QUuid>
#include <QDir>
#include <QFileInfo>

class StgActionCaptureImagePrivate
{
public:
    QPointer<Telegram> telegram;
    QString attachedMsg;
    InputPeer peer;
    qint64 replyToId;
    AsemanCameraCapture *camera;
    qint64 reqId;
};

StgActionCaptureImage::StgActionCaptureImage(QObject *parent) :
    AbstractStgAction(parent)
{
    p = new StgActionCaptureImagePrivate;
    p->camera = 0;
    p->reqId = 0;
}

QString StgActionCaptureImage::keyword()
{
    return "%camera%";
}

void StgActionCaptureImage::start(Telegram *tg, const InputPeer &peer, qint64 replyToId, const QString &attachedMsg)
{
    if(p->telegram || !tg)
    {
        emit finished();
        return;
    }

    p->telegram = tg;
    p->peer = peer;
    p->attachedMsg = attachedMsg;
    p->replyToId = replyToId;

    QString newDirPath = AsemanApplication::homePath() + "/camera/";
    QDir().mkpath(newDirPath);
    AsemanTools::clearDirectory(newDirPath);

    QString filePath = newDirPath + "/" + QString(QUuid::createUuid().toString()).remove("{").remove("}") + ".jpg";
    p->camera = new AsemanCameraCapture(this);

    connect(p->camera, SIGNAL(imageCaptured(int,QString)), SLOT(imageCaptured(int,QString)));
    connect(p->telegram, SIGNAL(messagesSendMediaAnswer(qint64,UpdatesType)),
            this, SLOT(messagesSendMediaAnswer(qint64,UpdatesType)));

    p->camera->capture(filePath, AsemanCameraCapture::CameraFacingBack);
}

void StgActionCaptureImage::imageCaptured(int id, const QString &path)
{
    if(id && !path.isEmpty() && QFileInfo::exists(path)) {
        p->telegram->messagesSendMessage(p->peer, SuperTelegramService::generateRandomId(),
                                         tr("Image taken and Uploading %1KB :)\nPlease Wait...").arg(QFileInfo(path).size()/1024),
                                         p->replyToId);
        p->telegram->messagesSendPhoto(p->peer, SuperTelegramService::generateRandomId(), path, p->replyToId);
    } else {
        p->telegram->messagesSendMessage(p->peer, SuperTelegramService::generateRandomId(), tr("Sorry. There is an error! I can't take image..."), p->replyToId);
        emit finished();
    }
}

void StgActionCaptureImage::messagesSendMediaAnswer(qint64 id, const UpdatesType &updates)
{
    Q_UNUSED(updates)
    if(p->reqId != id)
        return;
    if(!p->attachedMsg.isEmpty())
        p->telegram->messagesSendMessage(p->peer, SuperTelegramService::generateRandomId(), p->attachedMsg, p->replyToId);

    emit finished();
}

StgActionCaptureImage::~StgActionCaptureImage()
{
    delete p;
}

