#ifndef ASEMANNETWORKCHECKER_H
#define ASEMANNETWORKCHECKER_H

#include <QObject>

class AsemanNetworkCheckerPrivate;
class AsemanNetworkChecker : public QObject
{
    Q_OBJECT
public:
    AsemanNetworkChecker(QObject *parent = 0);
    ~AsemanNetworkChecker();

    bool online() const;

signals:
    void onlineChanged();

private:
    AsemanNetworkCheckerPrivate *p;
};

#endif // ASEMANNETWORKCHECKER_H
