#include "abstractstgaction.h"

#include <QTimer>

AbstractStgAction::AbstractStgAction(QObject *parent) :
    QObject(parent)
{
    connect(this, SIGNAL(finished()), this, SLOT(deleteLater()));
}

AbstractStgAction::~AbstractStgAction()
{

}

void AbstractStgAction::startTimout(int ms)
{
    QTimer *timout = new QTimer(this);
    timout->start(ms);
    connect(timout, SIGNAL(timeout()), SIGNAL(finished()));
}

