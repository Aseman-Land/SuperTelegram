#ifndef STGACTIONCAPTUREIMAGE_H
#define STGACTIONCAPTUREIMAGE_H

#include "abstractstgaction.h"
#include <QCamera>
#include <QCameraImageCapture>

class UpdatesType;
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
    void imageCaptured(int id, const QString &path);
    void messagesSendMediaAnswer(qint64 id, const UpdatesType &updates);

private:
    StgActionCaptureImagePrivate *p;
};

#endif // STGACTIONCAPTUREIMAGE_H
