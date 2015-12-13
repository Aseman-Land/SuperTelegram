#ifndef STGACTIONCAPTUREIMAGE_H
#define STGACTIONCAPTUREIMAGE_H

#include "abstractstgaction.h"
#include <QCamera>
#include <QCameraImageCapture>

class StgActionCaptureImagePrivate;
class StgActionCaptureImage : public AbstractStgAction
{
    Q_OBJECT
public:
    StgActionCaptureImage(QObject *parent = 0);
    ~StgActionCaptureImage();

    QStringList keywords() const;
    void start(Telegram *tg, const InputPeer &peer, qint64 replyToId = 0, const QString &attachedMsg = QString());

private slots:
    void cameraStartFailed(QCamera::Error error);
    void cameraStateChanged(QCamera::State state);
    void cameraLocked();
    void cameraLockFailed();
    void cameraCaptureImageSaved(int id, const QString &fileName);
    void cameraCaptureError(int id, QCameraImageCapture::Error error, const QString &errorString);

private:
    void finish();

private:
    StgActionCaptureImagePrivate *p;
};

#endif // STGACTIONCAPTUREIMAGE_H
