#ifndef ABSTRACTSTGACTION_H
#define ABSTRACTSTGACTION_H

#include <QObject>
#include <QStringList>

class InputPeer;
class Telegram;
class AbstractStgAction : public QObject
{
    Q_OBJECT
public:
    AbstractStgAction(QObject *parent = 0);
    ~AbstractStgAction();

    virtual QStringList keywords() const = 0;
    virtual void start(Telegram *tg, const InputPeer &peer, qint64 replyToId = 0, const QString &attachedMsg = QString()) = 0;

signals:
    void finished();
};

#endif // ABSTRACTSTGACTION_H
