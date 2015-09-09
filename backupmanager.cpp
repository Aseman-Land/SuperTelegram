#define HISTORY_LIMITS 50

#include "backupmanager.h"

#include <telegramqml.h>
#include <objects/types.h>

#include <QPointer>
#include <QHash>

class BackupManagerPrivate
{
public:
    QPointer<TelegramQml> telegram;
    QPointer<DialogObject> dialog;

    QDateTime startDate;
    bool connected;
    bool start;
    qreal progress;
    QString destination;

    QSet<qint64> ids;
    int offsets;

    QHash<qint64, Message> messages;
    QHash<qint64, User> users;
    QHash<qint64, Chat> chats;
    QList<qint64> messageIds;
};

BackupManager::BackupManager(QObject *parent) :
    QObject(parent)
{
    p = new BackupManagerPrivate;
    p->connected = false;
    p->start = false;
    p->offsets = 0;
    p->progress = 0;
}

void BackupManager::setTelegram(TelegramQml *tg)
{
    if(p->telegram == tg)
        return;
    if(p->telegram)
    {
        disconnect(p->telegram->telegram(), SIGNAL(messagesGetHistoryAnswer(qint64,qint32,QList<Message>,QList<Chat>,QList<User>)), this,
                   SLOT(messagesGetHistoryAnswer(qint64,qint32,QList<Message>,QList<Chat>,QList<User>)));
        disconnect(p->telegram, SIGNAL(authLoggedInChanged()), this, SLOT(recheck()));
    }

    p->telegram = tg;
    p->connected = false;
    p->start = false;

    if(p->telegram)
        connect(p->telegram, SIGNAL(authLoggedInChanged()), this, SLOT(recheck()), Qt::QueuedConnection);

    recheck();
    emit telegramChanged();
}

TelegramQml *BackupManager::telegram() const
{
    return p->telegram;
}

void BackupManager::setDialog(DialogObject *dialog)
{
    if(p->dialog == dialog)
        return;

    p->dialog = dialog;
    p->start = false;

    emit dialogChanged();
}

DialogObject *BackupManager::dialog() const
{
    return p->dialog;
}

void BackupManager::setStartDate(const QDateTime &dt)
{
    if(p->startDate == dt)
        return;

    p->startDate = dt;
    p->start = false;

    emit startDateChanged();
}

QDateTime BackupManager::startDate() const
{
    return p->startDate;
}

void BackupManager::setDestination(const QString &dest)
{
    if(p->destination == dest)
        return;

    p->destination = dest;
    emit destinationChanged();
}

QString BackupManager::destination() const
{
    return p->destination;
}

bool BackupManager::processing() const
{
    return p->ids.count();
}

qreal BackupManager::progress() const
{
    return p->progress;
}

void BackupManager::start()
{
    if(p->startDate.isNull())
        return;
    if(!p->dialog)
        return;
    if(!p->telegram || !p->telegram->authLoggedIn())
    {
        p->start = true;
        return;
    }

    p->offsets = 0;
    p->progress = 0;
    p->users.clear();
    p->chats.clear();
    p->messages.clear();
    p->messageIds.clear();

    getNext();

    emit progressChanged();
}

void BackupManager::recheck()
{
    if(!p->telegram || !p->telegram->authLoggedIn())
        return;

    connect(p->telegram->telegram(), SIGNAL(messagesGetHistoryAnswer(qint64,qint32,QList<Message>,QList<Chat>,QList<User>)),
            SLOT(messagesGetHistoryAnswer(qint64,qint32,QList<Message>,QList<Chat>,QList<User>)));

    if(p->start)
        start();
}

void BackupManager::messagesGetHistoryAnswer(qint64 id, qint32 sliceCount, const QList<Message> &messages, const QList<Chat> &chats, const QList<User> &users)
{
    p->ids.remove(id);
    Q_UNUSED(sliceCount)

    QDateTime minimumTime;

    bool contains_old_message = false;
    foreach(const User &u, users)
        p->users[u.id()] = u;
    foreach(const Chat &c, chats)
        p->chats[c.id()] = c;
    foreach(const Message &m, messages)
    {
        if(QDateTime::fromTime_t(m.date()) < p->startDate)
        {
            contains_old_message = true;
            continue;
        }

        if(minimumTime.isNull())
            minimumTime = QDateTime::fromTime_t(m.date());
        else
        if(QDateTime::fromTime_t(m.date()) < minimumTime)
            minimumTime = QDateTime::fromTime_t(m.date());

        p->messages[m.id()] = m;
        p->messageIds << m.id();
    }

    if(!contains_old_message || messages.count()<HISTORY_LIMITS)
    {
        getNext();
        p->progress = 100.0*minimumTime.secsTo(QDateTime::currentDateTime())/
                      p->startDate.secsTo(QDateTime::currentDateTime());
    }
    else
    {
        exportData();
        p->progress = 100;
    }

    emit processingChanged();
    emit progressChanged();
}

void BackupManager::getNext()
{
    if(!p->telegram || !p->telegram->telegram())
        return;

    qint64 id = p->telegram->telegram()->messagesGetHistory(getPeer(), p->offsets, 0, HISTORY_LIMITS);

    p->offsets += HISTORY_LIMITS;
    p->ids.insert(id);

    emit processingChanged();
}

void BackupManager::exportData()
{
    if(p->destination.isEmpty())
        return;

    QFile file(p->destination);
    if(!file.open(QFile::WriteOnly))
        return;

    QString result;
    for(int i=p->messageIds.count()-1; i>=0; i--)
    {
        const qint64 id = p->messageIds.at(i);
        const Message &message = p->messages.value(id);
        const User &fromUser = p->users.value(message.fromId());
        const QString &dateStr = QDateTime::fromTime_t(message.date()).toString();
        const QString &userName = QString("%1 %2").arg(fromUser.firstName()).arg(fromUser.lastName()).trimmed();

        result += tr("Message From: %1 on %2\n").arg(userName).arg(dateStr);
        switch(static_cast<int>(message.classType()))
        {
        case Message::typeMessage:
            if(message.media().classType() != MessageMedia::typeMessageMediaEmpty)
            {
                result += tr("Message media is not supported yet.");
                if(!message.media().caption().isEmpty())
                    result += "\n" + message.media().caption();
            }
            else
                result += message.message();
            break;

        case Message::typeMessageService:
            result += tr("Message service is not supported yet.");
            break;
        }

        result += "\n\n";
    }

    file.write(result.toUtf8());
    file.close();
}

InputPeer BackupManager::getPeer() const
{
    if(!p->dialog || !p->telegram)
        return InputPeer();

    PeerObject *peer = p->dialog->peer();
    return p->telegram->getInputPeer(peer->chatId()? peer->chatId() : peer->userId());
}

BackupManager::~BackupManager()
{
    delete p;
}

