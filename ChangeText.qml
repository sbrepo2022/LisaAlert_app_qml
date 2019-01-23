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
    property alias placeholderText: tokenText.placeholderText
    signal changeName

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
                placeholderText: "Введите текст..."
                font.pixelSize: topRect.textSize
                font.family: "Montserrat"
                color: "#000"
                background: Rectangle {
                    color: "#00000000"
                }
                padding: parent.radius

                validator: RegExpValidator {
                    regExp: /[\w ]{0,64}/
                }
                onTextEdited: {
                    if (borderRight.isDone) {
                        image.source = "qrc:/textures/done.svg";
                        borderRight.color = "#0075BD";
                        bgRight.color = "#0095DD";
                    }
                    borderRight.isDone = false;
                }
            }
        }
    }

    Rectangle {
        property bool isDone: true
        id: borderRight
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: height
        radius: parent.radius
        color: "#ccc"

        Behavior on color {
            ColorAnimation {duration: 300;}
        }

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
            color: "#f8f8f8"
            Behavior on color {
                ColorAnimation {duration: 300;}
            }

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.radius
                color: parent.color
            }
        }

        Image {
            id: image
            anchors.fill: parent
            anchors.margins: parent.width / 6
            source: "qrc:/textures/done2.svg"
            sourceSize: Qt.size(width, height);
            smooth: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (! borderRight.isDone) {
                    image.source = "qrc:/textures/done2.svg";
                    borderRight.color = "#ccc";
                    bgRight.color = "#f8f8f8";
                    topRect.changeName();
                }
                borderRight.isDone = true;
            }
        }
    }
}


