#define ADD_USER_BLOCK_TIMER(USER_ID) { \
        int timerId = startTimer(5*60*1000); \
        p->userSentBlockTimer.insert(USER_ID, timerId); \
    }

#define IS_PREMIUM \
    (CHECK_INVENTORY_PURCHASED(p->store, stg_premium_pack) || \
     (p->stg && SuperTelegram::checkPremiumNumber(p->stg->phoneNumber())) || \
     AsemanDevices::isDesktop())

#define CHECK_INVENTORY(SKU) \
    (IS_PREMIUM || CHECK_INVENTORY_PURCHASED(p->store, SKU))

#include "supertelegramservice.h"
#include "supertelegram.h"
#include "asemantools/asemanapplication.h"
#include "asemantools/asemandevices.h"
#include "asemantools/asemannetworksleepmanager.h"
#include "asemantools/asemantools.h"
#include "commandsdatabase.h"
#include "stgstoremanagercore.h"

#include "stgactiongetgeo.h"
#include "stgactioncaptureimage.h"

#include "telegram.h"
#include "util/utils.h"

#include <QDir>
#include <QFileInfo>
#include <QTimer>
#include <QDebug>
#include <QTimerEvent>
#include <QPointer>
#include <QCameraInfo>
#include <QSet>
#include <QEventLoop>
#include <QHash>
#include <QImageReader>
#include <QBuffer>
#include <QCryptographicHash>
#include <QDataStream>
#include <QPair>

class SuperTelegramServicePrivate
{
public:
    QPointer<Telegram> telegram;
    QPointer<SuperTelegram> stg;
    QPointer<CommandsDatabase> db;
    QPointer<StgStoreManagerCore> store;

    QTimer *timerMessageClock;
    QTimer *tgUpdateDialogTimer;
    QTimer *picChangerClock;

    QTimer *tgSleepTimer;
    QTimer *tgWakeTimer;
    QTimer *tgUpdateTimer;
    QTimer *tgAutoUpdateTimer;

    AutoMessage activeAutoMessages;
    QList<SensMessage> sensMessages;
    qint64 profilePictureInterval;

    QList< QPair<QVariant,int> > pendingActions;
    QHash<qint64, QString> uploadingProfilePictures;
    QHash<qint64, qint64> userSentBlockTimer;

    AsemanNetworkSleepManager *sleepManager;
    bool external;
    qint64 profilePictureEstimatedTime;

    QSet<qint64> answeredMessages;
    QDateTime uptime;
};

SuperTelegramService::SuperTelegramService(QObject *parent) :
    QObject(parent)
{
    qsrand(QTime::currentTime().msec());

    p = new SuperTelegramServicePrivate;
    p->tgSleepTimer = 0;
    p->tgWakeTimer = 0;
    p->sleepManager = 0;
    p->profilePictureInterval = 0;
    p->external = false;
    p->uptime = QDateTime::currentDateTime();
    p->profilePictureEstimatedTime = 0;

    p->timerMessageClock = new QTimer(this);
    p->timerMessageClock->setSingleShot(true);

    p->picChangerClock = new QTimer(this);
    p->picChangerClock->setSingleShot(true);

    p->tgUpdateTimer = new QTimer(this);
    p->tgUpdateTimer->setInterval(3000);
    p->tgUpdateTimer->setSingleShot(true);

    p->tgAutoUpdateTimer = new QTimer(this);
    p->tgAutoUpdateTimer->setInterval(1*60*1000);
    p->tgAutoUpdateTimer->setSingleShot(false);
    p->tgAutoUpdateTimer->start();

    p->tgUpdateDialogTimer = new QTimer(this);
    p->tgUpdateDialogTimer->setInterval(5*60*1000);
    p->tgUpdateDialogTimer->setSingleShot(false);
    p->tgUpdateDialogTimer->start();

    connect(p->timerMessageClock, SIGNAL(timeout()), SLOT(clockTriggred()));
    connect(p->tgUpdateDialogTimer, SIGNAL(timeout()), SLOT(updateDialogs()));
    connect(p->tgUpdateTimer, SIGNAL(timeout()), SLOT(updatesGetState()));
    connect(p->tgAutoUpdateTimer, SIGNAL(timeout()), SLOT(updatesGetState()));
    connect(p->picChangerClock, SIGNAL(timeout()), SLOT(switchPicture()));
}

