import QtQuick 2.11
import QtQuick.Window 2.11
import QtGraphicalEffects 1.12

Rectangle {
    id: top_surface
    color: "#f2f2f2"

    function mp(x) {
        return Screen.pixelDensity * x;
    }

    Image {
        id: background_img
        source: "qrc:/textures/background.svg"
        sourceSize: Qt.size(parent.width, parent.height)
        anchors.fill: parent
        smooth: true
    }

    Text {
        id: title
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: top_surface.height / 8 / 3
        text: "Rescue Map"
        color: "#fff"
        font.bold: true
        font.pixelSize: mp(4)
        font.family: "Montserrat"
    }

    FastShadow {
        id: interfaceSurfaceShadow
        anchors.fill: interface_surface
        radius: mp(8)
        verticalOffset: mp(2)
        color: "#555"
    }

    Rectangle {
        id: interface_surface
        property int margin: mp(4)
        property int spacing: mp(4)
        property int bRadius: mp(3)
        property int textSize: mp(3)

        anchors.verticalCenter: top_surface.verticalCenter
        anchors.left: top_surface.left
        anchors.right: top_surface.right
        anchors.leftMargin: margin
        anchors.rightMargin: margin
        height: childrenRect.height + margin * 2
        color: "#fff"

        Text {
            id: surfaceTitle
            anchors.top: parent.top
            anchors.topMargin: parent.spacing
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Авторизация"
            color: "#000"
            font.pixelSize: interface_surface.textSize
            font.family: "Montserrat"
        }

        Rectangle {
            id: line1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: surfaceTitle.bottom
            anchors.topMargin: parent.spacing
            width: parent.width - parent.margin * 2
            height: 1
            color: "#999"
        }

        TokenEditElement {
            id: tokenEdit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: line1.bottom
            anchors.topMargin: parent.spacing
            width: parent.width - parent.margin * 2
            radius: parent.bRadius
            textSize: interface_surface.textSize
        }

        NameEdit {
            id: nameEdit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: tokenEdit.bottom
            anchors.topMargin: parent.spacing
            width: parent.width - parent.margin * 2
            radius: parent.bRadius
            textSize: interface_surface.textSize
        }

        Rectangle {
            id: connectionButton
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: nameEdit.bottom
            anchors.topMargin: parent.spacing
            width: parent.width - parent.margin * 2
            height: connectionText.height + radius * 2
            radius: parent.bRadius
            color: "#111"
            Text {
                id: connectionText
                anchors.centerIn: parent
                font.pixelSize: interface_surface.textSize
                font.family: "Montserrat"
                color: "#fff"
                text: "Присоединиться"
            }
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    connectionButton.color = "#222";
                }
                onReleased: {
                    connectionButton.color = "#111";
                }
                onCanceled: {
                    connectionButton.color = "#111";
                }
                onClicked: {
                    appCore.login(tokenEdit.text + tokenEdit.preeditText, nameEdit.text + nameEdit.preeditText);
                }
            }
        }
    }
}
