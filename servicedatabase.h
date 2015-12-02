#ifndef SERVICEDATABASE_H
#define SERVICEDATABASE_H

#include <QObject>

class ServiceDatabasePrivate;
class ServiceDatabase : public QObject
{
    Q_OBJECT
public:
    ServiceDatabase(QObject *parent = 0);
    ~ServiceDatabase();

private:
    void initBuffer();

private:
    ServiceDatabasePrivate *p;
};

#endif // SERVICEDATABASE_H