void SuperTelegramService::start(Telegram *tg, SuperTelegram *stg, AsemanNetworkSleepManager *sleepManager, StgStoreManagerCore *store)
{
    if(p->telegram)
        return;

    if(tg)
    {
        p->store = store;
        p->stg = stg;
        p->db = p->stg->database();
        p->telegram = tg;
        p->sleepManager = sleepManager;
        p->external = true;
    }
    else
    {
        p->store = new StgStoreManagerCore(this);
        p->stg = new SuperTelegram(this);

        p->sleepManager = new AsemanNetworkSleepManager(this);
        p->db = p->stg->database();

        const QString phoneNumber = p->stg->phoneNumber();
        const QString configPath = AsemanApplication::homePath();
        if(!QFileInfo::exists(configPath + "/" + phoneNumber + "/auth"))
        {
            QTimer::singleShot(1, AsemanApplication::instance(), SLOT(exit()));
            return;
        }

        QDir().mkpath(configPath);

        p->telegram = new Telegram(p->stg->defaultHostAddress(),
                                   p->stg->defaultHostPort(),
                                   p->stg->defaultHostDcId(),
                                   p->stg->appId(),
                                   p->stg->appHash(),
                                   phoneNumber,
                                   configPath,
                                   p->stg->publicKey());

        connect(p->telegram, SIGNAL(authNeeded()), SLOT(authNeeded()));
        QTimer::singleShot(1000, this, SLOT(initTelegram()));

        p->sleepManager->setHost(p->stg->defaultHostAddress());
        p->sleepManager->setPort(p->stg->defaultHostPort());
        p->sleepManager->setInterval(5000);
    }

    p->tgWakeTimer = new QTimer(this);
    p->tgWakeTimer->setInterval(1000);
    p->tgWakeTimer->setSingleShot(true);

    p->tgSleepTimer = new QTimer(this);
    p->tgSleepTimer->setInterval(30*60*1000);
    p->tgSleepTimer->setSingleShot(false);
    p->tgSleepTimer->start();

    connect(p->tgSleepTimer, SIGNAL(timeout()), this, SLOT(sleep()));
    connect(p->tgSleepTimer, SIGNAL(timeout()), p->tgWakeTimer, SLOT(start()));
    connect(p->tgWakeTimer, SIGNAL(timeout()), this, SLOT(wake()));

    connect(p->db, SIGNAL(autoMessageChanged())        , SLOT(updateAutoMessage()));
    connect(p->db, SIGNAL(sensMessageChanged())        , SLOT(updateSensMessage()));
    connect(p->db, SIGNAL(profilePictureTimerChanged()), SLOT(updatePPicChanged()));

    connect(p->telegram, SIGNAL(authLoggedIn()), SLOT(authLoggedIn()));
    connect(p->telegram, SIGNAL(updateShortMessage(qint32,qint32,QString,qint32,qint32,qint32,qint32,qint32,qint32,bool,bool)),
            SLOT(updateShortMessage(qint32,qint32,QString,qint32,qint32,qint32,qint32,qint32,qint32,bool,bool)));
    connect(p->telegram, SIGNAL(messagesGetDialogsAnswer(qint64,qint32,QList<Dialog>,QList<Message>,QList<Chat>,QList<User>)),
            SLOT(messagesGetDialogsAnswer(qint64,qint32,QList<Dialog>,QList<Message>,QList<Chat>,QList<User>)));
    connect(p->telegram, SIGNAL(photosUploadProfilePhotoAnswer(qint64,Photo,QList<User>)),
            SLOT(photosUploadProfilePhotoAnswer(qint64,Photo,QList<User>)));

    connect(p->sleepManager, SIGNAL(availableChanged()), SLOT(hostCheckerStateChanged()));

    updateAutoMessage();
    updateSensMessage();
    updatePPicChanged();
    startClock();
}

void SuperTelegramService::stop()
{
    if(!p->telegram)
        return;

    delete p->telegram;
    p->telegram = 0;

    p->timerMessageClock->stop();
}

void SuperTelegramService::authNeeded()
{
    AsemanApplication::exit(0);
}

void SuperTelegramService::authLoggedIn()
{
    qDebug() << "Logged In";
    p->telegram->updatesGetState();
}

void SuperTelegramService::clockTriggred()
{
    QDateTime dt = QDateTime::currentDateTime();

    checkPendingActions();
    checkTimerMessages(dt);
    checkProfilePicState(dt);

    startClock();
}

void SuperTelegramService::updateDialogs()
{
    if(!p->telegram)
        return;

    p->telegram->messagesGetDialogs();
}

void SuperTelegramService::updateProfilePictureEstimatedTime(const QDateTime &dt)
{
    int interval = 0;
    int state = p->profilePictureInterval;
    if(state < 0 && !p->db)
    {
        p->profilePictureEstimatedTime = 0;
        emit profilePictureEstimatedTimeChanged();
        return;
    }

    if(state >= 30)
        interval = (state-29)*7*24*60;
    else
    if(state >= 24)
        interval = (state-23)*24*60;
    else
        interval = (state+1)*60;

    QDateTime startDate = p->db->profilePictureTimerSource();
    const qint64 seconds = startDate.secsTo(dt)/60;

    int newTime = interval? (seconds%interval) : 0;
    p->profilePictureEstimatedTime = newTime? interval-newTime : 0;
    emit profilePictureEstimatedTimeChanged();
}

