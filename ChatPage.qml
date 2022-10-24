import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.12

Item {
    property Item background
    property Item mask
    property Item swipeView
    property int messagesNotSeen: 0 // дописать определение того, что сообщение было просмотрено
    id: top_surface
    clip: true

    function mp(x) {
        return Screen.pixelDensity * x;
    }

    Rectangle {
        property int textSize: mp(2.5)
        id: topRect
        anchors.fill: parent
        color: background.color

        ListModel {
            id: messagesModel
            /*ListElement {
                isMyMessage: true
                senderID: 1
                senderName: "Серей Борисов"
                sendingTime: "23:58"
                messageText: "Скоро будут настройки"
                hadSeen: false
            }
            ListElement {
                isMyMessage: true
                senderID: 1
                senderName: "Серей Борисов"
                sendingTime: "23:58"
                messageText: "Поддерживаю идею разработчика Александра"
                hadSeen: false
            }*/
        }

        ListView {
            id: msgListView
            property real lastY: 0
            property real kinetic: 0
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            //anchors.topMargin: parent.height * 0.21

            Timer {
                interval: 500
                running: true
                repeat: true
                onTriggered: {
                    if (msgListView.visibleArea.yPosition * msgListView.contentHeight < msgListView.height) {
                        sessionData.getPreviousMessages();
                    }

                    if (msgListView.contentHeight - (msgListView.visibleArea.yPosition + msgListView.visibleArea.heightRatio) * msgListView.contentHeight < msgListView.height) {
                        sessionData.getNextMessages();
                    }
                }
            }

            Connections {
                target: sessionData

                onPrependMessage: {
                    messagesModel.insert(0, JSON.parse(element));
                }

                onAppendMessage: {
                    messagesModel.append(JSON.parse(element));
                    top_surface.messagesNotSeen += 1;
                }

                onUpdatedName: {
                    for (var i = 0; i < messagesModel.count; i++) {
                        if (messagesModel.get(i).isMyMessage === true)
                            messagesModel.setProperty(i, "senderName", name);
                    }
                }
            }

            header: Rectangle {
                width: parent.width
                height: mp(2) + msgEditRect.height
                color: "#00000000"
            }

            footer: Rectangle {
                width: parent.width
                height: parent.parent.height * 0.2
                color: "#00000000"
            }

            addDisplaced: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 300
                }
            }

            verticalLayoutDirection: ListView.BottomToTop
            model: messagesModel
            delegate: Component {
                id: messageDelegateComponent

                Item {
                    property int heightMargin: mp(2) + mp(4)
                    id: topMsgItem
                    width: parent.width
                    height: childrenRect.height + heightMargin

                    Text {
                        id: nameText
                        anchors.top: parent.top
                        anchors.topMargin: mp(4)
                        anchors.left: parent.left
                        anchors.leftMargin: mp(4)
                        width: topMsgItem.width / 5 * 3
                        wrapMode: Text.Wrap
                        text: senderName
                        font.pixelSize: topRect.textSize
                        font.family: "Montserrat"
                        color: "#ccc"
                        Component.onCompleted: {
                            var dateTime1 = Date.parse(sendingTime);
                            var dateTime2 = Date.parse(messagesModel.get(index + 1).sendingTime);
                            if (index < messagesModel.count - 1)
                                if (messagesModel.get(index + 1).senderID === senderID  && dateTime1 - dateTime2 < 60000) {
                                    nameText.anchors.topMargin = 0;
                                    nameText.height = 0;
                                    nameText.opacity = 0.0;
                                    topMsgItem.heightMargin = mp(2);
                                }
                        }
                    }

                    Rectangle {
                        id: msgRect
                        anchors.top: nameText.bottom
                        anchors.topMargin: mp(2)
                        anchors.left: parent.left
                        anchors.leftMargin: mp(4)
                        width: msgText.paintedWidth + mp(4) * 2
                        height: msgText.paintedHeight + mp(4) * 2
                        color: isMyMessage ? "#ccf" : "#ddd"
                        radius: mp(4)
                        Text {
                            id: msgText
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: mp(4)
                            width: topMsgItem.width / 5 * 3
                            wrapMode: Text.Wrap
                            text: messageText
                            font.pixelSize: topRect.textSize
                            font.family: "Montserrat"
                            color: "#000"
                        }
                    }
                    Text {
                        id: timeText
                        anchors.top: msgRect.top
                        anchors.right: parent.right
                        anchors.topMargin: mp(4)
                        anchors.rightMargin: mp(4)
                        text: {
                            var curTime = new Date().getTime();
                            if (curTime - Date.parse(sendingTime) > 24 * 60 * 60 * 1000) {
                                return sendingTime.split('T')[0].split('-')[1] + "." + sendingTime.split('T')[0].split('-')[2];
                            }
                            else {
                                return sendingTime.split('T')[1].split(':')[0] + ":" + sendingTime.split('T')[1].split(':')[1];
                            }
                        }
                        font.pixelSize: topRect.textSize
                        font.family: "Montserrat"
                        color: "#ccc"
                    }
                }
            }

            Component.onCompleted: {
                lastY = contentY;
            }

            onHeightChanged: {
                msgEditRect.heightOffset = 0
            }

            onContentYChanged: {
                if (draggingVertically) {   // save moving direction
                    kinetic = lastY - contentY;
                }
                if (contentHeight > height)
                    if (lastY - contentY < 0 && kinetic < 0 || lastY - contentY > 0 && kinetic > 0 && (visibleArea.heightRatio + visibleArea.yPosition) < 1.0)
                        msgEditRect.heightOffset += lastY - contentY;
                if (msgEditRect.y > topRect.height) msgEditRect.heightOffset = msgEditRect.height;
                if (msgEditRect.y < topRect.height - msgEditRect.height) msgEditRect.heightOffset = 0;
                lastY = contentY;
            }
        }

        /*LinearGradient {
            id: gradient
            anchors.fill: parent
            gradient: Gradient {
                GradientStop {
                    position: 1.0
                    color: "#00f2f2f2"
                }
                GradientStop {
                    position: 0.31
                    color: "#00f2f2f2"
                }
                GradientStop {
                    position: 0.21
                    color: "#fff2f2f2"
                }
                GradientStop {
                    position: 0.0
                    color: "#fff2f2f2"
                }
            }
        }*/

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
            text: "Сообщения"
            color: "#fff"
            font.bold: true
            font.pixelSize: mp(4)
            font.family: "Montserrat"
        }

        FastShadow {
            id: msgEditShadow
            anchors.fill: msgEditRect
            radius: mp(3)
            color: "#aaa"
        }

        Rectangle {
            property real heightOffset: 0
            id: msgEditRect
            width: parent.width
            height: msgEditLine.height
            x: 0
            y: parent.height - height + heightOffset
            color: "#f8f8f8"
            TextField {
                id: msgEditLine
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: sendButton.left
                placeholderText: "Напишите сообщение..."
                font.pixelSize: mp(3)
                font.family: "Montserrat"
                color: "#000"
                background: Rectangle {
                    color: "#00000000"
                }
                padding: mp(4)
                selectByMouse: true

                onPreeditTextChanged: {
                    (text === "" && preeditText.length == 0) ? sendButton.yOffset = 0 : sendButton.yOffset = -sendButton.height;
                }

                onTextChanged: {
                    (text === "" && preeditText.length == 0) ? sendButton.yOffset = 0 : sendButton.yOffset = -sendButton.height;
                }
            }

            Rectangle {
                property int yOffset: 0
                id: sendButton
                anchors.right: parent.right
                height: parent.height
                width: height
                y: height + yOffset
                color: "#00000000"
                Behavior on yOffset {
                    NumberAnimation {easing.type: Easing.OutBack; duration: 300;}
                }

                Image {
                    anchors.centerIn: parent
                    height: (parent.height < parent.width ? parent.height : parent.width) * 0.6
                    width: height
                    source: "qrc:/textures/send.svg"
                    sourceSize: Qt.size(width, height)
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        /*messagesModel.insert(0, {"isMyMessage": true,
                                                 "senderID": 1,
                                                 "senderName": "Серей Борисов",
                                                 "sendingTime": Qt.formatDateTime(new Date(), "h:m"),
                                                 "messageText": msgEditLine.text});*/
                        sessionData.addMessageToStack(msgEditLine.text + msgEditLine.preeditText);
                        msgEditLine.text = " ";
                        msgEditLine.text = "";
                    }
                }
            }
        }
    }
}
