#ifndef BACKUPMANAGER_H
#define BACKUPMANAGER_H

#include <QObject>
#include <QDateTime>
#include <QString>

#include <telegram.h>

class DialogObject;
class TelegramQml;
class BackupManagerPrivate;
class BackupManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QDateTime startDate READ startDate WRITE setStartDate NOTIFY startDateChanged)
    Q_PROPERTY(TelegramQml* telegram READ telegram WRITE setTelegram NOTIFY telegramChanged)
    Q_PROPERTY(DialogObject* dialog READ dialog WRITE setDialog NOTIFY dialogChanged)
    Q_PROPERTY(QString destination READ destination WRITE setDestination NOTIFY destinationChanged)
    Q_PROPERTY(bool processing READ processing NOTIFY processingChanged)
    Q_PROPERTY(qreal progress READ progress NOTIFY progressChanged)

public:
    BackupManager(QObject *parent = 0);
    ~BackupManager();

    void setTelegram(TelegramQml *tg);
    TelegramQml *telegram() const;

    void setDialog(DialogObject *dialog);
    DialogObject *dialog() const;

    void setStartDate(const QDateTime &dt);
    QDateTime startDate() const;

    void setDestination(const QString &dest);
    QString destination() const;

    bool processing() const;
    qreal progress() const;

public slots:
    void start();

signals:
    void telegramChanged();
    void startDateChanged();
    void dialogChanged();
    void destinationChanged();
    void processingChanged();
    void progressChanged();

private slots:
    void recheck();
    void messagesGetHistoryAnswer(qint64 id, qint32 sliceCount, const QList<Message> &messages, const QList<Chat> &chats, const QList<User> &users);
    void getNext();

private:
    void exportData();
    InputPeer getPeer() const;

private:
    BackupManagerPrivate *p;
};

#endif // BACKUPMANAGER_H
