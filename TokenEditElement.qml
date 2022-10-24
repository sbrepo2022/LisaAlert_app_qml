import QtQuick 2.11
import QtQuick.Controls 2.4

Item {
    FontLoader {
        id: montserratFont
        source: "qrc:/fonts/Montserrat-Regular.ttf"
    }

    property int radius: 0
    property int textSize: 20
    property alias text: tokenText.text
    property alias preeditText: tokenText.preeditText
    signal takePhoto

    id: topRect
    height: tokenText.height
    Rectangle {
        id: borderLeft
        anchors.left: parent.left
        anchors.right: borderRight.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        radius: parent.radius
        color: "#ccc"

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.radius
            color: parent.color
        }

        Rectangle {
            id: bgLeft
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "#f8f8f8"

            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.radius
                color: parent.color
            }

            TextField {
                id: tokenText
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                placeholderText: "Введите токен..."
                font.pixelSize: topRect.textSize
                font.family: "Montserrat"
                color: "#000"
                background: Rectangle {
                    color: "#00000000"
                }
                padding: parent.radius

                validator: RegExpValidator {
                    regExp: /[0-9a-zA-Z]{0,5}/
                }

            }
        }
    }

    Rectangle {
        id: borderRight
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: height
        radius: parent.radius
        color: "#0075BD"

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.radius
            color: parent.color
        }

        Rectangle {
            id: bgRight
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "#0095DD"

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.radius
                color: parent.color
            }
        }

        Image {
            anchors.fill: parent
            anchors.margins: parent.width / 6
            source: "qrc:/textures/photo.svg"
            sourceSize: Qt.size(width, height);
            smooth: true
        }

        MouseArea {
            anchors.fill: parent
            onPressed: {
                bgRight.color = "#0075BD";
            }
            onReleased: {
                bgRight.color = "#0095DD";
            }
            onClicked: {
                topRect.takePhoto();
            }
        }
    }
}


