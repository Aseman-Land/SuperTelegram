import QtQuick 2.0
import AsemanTools 1.0

Rectangle {
    width: 100
    height: 62
    color: "#fcfcfc"

    AboutPage {
        anchors.fill: parent
        defaultColor: "#2CA5E0"
        z: 100
        list: [stg_component, nile_component, osp_component, about_aseman]
    }

    AboutPageItem {
        id: stg_component
        title: "Application"
        color: "#2CA5E0"
        icon: "img/simple-icon.png"
        delegate: AboutStg{}
    }
    AboutPageItem {
        id: nile_component
        title: qsTr("Nile Group")
        color: "#00A0E3"
        icon: "img/simple-nilegroup.png"
        delegate: AboutNileGroup{}
    }
    AboutPageItem {
        id: osp_component
        title: qsTr("Open-Source")
        color: "#7BCF6A"
        icon: "img/simple-opensource.png"
        delegate: OpenSourceProjects{}
    }
    AboutPageAseman {
        id: about_aseman
    }
}

