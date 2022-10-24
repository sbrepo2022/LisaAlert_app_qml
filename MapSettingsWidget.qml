import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.12

Item {
    id: top_surface

    function mp(x) {
        return Screen.pixelDensity * x;
    }

    FastShadow {
        id: slideButtonShadow
        anchors.fill: slideButton
        radius: mp(6)
        borderRadius: mp(3)
        color: "#aaa"
    }

    Rectangle {
        id: slideButton
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: mp(2)
        width: slideText.width
        height: slideText.height
        radius: mp(3)
        color: "#fff"

        Text {
            id: slideText
            text: "Настройки"
            font.pixelSize: mp(3)
            font.family: "Montserrat"
            color: "#000"
            padding: parent.radius
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                topRect.dDuration = topRect.fDuration;
                topRect.state = "opened";
            }
        }
    }

    FastShadow {
        id: topRectShadow
        anchors.fill: topRect
        radius: mp(6)
        borderRadius: mp(3)
        color: "#aaa"
    }

    Rectangle {
        property int yOffset: 0
        property int dDuration
        property int fDuration: 300
        id: topRect
        anchors.left: parent.left
        anchors.right: parent.right
        x: 0
        y: top_surface.y - topRect.height + yOffset
        height: widgetContent.height + slider.height
        color: "#fff"
        radius: mp(3)

        state: "closed"

        states: [
            State {
                name: "closed"
                PropertyChanges {
                    target: topRect
                    yOffset: 0
                }
            },
            State {
                name: "opened"
                PropertyChanges {
                    target: topRect
                    yOffset: topRect.height
                }
            }
        ]

        transitions: [
            Transition {
                from: "*"
                to: "*"

                NumberAnimation {
                    target: topRect
                    property: "yOffset"
                    duration: topRect.dDuration
                    easing.type: Easing.Linear
                }
            }
        ]

        MouseArea {
            anchors.fill: parent
        }

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.radius
            color: parent.color
        }

        Item {
            id: widgetContent
            anchors.left: parent.left
            anchors.right: parent.right
            x: 0
            height: childrenRect.height + mp(4) * 2

            FindPlaceEdit {
                id: findPlaceEdit
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: mp(4)
                width: parent.width - mp(4) * 2
                radius: mp(3)
                textSize: mp(3)
            }

            Text {
                id: layersTitle
                anchors.top: findPlaceEdit.bottom
                anchors.topMargin: mp(4)
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Слои"
                color: "#000"
                font.pixelSize: mp(3)
                font.family: "Montserrat"
            }

            Rectangle {
                id: line1
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: layersTitle.bottom
                anchors.topMargin: mp(4)
                width: parent.width - mp(4) * 2
                height: 1
                color: "#ccc"
            }

            Item {
                id: layersRow
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: line1.bottom
                anchors.topMargin: mp(2)
                width: parent.width - mp(4) * 2
                height: findPlaceEdit.height * 1.2

                CheckButton {
                    id: tracks_layer_button;
                    x: parent.width / 3 * 0
                    y: 0
                    height: parent.height
                    width: parent.width / 3
                    imgSource: "qrc:/textures/tracks_layer_off.svg"
                    imgAltSource: "qrc:/textures/tracks_layer_on.svg"

                    onChecked: {
                        sessionData.setTracksVisible(true);
                    }

                    onUnchecked: {
                        sessionData.setTracksVisible(false);
                    }
                }

                CheckButton {
                    id: markers_layer_button;
                    x: parent.width / 3 * 1
                    y: 0
                    height: parent.height
                    width: parent.width / 3
                    imgSource: "qrc:/textures/markers_layer_off.svg"
                    imgAltSource: "qrc:/textures/markers_layer_on.svg"
                }

                CheckButton {
                    id: search_layer_button;
                    x: parent.width / 3 * 2
                    y: 0
                    height: parent.height
                    width: parent.width / 3
                    imgSource: "qrc:/textures/search_areas_layer_off.svg"
                    imgAltSource: "qrc:/textures/search_areas_layer_on.svg"
                }
            }
        }

        Item {
            property int lastPosY
            property real kinetic
            id: slider
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            height: mp(4)
            width: parent.width

            Rectangle {
                anchors.centerIn: parent
                height: parent.height / 3
                width: height * 4
                radius: height / 2
                color: "#ccc"
            }
            MouseArea {
                anchors.fill: parent

                onPressed: {
                    slider.lastPosY = mapToItem(top_surface, 0, mouseY, 0, 0).y;
                }

                onMouseYChanged: {
                    var newYPosition = mapToItem(top_surface, 0, mouseY, 0, 0).y;
                    if (newYPosition - slider.lastPosY != 0)
                        slider.kinetic = newYPosition - slider.lastPosY;
                    topRect.yOffset += newYPosition - slider.lastPosY;
                    slider.lastPosY = newYPosition;

                    if (topRect.yOffset < 0) topRect.yOffset = 0;
                    if (topRect.yOffset > topRect.height) topRect.yOffset = topRect.height;
                }

                onReleased: {
                    if (slider.kinetic > 0) {
                        topRect.dDuration = (topRect.height - topRect.yOffset) / topRect.height * topRect.fDuration;
                        topRect.state = "closed";
                        topRect.state = "opened";
                    }
                    else if (slider.kinetic < 0) {
                        topRect.dDuration = topRect.yOffset / topRect.height * topRect.fDuration;
                        topRect.state = "opened";
                        topRect.state = "closed";
                    }
                }
            }
        }
    }
}
