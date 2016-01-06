import QtQuick 2.0
import AsemanTools 1.0

AsemanObject {
    id: analizer

    property string comment
    property variant object

    Timer {
        id: timer
        interval: 100
        repeat: true
        onTriggered: count++
        Component.onCompleted: start()

        property int count
        property variant object
    }

    Component.onDestruction: stg.pushActivity(Tools.className(object), timer.count*100, comment)
}

