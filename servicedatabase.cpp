#define DATABASE_SRC_PATH ":/database/servicedb.sqlite"
#define DATABASE_DST_PATH QString(AsemanApplication::homePath() + "/servicedb.sqlite")

#include "servicedatabase.h"
#include "asemantools/asemanapplication.h"

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlError>
#include <QFile>
#include <QUuid>
#include <QFileInfo>

class ServiceDatabasePrivate
{
public:
    QSqlDatabase db;
    QString connectionName;
};

ServiceDatabase::ServiceDatabase(QObject *parent) : QObject(parent)
{
    p = new ServiceDatabasePrivate;
    p->connectionName = QUuid::createUuid().toString();

    if(!QFileInfo::exists(DATABASE_DST_PATH))
        QFile::copy(DATABASE_SRC_PATH, DATABASE_DST_PATH);

    QFile(DATABASE_DST_PATH).setPermissions(QFileDevice::ReadUser|QFileDevice::WriteUser|
                                  QFileDevice::ReadGroup|QFileDevice::WriteGroup);

    p->db = QSqlDatabase::addDatabase("QSQLITE", p->connectionName);
    p->db.setDatabaseName(DATABASE_DST_PATH);
    p->db.open();

    initBuffer();
}

void ServiceDatabase::initBuffer()
{

}

ServiceDatabase::~ServiceDatabase()
{
    delete p;
}