qint64 SuperTelegramService::profilePictureEstimatedTime() const
{
    return p->profilePictureEstimatedTime;
}

void SuperTelegramService::updateShortMessage(qint32 id, qint32 userId, const QString &message, qint32 pts, qint32 pts_count, qint32 date, qint32 fwd_from_id, qint32 fwd_date, qint32 reply_to_msg_id, bool unread, bool out)
{
    Q_UNUSED(pts)
    Q_UNUSED(pts_count)
    Q_UNUSED(date)
    Q_UNUSED(fwd_from_id)
    Q_UNUSED(fwd_date)
    Q_UNUSED(reply_to_msg_id)
    Q_UNUSED(message)

    if(!unread || out)
        return;
    if(p->userSentBlockTimer.contains(userId))
        return;
    if(p->answeredMessages.contains(id))
        return;

    InputPeer input(InputPeer::typeInputPeerContact);
    input.setUserId(userId);

    if(!p->activeAutoMessages.guid.isEmpty())
    {
        qDebug() << QString("Auto message (%1) activated on the new message.").arg(p->activeAutoMessages.message);
        processOnTheMessage(id, input, p->activeAutoMessages.message);
        p->answeredMessages.insert(id);
        ADD_USER_BLOCK_TIMER(userId)
    }
    else
    {
        foreach(const SensMessage &sens, p->sensMessages)
        {
            if(sens.userId && sens.userId != userId)
                continue;
            if(message.toLower().trimmed().contains(sens.key.toLower().trimmed()))
            {
                qDebug() << QString("Sens message (%1) activated on the new message.").arg(sens.key);
                processOnTheMessage(id, input, sens.value);
            }
        }
    }
}

void SuperTelegramService::messagesGetDialogsAnswer(qint64 id, qint32 sliceCount, const QList<Dialog> &dialogs, const QList<Message> &messages, const QList<Chat> &chats, const QList<User> &users)
{
    Q_UNUSED(id)
    Q_UNUSED(sliceCount)
    Q_UNUSED(dialogs)
    Q_UNUSED(users)
    Q_UNUSED(chats)

    const QDateTime &ct = QDateTime::currentDateTime();
    const qint64 uptimeDiff = p->uptime.secsTo(ct);
    qint64 maxTime = 15*60;
    if(maxTime > uptimeDiff)
        maxTime = uptimeDiff;

    foreach(const Message &m, messages)
    {
        if(m.toId().classType() == Peer::typePeerChat)
            continue;
        const qint64 secs = QDateTime::fromTime_t(m.date()).secsTo(ct);
        if(secs > maxTime)
            continue;

        updateShortMessage(m.id(), m.fromId(), m.message(), 0, 0, m.date(), m.fwdFromId(), m.fwdDate()
                           , m.replyToMsgId(), m.flags()&1, m.flags()&2);
    }
}

void SuperTelegramService::photosUploadProfilePhotoAnswer(qint64 id, const Photo &photo, const QList<User> &users)
{
    Q_UNUSED(users)

    const QString &hash = p->uploadingProfilePictures.take(id);
    if(hash.isEmpty())
        return;

    FileAccessHash acs_hash;
    acs_hash.fileId = photo.id();
    acs_hash.accessHash = photo.accessHash();

    p->db->addAccessHash(hash, acs_hash);
}

void SuperTelegramService::processOnTheMessage(qint32 id, const InputPeer &input, const QString &msg)
{
    QString attachedText = msg;
    if(!CHECK_INVENTORY(stg_by_stg))
        attachedText += "\n\nby SuperTelegram";

    const bool allowTags = CHECK_INVENTORY(stg_txt_tags);
    if(allowTags && msg.contains(StgActionGetGeo::keyword()))
    {
        StgActionGetGeo *action = new StgActionGetGeo(this);
        action->start(p->telegram, input, id, attachedText);
    }
    else
    if(allowTags && msg.contains(StgActionCaptureImage::keyword()))
    {
        StgActionCaptureImage *action = new StgActionCaptureImage(this);
        action->start(p->telegram, input, id, attachedText);
    }
    else
        p->telegram->messagesSendMessage(input, generateRandomId(), attachedText, id);
}

