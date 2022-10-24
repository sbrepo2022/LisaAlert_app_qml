import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.12

Item {
    id: top_surface
    signal checked
    signal unchecked
    property string imgSource
    property string imgAltSource
    property bool isChecked: true

    FastShadow {
        id: checkButtonShadow
        anchors.fill: checkButton
        radius: mp(6)
        verticalOffset: mp(1)
        borderRadius: checkButton.radius
        color: "#555"
    }

    Rectangle {
        id: checkButton

        anchors.centerIn: parent
        height: parent.height < parent.width ? parent.height : parent.width
        width: height
        radius: height / 2
        color: top_surface.isChecked ? "#3696de" : "#fff"

        Behavior on color {
            ColorAnimation {duration: 300;}
        }

        Image {
            anchors.fill: parent
            source: top_surface.isChecked ? imgAltSource : imgSource
            sourceSize: Qt.size(width, height)
            smooth: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                top_surface.isChecked = ! top_surface.isChecked;
                top_surface.isChecked ? top_surface.checked() : top_surface.unchecked();
            }
        }
    }
}
