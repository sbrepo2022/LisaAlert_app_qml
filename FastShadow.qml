import QtQuick 2.11
import QtQuick.Window 2.11
import QtGraphicalEffects 1.12

Item {
    property string color: "#000"
    property int radius: 0
    property int borderRadius: 0
    property int verticalOffset: 0
    property int horizontalOffset: 0
    Rectangle {
        id: shadowRect
        anchors.centerIn: parent
        width: parent.width - 2
        height: parent.height - 2
        radius: parent.borderRadius
        color: parent.color
    }

    FastBlur {
        id: blur
        anchors.centerIn: shadowRect
        anchors.verticalCenterOffset: parent.verticalOffset
        anchors.horizontalCenterOffset: parent.horizontalOffset
        width: shadowRect.width
        height: shadowRect.height
        source: shadowRect
        radius: parent.radius
        transparentBorder: true
        cached: true
    }
}
