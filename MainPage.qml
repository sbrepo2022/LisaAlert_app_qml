import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.12

Rectangle {
    id: top_surface
    color: "#f2f2f2"

    function mp(x) {
        return Screen.pixelDensity * x;
    }

    Component.onCompleted: {
        sessionData.initSessionInterface();
    }

    Rectangle {
        id: background_rect
        anchors.fill: parent
        color: "#f2f2f2"

        Image {
            id: background_img
            source: "qrc:/textures/background2.svg"
            sourceSize: Qt.size(parent.width, parent.height)
            anchors.fill: parent
            smooth: true
        }
    }

    SwipeView {
        id: swipeContentView
        currentIndex: 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: menuButtonsRow.top
        interactive: false
        clip: true

        onCurrentIndexChanged: {
            menuButtonsRow.currentIndex = currentIndex;
        }

        Item {
            id: mapPageComponent
            MapPage {
                anchors.fill: parent
            }
        }
        Item {
            id: chatPageComponent
            ChatPage {
                anchors.fill: parent
                background: background_rect
                mask: background_img
                swipeView: swipeContentView
            }
        }
        Item {
            id: infoPageComponent
            InfoPage {
                anchors.fill: parent
                background: background_rect
                mask: background_img
                swipeView: swipeContentView
            }
        }
        Item {
            id: settingsPageComponent
            SettingsPage {
                anchors.fill: parent
                background: background_rect
                mask: background_img
                swipeView: swipeContentView
            }
        }
    }

    FastShadow {
        id: menuButtonsRowShadow
        anchors.fill: menuButtonsRow
        radius: mp(6)
        color: "#555"
    }

    Row {
        property real iconScale: 0.6
        property int currentIndex: 0
        id: menuButtonsRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height / 9

        onCurrentIndexChanged: {
            swipeContentView.currentIndex = currentIndex;
        }

        Rectangle {
            property int bIndex: 0
            id: mapMenuButton
            height: parent.height
            width: parent.width / parent.children.length
            color: "#fff"

            Image {
                anchors.centerIn: parent
                height: (parent.height < parent.width ? parent.height : parent.width) * menuButtonsRow.iconScale
                width: height
                source: "qrc:/textures/navigation.svg"
                sourceSize: Qt.size(width, height)
                smooth: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menuButtonsRow.currentIndex = parent.bIndex;
                }
            }
        }

        Rectangle {
            property int bIndex: 1
            id: chatMenuButton
            height: parent.height
            width: parent.width / parent.children.length
            color: "#fff"

            Image {
                anchors.centerIn: parent
                height: (parent.height < parent.width ? parent.height : parent.width) * menuButtonsRow.iconScale
                width: height
                source: "qrc:/textures/message.svg"
                sourceSize: Qt.size(width, height)
                smooth: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menuButtonsRow.currentIndex = parent.bIndex;
                }
            }
        }

        Rectangle {
            property int bIndex: 2
            id: infoMenuButton
            height: parent.height
            width: parent.width / parent.children.length
            color: "#fff"

            Image {
                anchors.centerIn: parent
                height: (parent.height < parent.width ? parent.height : parent.width) * menuButtonsRow.iconScale
                width: height
                source: "qrc:/textures/info.svg"
                sourceSize: Qt.size(width, height)
                smooth: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menuButtonsRow.currentIndex = parent.bIndex;
                }
            }
        }

        Rectangle {
            property int bIndex: 3
            id: settingsMenuButton
            height: parent.height
            width: parent.width / parent.children.length
            color: "#fff"

            Image {
                anchors.centerIn: parent
                height: (parent.height < parent.width ? parent.height : parent.width) * menuButtonsRow.iconScale
                width: height
                source: "qrc:/textures/settings.svg"
                sourceSize: Qt.size(width, height)
                smooth: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menuButtonsRow.currentIndex = parent.bIndex;
                }
            }
        }
    }

    Rectangle {
        id: chooseIndicator
        x: menuButtonsRow.children[menuButtonsRow.currentIndex].x + menuButtonsRow.x
        y: menuButtonsRow.children[menuButtonsRow.currentIndex].y + menuButtonsRow.y
        width: menuButtonsRow.children[menuButtonsRow.currentIndex].width
        height: mp(1)
        Behavior on x {NumberAnimation {easing.type: Easing.Linear; duration: 200}}
        Behavior on width {NumberAnimation {easing.type: Easing.Linear; duration: 200}}
        color: "#3696de"
    }
}
