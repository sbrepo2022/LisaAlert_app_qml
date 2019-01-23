import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.12

Item {
    property bool isChecked: true
    property string text: ""
    id: top_surface
    width: childrenRect.width
    Rectangle {
        id: checkIndicator
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        width: height
        radius: height / 6
        color: top_surface.isChecked ? "#00003c" : "#fff"
        border.color: "#00003c"
        border.width: height / 8

        Behavior on color {
            ColorAnimation {duration: 100;}
        }

        Image {
            anchors.fill: parent
            source: "qrc:/textures/done.svg"
            sourceSize: Qt.size(width, height)
            smooth: true

            transform: Scale {
                id: sTransform
                origin.x: checkIndicator.width / 2
                origin.y: checkIndicator.height / 2
                xScale: top_surface.isChecked ? 1.0 : 0.0
                yScale: top_surface.isChecked ? 1.0 : 0.0

                Behavior on xScale {
                    NumberAnimation {duration: 100;}
                }

                Behavior on yScale {
                    NumberAnimation {duration: 100;}
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            isChecked = !isChecked;
        }
    }

    Text {
        id: title
        anchors.left: checkIndicator.right
        anchors.leftMargin: mp(4)
        anchors.verticalCenter: parent.verticalCenter
        text: top_surface.text
        color: "#000"
        font.pixelSize: mp(3)
        font.family: "Montserrat"
    }
}
