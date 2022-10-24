import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.12

Item {
    property Item background
    property Item mask
    property Item swipeView
    id: top_surface
    clip: true

    function mp(x) {
        return Screen.pixelDensity * x;
    }

    Connections {
        target: sessionData

        onUpdatedName: {
            nameEdit.text = name;
        }
    }

    Rectangle {
        id: topRect
        anchors.fill: parent
        color: background.color

        Flickable {
            id: flickable
            anchors.fill: parent
            contentWidth: width
            contentHeight: contentItem.height + contentItem.y

            Item {
                id: contentItem
                anchors.left: parent.left
                anchors.right: parent.right
                y: topRect.height * 0.25
                height: childrenRect.height + mp(6)

                CheckButton {
                    id: trackingButton
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width > mp(20) ? mp(20) : parent.width
                    height: width
                    imgSource: "qrc:/textures/tracking_off.svg"
                    imgAltSource: "qrc:/textures/tracking_on.svg"
                    isChecked: false
                    onChecked: {
                        sessionData.setGeoSourceState(true);
                    }
                    onUnchecked: {
                        sessionData.setGeoSourceState(false);
                    }
                }

                FastShadow {
                    id: settingsSurfaceShadow
                    anchors.fill: settingsSurface
                    radius: mp(6)
                    verticalOffset: mp(1)
                    borderRadius: settingsSurface.radius
                    color: "#555"
                }

                Rectangle {
                    id: settingsSurface
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: trackingButton.bottom
                    anchors.topMargin: mp(6)
                    height: childrenRect.height + mp(4) * 2
                    color: "#fff"

                    Text {
                        id: widgetsTitle
                        anchors.top: parent.top
                        anchors.topMargin: mp(4)
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Виджеты"
                        color: "#000"
                        font.pixelSize: mp(3)
                        font.family: "Montserrat"
                    }

                    Rectangle {
                        id: line1
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.children[0].bottom
                        anchors.topMargin: mp(4)
                        width: parent.width - mp(4) * 2
                        height: 1
                        color: "#999"
                    }

                    CheckButton2 {
                        anchors.top: parent.children[1].bottom
                        anchors.left: parent.left
                        anchors.topMargin: mp(4)
                        anchors.leftMargin: mp(4)
                        height: mp(5)
                        text: "Компас"
                    }
                    CheckButton2 {
                        anchors.top: parent.children[2].bottom
                        anchors.left: parent.left
                        anchors.topMargin: mp(4)
                        anchors.leftMargin: mp(4)
                        height: mp(5)
                        text: "Альтитуда"
                    }
                    CheckButton2 {
                        anchors.top: parent.children[3].bottom
                        anchors.left: parent.left
                        anchors.topMargin: mp(4)
                        anchors.leftMargin: mp(4)
                        height: mp(5)
                        text: "Измерение движения"
                    }

                    Text {
                        id: sysSettingsTitle
                        anchors.top: parent.children[4].bottom
                        anchors.topMargin: mp(8)
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Параметры пользователя"
                        color: "#000"
                        font.pixelSize: mp(3)
                        font.family: "Montserrat"
                    }

                    Rectangle {
                        id: line2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.children[5].bottom
                        anchors.topMargin: mp(4)
                        width: parent.width - mp(4) * 2
                        height: 1
                        color: "#999"
                    }

                    ChangeText {
                        id: nameEdit
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.children[6].bottom
                        anchors.topMargin: mp(4)
                        width: parent.width - mp(4) * 2
                        radius: mp(3)
                        textSize: mp(3)
                        placeholderText: "Введите имя..."
                        onChangeName: {
                            sessionData.changeNameAction(nameEdit.text + nameEdit.preeditText);
                        }
                    }

                    Text {
                        id: dataSettingsTitle
                        anchors.top: parent.children[7].bottom
                        anchors.topMargin: mp(8)
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Данные приложения"
                        color: "#000"
                        font.pixelSize: mp(3)
                        font.family: "Montserrat"
                    }

                    Rectangle {
                        id: line3
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.children[8].bottom
                        anchors.topMargin: mp(4)
                        width: parent.width - mp(4) * 2
                        height: 1
                        color: "#999"
                    }

                    Rectangle {
                        id: clearMapCacheButton
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.children[9].bottom
                        anchors.topMargin: mp(4)
                        width: parent.width - mp(8) * 2
                        height: clearMapCacheText.height + mp(3) * 2
                        radius: mp(3)
                        color: "#0095dd"
                        Text {
                            id: clearMapCacheText
                            anchors.centerIn: parent
                            font.pixelSize: mp(3)
                            font.family: "Montserrat"
                            color: "#fff"
                            text: "Очистить кэш"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onPressed: {
                                clearMapCacheButton.color = "#0075bd";
                            }
                            onReleased: {
                                clearMapCacheButton.color = "#0095dd";
                            }
                            onCanceled: {
                                clearMapCacheButton.color = "#0095dd";
                            }
                            onClicked: {
                            }
                        }
                    }
                }

                FastShadow {
                    id: logoutButtonShadow
                    anchors.fill: logoutButton
                    radius: mp(6)
                    verticalOffset: mp(1)
                    borderRadius: logoutButton.radius
                    color: "#555"
                }

                Rectangle {
                    id: logoutButton
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: settingsSurface.bottom
                    anchors.topMargin: mp(6)
                    width: parent.width - mp(8) * 2
                    height: logoutText.height + mp(3) * 2
                    radius: mp(3)
                    color: "#111"
                    Text {
                        id: logoutText
                        anchors.centerIn: parent
                        font.pixelSize: mp(3)
                        font.family: "Montserrat"
                        color: "#fff"
                        text: "Завершить"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed: {
                            logoutButton.color = "#222";
                        }
                        onReleased: {
                            logoutButton.color = "#111";
                        }
                        onCanceled: {
                            logoutButton.color = "#111";
                        }
                        onClicked: {
                            appCore.endSession();
                        }
                    }
                }
            }
        }

        OpacityMask {
            anchors.fill: parent
            source: ShaderEffectSource {
                sourceItem: top_surface.background
                sourceRect: {
                    top_surface.swipeView.contentItem.contentX;
                    return topRect.mapToItem(top_surface.background, 0, 0, topRect.width, topRect.height);
                }
            }

            maskSource: ShaderEffectSource {
                sourceItem: top_surface.mask
                sourceRect: {
                    top_surface.swipeView.contentItem.contentX;
                    return topRect.mapToItem(top_surface.mask, 0, 0, topRect.width, topRect.height);
                }
            }
        }

        Text {
            id: title
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: top_surface.height / 8 / 3
            text: "Настройки"
            color: "#fff"
            font.bold: true
            font.pixelSize: mp(4)
            font.family: "Montserrat"
        }
    }
}
