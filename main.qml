import QtQuick 2.11
import QtQuick.Window 2.2
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.12
import QtQuick.Dialogs 1.2

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 270
    height: 480
    title: qsTr("Rescue Map")

    MessageDialog {
        id: messageDialog
        title: "May I have your attention please"
        text: "It's so cool that you are using Qt Quick."
        visible: false
    }

    Connections {
        target: sessionData

        onShowMessage: {
            messageDialog.title = stitle;
            messageDialog.text = stext;
            messageDialog.visible = true;
        }
    }


    Connections {
        target: appCore

        onShowMessage: {
            messageDialog.title = stitle;
            messageDialog.text = stext;
            messageDialog.visible = true;
        }

        onLoginResult: {
            switch (code) {
                case 0:
                    mainStack.push(mainPageComponent);
                    break;
            }
        }

        onLogout: {
            mainStack.pop();
        }
    }

    StackView {
        id: mainStack
        anchors.fill: parent
        focus: true
        initialItem: loginPageComponent

        Component {
            id: loginPageComponent
            LoginPage {
                id: loginPage
            }
        }

        Component {
            id: mainPageComponent
            MainPage {
                id: mainPage
            }
        }
    }

    Component.onCompleted: {
        appCore.initApp();
    }
}
