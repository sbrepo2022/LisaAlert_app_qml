import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Controls 2.4

Item {
    property int radius: 0
    property int textSize: 20
    property alias text: nameText.text

    function mp(x) {
        return Screen.pixelDensity * x;
    }

    id: topRect
    height: nameText.height
    Rectangle {
        id: border
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        radius: parent.radius
        color: "#ccc"

        Rectangle {
            id: bgLeft
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "#f8f8f8"

            TextField {
                id: nameText
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: searchButton.left
                placeholderText: "Найти место..."
                font.pixelSize: topRect.textSize
                font.family: "Montserrat"
                color: "#000"
                background: Rectangle {
                    color: "#00000000"
                }
                padding: parent.radius
            }
            Rectangle {
                id: searchButton
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: mp(1)
                width: height
                color: "#00000000"

                Image {
                    anchors.fill: parent
                    anchors.margins: parent.height / 8
                    source: "qrc:/textures/search.svg"
                    sourceSize: Qt.size(width, height)
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                    }
                }
            }
        }
    }
}
