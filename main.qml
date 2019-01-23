import QtQuick 2.11
import QtQuick.Window 2.2
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.12

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 270
    height: 480
    title: qsTr("Lisa Alert")

    Connections {
        target: appCore

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
