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

class StgActionCaptureImagePrivate
{
public:
    QPointer<Telegram> telegram;
    QString attachedMsg;
    InputPeer peer;
    qint64 replyToId;
    AsemanCameraCapture *camera;
};

StgActionCaptureImage::StgActionCaptureImage(QObject *parent) :
    AbstractStgAction(parent)
{
    p = new StgActionCaptureImagePrivate;
    p->camera = 0;
}

QStringList StgActionCaptureImage::keywords() const
{
    return QStringList() << "%camera%" << "%capture%";
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

    QString filePath = newDirPath + "/" + QUuid::createUuid().toString() + ".jpg";
    p->camera = new AsemanCameraCapture(this);

    connect(p->camera, SIGNAL(imageCaptured(int,QString)), SLOT(imageCaptured(int,QString)));

    p->camera->capture(filePath, AsemanCameraCapture::CameraFacingBack);
}

void StgActionCaptureImage::imageCaptured(int id, const QString &path)
{
    if(id && !path.isEmpty())
    {
        p->telegram->messagesSendPhoto(p->peer, SuperTelegramService::generateRandomId(), path, p->replyToId);
        if(!p->attachedMsg.isEmpty())
            p->telegram->messagesSendMessage(p->peer, SuperTelegramService::generateRandomId(), p->attachedMsg, p->replyToId);
    }

    emit finished();
}

StgActionCaptureImage::~StgActionCaptureImage()
{
    delete p;
}

