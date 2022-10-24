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

        onUpdatedToken: {
            infoModel.set(0, {"fieldValue":token});
        }

        onUpdatedHunterId: {
            infoModel.set(1, {"fieldValue":hunter_id});
        }

        onUpdatedName: {
            infoModel.set(2, {"fieldValue":name});
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
                y: height > topRect.height * 0.75 ? topRect.height * 0.25 : topRect.height * 0.25 + topRect.height * 0.75 / 2 - height / 2
                height: childrenRect.height + mp(6)

                ListModel {
                    id: infoModel
                    ListElement {
                        fieldTitle: "Токен:"
                        fieldValue: "token"
                    }
                    ListElement {
                        fieldTitle: "UID:"
                        fieldValue: "1"
                    }
                    ListElement {
                        fieldTitle: "Имя:"
                        fieldValue: "Сергей Борисов"
                    }
                }

                FastShadow {
                    id: infoListShadow
                    anchors.fill: infoList
                    radius: mp(6)
                    verticalOffset: mp(1)
                    color: "#555"
                }

                ListView {
                    id: infoList
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: contentHeight
                    interactive: false

                    model: infoModel
                    delegate: Component {
                        Rectangle {
                            color: index % 2 ? "#f2f2f2" : "#fff"
                            width: parent.width
                            height: childrenRect.height + mp(4) * 2
                            Text {
                                id: infoTitle
                                anchors.top: parent.top
                                anchors.topMargin: mp(4)
                                anchors.left: parent.left
                                anchors.right: parent.horizontalCenter
                                anchors.leftMargin: mp(4)
                                text: fieldTitle
                                color: "#000"
                                font.pixelSize: mp(3)
                                font.family: "Montserrat"
                                wrapMode: Text.Wrap
                            }
                            Text {
                                id: infoValue
                                anchors.top: parent.top
                                anchors.topMargin: mp(4)
                                anchors.right: parent.right
                                anchors.left: parent.horizontalCenter
                                anchors.rightMargin: mp(4)
                                text: fieldValue
                                horizontalAlignment: Text.AlignRight
                                color: "#000"
                                font.pixelSize: mp(3)
                                font.family: "Montserrat"
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }

                FastShadow {
                    id: appInfoShadow
                    anchors.fill: appInfo
                    radius: mp(6)
                    verticalOffset: mp(1)
                    color: "#555"
                }

                Rectangle {
                    id: appInfo
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: infoList.bottom
                    anchors.topMargin: mp(6)
                    height: childrenRect.height + mp(4) * 2
                    Text {
                        id: infoTitle
                        anchors.top: parent.top
                        anchors.topMargin: mp(4)
                        anchors.left: parent.left
                        anchors.right: parent.right
                        text: "Rescue Map v2.0 (alpha)"
                        horizontalAlignment: Text.AlignHCenter
                        color: "#000"
                        font.pixelSize: mp(3)
                        font.family: "Montserrat"
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
            text: "Информация"
            color: "#fff"
            font.bold: true
            font.pixelSize: mp(4)
            font.family: "Montserrat"
        }
    }
}
