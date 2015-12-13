#include "stgactioncaptureimage.h"
#include "supertelegramservice.h"
#include "telegram.h"

#include <QPointer>
#include <QCameraInfo>
#include <QCamera>
#include <QCameraImageCapture>

class StgActionCaptureImagePrivate
{
public:
    QPointer<Telegram> telegram;
    QString attachedMsg;
    InputPeer peer;
    qint64 replyToId;

    QPointer<QCamera> camera;
    QPointer<QCameraImageCapture> capture;
};

StgActionCaptureImage::StgActionCaptureImage(QObject *parent) :
    AbstractStgAction(parent)
{
    p = new StgActionCaptureImagePrivate;
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

    QList<QCameraInfo> cameras = QCameraInfo::availableCameras();
    if(cameras.isEmpty())
    {
        emit finished();
        return;
    }

    QCameraInfo device = cameras.first();
    foreach(const QCameraInfo &inf, cameras)
        if(inf.position() == QCamera::FrontFace)
        {
            device = inf;
            break;
        }

    p->camera = new QCamera(device);
    p->camera->setCaptureMode(QCamera::CaptureStillImage);

    connect(p->camera, SIGNAL(stateChanged(QCamera::State)),
            this, SLOT(cameraStateChanged(QCamera::State)));
    connect(p->camera, SIGNAL(error(QCamera::Error)),
            this, SLOT(cameraStartFailed(QCamera::Error)));

    p->camera->start();
}

void StgActionCaptureImage::cameraStartFailed(QCamera::Error error)
{
    if(error == QCamera::NoError)
        return;

    qDebug() << p->camera->error() << p->camera->errorString();
    finish();
}

void StgActionCaptureImage::cameraStateChanged(QCamera::State state)
{
    if(state != QCamera::ActiveState)
        return;

    connect(p->camera, SIGNAL(locked()),
            this, SLOT(cameraLocked()));
    connect(p->camera, SIGNAL(lockFailed()),
            this, SLOT(cameraLockFailed()));

    p->camera->searchAndLock();
}

void StgActionCaptureImage::cameraLocked()
{
    p->capture = new QCameraImageCapture(p->camera, this);

    connect(p->capture, SIGNAL(imageSaved(int,QString)),
            this, SLOT(cameraCaptureImageSaved(int,QString)));
    connect(p->capture, SIGNAL(error(int,QCameraImageCapture::Error,QString)),
            this, SLOT(cameraCaptureError(int,QCameraImageCapture::Error,QString)));
}

void StgActionCaptureImage::cameraLockFailed()
{
    finish();
}

void StgActionCaptureImage::cameraCaptureImageSaved(int id, const QString &fileName)
{
    Q_UNUSED(id)
    p->telegram->messagesSendPhoto(p->peer, SuperTelegramService::generateRandomId(), fileName, p->replyToId);
    if(!p->attachedMsg.isEmpty())
        p->telegram->messagesSendMessage(p->peer, SuperTelegramService::generateRandomId(), p->attachedMsg, p->replyToId);

    finish();
}

void StgActionCaptureImage::cameraCaptureError(int id, QCameraImageCapture::Error error, const QString &errorString)
{
    Q_UNUSED(id)
    qDebug() << error << errorString;
    finish();
}

void StgActionCaptureImage::finish()
{
    if(p->camera)
    {
        p->camera->deleteLater();
        p->camera = 0;
    }
    if(p->capture)
    {
        p->capture->deleteLater();
        p->capture = 0;
    }
    emit finished();
}

StgActionCaptureImage::~StgActionCaptureImage()
{
    delete p;
}