void SuperTelegramService::switchPicture()
{
    const QString &newFile = getNextProfilePicture();
    if(newFile.isEmpty())
        return;

    QImageReader reader(newFile);
    reader.setScaledSize(QSize(128,128));
    QImage img = reader.read();

    QByteArray data;
    QDataStream stream(&data, QIODevice::WriteOnly);
    stream << img;

    QString hash = QCryptographicHash::hash(data, QCryptographicHash::Md5).toHex();
    FileAccessHash fa_hash = p->db->getAccessHash(hash);
    if(fa_hash.accessHash)
    {
        p->telegram->photosUpdateProfilePhoto(fa_hash.fileId, fa_hash.accessHash);
        return;
    }

    qint64 id = p->telegram->photosUploadProfilePhoto(newFile);
    if(!id)
        return;

    p->uploadingProfilePictures[id] = hash;
}

QString SuperTelegramService::getNextProfilePicture() const
{
    QStringList files = QDir(p->stg->profilePicSwitcherLocation()).entryList(QDir::Files);
    if(files.isEmpty())
        return QString();

    return p->stg->profilePicSwitcherLocation() + "/" + files[qrand()%files.length()];
}

void SuperTelegramService::updateAutoMessage()
{
    if(!p->db) return;
    p->activeAutoMessages = p->db->autoMessageActiveMessage();
}

void SuperTelegramService::updateSensMessage()
{
    if(!p->db) return;
    p->sensMessages = p->db->sensMessageFetchAll();
}

void SuperTelegramService::updatePPicChanged()
{
    if(!p->db) return;
    p->profilePictureInterval = p->db->profilePictureTimer();
}

void SuperTelegramService::initTelegram()
{
    if(!p->telegram)
        return;

    p->telegram->init();
}

void SuperTelegramService::hostCheckerStateChanged()
{
    if(p->sleepManager->available())
        wake();
    else
        sleep();
}

void SuperTelegramService::updatesGetState()
{
    if(p->telegram) p->telegram->updatesGetState();
}

void SuperTelegramService::wake()
{
    qDebug() << __FUNCTION__;
    if(p->telegram) p->telegram->wake();
    p->tgUpdateTimer->stop();
    p->tgUpdateTimer->start();
    p->tgUpdateDialogTimer->stop();
    p->tgUpdateDialogTimer->start();
    p->tgAutoUpdateTimer->stop();
    p->tgAutoUpdateTimer->start();
}

void SuperTelegramService::sleep()
{
    qDebug() << __FUNCTION__;
    if(p->telegram) p->telegram->sleep();
    p->tgUpdateTimer->stop();
    p->tgUpdateDialogTimer->stop();
    p->tgAutoUpdateTimer->stop();
}

void SuperTelegramService::timerEvent(QTimerEvent *e)
{
    const qint64 userId = p->userSentBlockTimer.key(e->timerId());
    if(userId)
    {
        p->userSentBlockTimer.remove(userId);
        killTimer(e->timerId());
    }
}

void SuperTelegramService::startClock()
{
    const QTime &time = QTime::currentTime();
    const int msec = 60000 - (time.second()*1000 + time.msec()) + 1000;

    p->timerMessageClock->start(msec);
}

void SuperTelegramService::checkTimerMessages(const QDateTime &dt)
{
    if(!p->db) return;

    const QList<TimerMessage> &timerMessages = p->db->timerMessageFetch(dt);
    foreach(const TimerMessage &tm, timerMessages)
    {
        if(p->telegram->isSlept())
        {
            QPair<QVariant, int> pair;
            pair.first = QVariant::fromValue<TimerMessage>(tm);
            pair.second = 0;
            p->pendingActions << pair;
        }
        else
            processOnTheMessage(0, tm.peer, tm.message);
    }
}

void SuperTelegramService::checkProfilePicState(const QDateTime &dt)
{
    if(p->profilePictureInterval < 0)
        return;
    updateProfilePictureEstimatedTime(dt);
    if(p->profilePictureEstimatedTime != 0)
        return;

    switchPicture();
}

void SuperTelegramService::checkPendingActions()
{
    for(int i=0; i<p->pendingActions.count(); i++)
    {
        QPair<QVariant,int> pair = p->pendingActions[i];
        if(pair.first.type() == QVariant::nameToType(ASEMAN_TYPE_NAME(TimerMessage)))
        {
            TimerMessage tm = pair.first.value<TimerMessage>();
            if(p->telegram->isSlept())
                pair.second++;
            else
                processOnTheMessage(0, tm.peer, tm.message);
        }

        if(pair.second < 5)
            p->pendingActions[i] = pair;
        else
        {
            p->pendingActions.removeAt(i);
            i--;
        }
    }
}

qint64 SuperTelegramService::generateRandomId()
{
    qint64 randomId;
    Utils::randomBytes(&randomId, 8);
    return randomId;
}

SuperTelegramService::~SuperTelegramService()
{
    delete p;
}

