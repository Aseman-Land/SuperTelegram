#include "commandsdatabase.h"

class CommandsDatabasePrivate
{
public:
};

CommandsDatabase::CommandsDatabase(QObject *parent) :
    QObject(parent)
{
    p = new CommandsDatabasePrivate;
}

CommandsDatabase::~CommandsDatabase()
{
    delete p;
}

