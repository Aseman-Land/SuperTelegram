#ifndef COMMANDSDATABASE_H
#define COMMANDSDATABASE_H

#include <QObject>

class CommandsDatabasePrivate;
class CommandsDatabase : public QObject
{
    Q_OBJECT
public:
    CommandsDatabase(QObject *parent = 0);
    ~CommandsDatabase();

private:
    CommandsDatabasePrivate *p;
};

#endif // COMMANDSDATABASE_H
