#include "appcore.h"

AppCore::AppCore(QObject *parent) : QObject(parent)
{
    this->token = "";
    this->name = "";
    this->is_authorized = false;
    this->hunter_id = 0;
}

bool AppCore::loadOperation() {
    qDebug() << QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/" + SETTINGS_FILE;
    QFile file(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/" + SETTINGS_FILE);
    QString data;
    QJsonDocument document;
    QJsonObject root_object;

    if (file.exists()) {
        file.open(QIODevice::ReadOnly);
        data = file.readAll();
        document = QJsonDocument::fromJson(data.toUtf8());
        if (document.isObject()) {
            root_object = document.object();
            setToken(root_object["token"].toString());
            setName(root_object["name"].toString());
            setHunterId(root_object["hunter_id"].toInt());
        }
        else {
            return false;
        }
    }
    else {
        return false;
    }
    return true;
}

void AppCore::saveOperation() {
    QFile file(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/" + SETTINGS_FILE);
    file.open(QIODevice::WriteOnly);
    file.write("{\"token\":\"");
    file.write(token.toUtf8());
    file.write("\", \"name\":\"");
    file.write(name.toUtf8());
    file.write("\", \"hunter_id\":");
    file.write(QString::number(hunter_id).toUtf8());
    file.write("}");
}

void AppCore::deleteOperation() {
    QFile file(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/" + SETTINGS_FILE);
    if (file.exists())
        file.remove();
}

void AppCore::initApp() {
    if (loadOperation()) {
        // check operation existance
        emit loginResult(0);
    }
}

void AppCore::login(QString token, QString name) {
    setToken(token);
    setName(name);
    // onConnectAction
    setHunterId(0);
    startSession();
    emit loginResult(0);
}

void AppCore::connectAction() {

}

void AppCore::onConnectAction(QNetworkReply *result) {

}

void AppCore::startSession() {
    this->is_authorized = true;
    saveOperation();
}

void AppCore::endSession() {
    this->is_authorized = false;
    deleteOperation();
    emit logout();
}
