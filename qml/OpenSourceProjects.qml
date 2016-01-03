/*
    Copyright (C) 2015 Nile Group
    http://nilegroup.org

    Kaqaz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Kaqaz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import AsemanTools 1.0

Item {

    ListView {
        id: preference_list
        anchors.fill: parent
        highlightMoveDuration: 250
        bottomMargin: View.navigationBarHeight
        clip: true
        focus: true
        boundsBehavior: Flickable.StopAtBounds
        rebound: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 0
            }
        }

        header: Text {
            width: preference_list.width
            anchors.margins: 8*Devices.density
            font.family: AsemanApp.globalFont.family
            font.pixelSize: 9*fontRatio*Devices.fontDensity
            color: "#444444"
            text: qsTr("List of other opensource projects used in Meikade.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        model: ListModel {}
        delegate: Item {
            id: item
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*Devices.density
            height: column.height + 40*Devices.density

            Column {
                id: column
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10*Devices.density
                spacing: 3*Devices.density

                Item {
                    id: title_item
                    height: title_txt.height
                    width: column.width

                    Text {
                        id: title_txt
                        font.pixelSize: 14*fontRatio*Devices.fontDensity
                        anchors.left: parent.left
                        color: "#444444"
                        text: title
                    }

                    Text {
                        id: license_txt
                        font.pixelSize: 10*fontRatio*Devices.fontDensity
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        color: "#777777"
                        text: license
                    }
                }

                Text {
                    id: description_txt
                    font.pixelSize: 9*fontRatio*Devices.fontDensity
                    anchors.left: parent.left
                    anchors.right: parent.right
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: "#666666"
                    text: description
                }

                Text {
                    id: link_txt
                    font.pixelSize: 9*fontRatio*Devices.fontDensity
                    color: "#0d80ec"
                    text: link

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.openUrlExternally(link_txt.text)
                    }
                }
            }
        }

        Component.onCompleted: {
            model.clear()

            model.append({"title": "libqtelegram-ae", "license": "GNU GPL v3", "link": "https://github.com/Aseman-Land/libqtelegram-aseman-edition", "description": "It's a fork of libqtelegram by Aseman Team which is porting to windows and mac alongside linux support. It's also build using qmake instead of cmake."})
            model.append({"title": "TelegramQml", "license": "GNU GPL v3", "link": "https://github.com/Aseman-Land/TelegramQML", "description": "Telegram API tools for QtQml and Qml. It's based on Cutegram-Core and libqtelegram."})
            model.append({"title": "OpenSSL", "license": "	Apache", "link": "https://www.openssl.org/", "description": "The OpenSSL Project is a collaborative effort to develop a robust, commercial-grade, full-featured, and Open Source toolkit implementing the Transport Layer Security (TLS) and Secure Sockets Layer (SSL) protocols as well as a full-strength general purpose cryptography library."})
            model.append({"title": "Qt Framework " + Tools.qtVersion(), "license": "GNU GPL v3", "link": "http://qt.io", "description": "Qt is a cross-platform application and UI framework for developers using C++ or QML, a CSS & JavaScript like language."})
            model.append({"title": "QtSingleApplication", "license": "GNU GPL v3", "link": "https://github.com/lycis/QtDropbox/", "description": "The QtSingleApplication component provides support for applications that can be only started once per user."})
            model.append({"title": "Aseman Qt Tools", "license": "GNU GPL v3", "link": "https://github.com/aseman-labs/aseman-qt-tools", "description": "Some tools, creating for Aseman Qt projects and used on many of Aseman's projects"})
            model.append({"title": "SimpleQtCryptor", "license": "GNU GPL v3", "link": "http://zo0ok.com/techfindings/archives/595", "description": "Simple Qt encryption library and tools."})

            focus = true
        }
    }

    ScrollBar {
        scrollArea: preference_list; height: preference_list.height - View.navigationBarHeight
        width: 6*Devices.density
        anchors.right: preference_list.right; anchors.top: preference_list.top;
        color: "#7BCF6A"
    }
}
