#include "abstractstgaction.h"

AbstractStgAction::AbstractStgAction(QObject *parent) :
    QObject(parent)
{
    connect(this, SIGNAL(finished()), this, SLOT(deleteLater()));
}

AbstractStgAction::~AbstractStgAction()
{

}

