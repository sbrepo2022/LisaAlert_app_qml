#include "appcore.h"

QString Track::getModel() {
    QString dict;
    dict += "{";
    dict += "\"hunterId\":";
    dict += QString::number(hunter_id);
    dict += ",";
    dict += "\"color\":\"";
    dict += color;
    dict += "\",";
    dict += "\"geoData\":[";
    int i = 0;
    foreach (const TrackPoint &point, track_points) {
        dict += "{";
        dict += "\"lat\":";
        dict += QString::number(point.coord.latitude());
        dict += ",";
        dict += "\"long\":";
        dict += QString::number(point.coord.longitude());
        dict += ",";
        dict += "\"sendingTime\":\"";
        dict += point.dt.toString(Qt::ISODate);
        dict += "\"}";
        if (i < track_points.count() - 1)
            dict += ",";
        i++;
    }
    dict += "]";
    dict += "}";
    return dict;
}

void ChatMessage::setTime(int year, int month, int day, int hour, int minute, int second) {
    sending_time.setDate(QDate(year, month, day));
    sending_time.setTime(QTime(hour, minute, second));
}

QString ChatMessage::getModel(int hunter_id) {
    QString dict;
    dict += "{";
    dict += "\"hadSeen\":false,";
    dict += "\"isMyMessage\":";
    sender_id == hunter_id ? dict += "true" : dict += "false";
    dict += ",";
    dict += "\"senderID\":";
    dict += QString::number(sender_id);
    dict += ",";
    dict += "\"senderName\":\"";
    dict += sender_name;
    dict += "\",";
    dict += "\"sendingTime\":\"";
    dict += sending_time.toString(Qt::ISODate);
    dict += "\",";
    dict += "\"messageText\":\"";
    dict += message_text;
    dict += "\"";
    dict += "}";
    return dict;
}

InitSettings::InitSettings() {
    chat_cache_size = 10485760;
    check_messages_interval = 3000;
    load_messages_count = 20;
    send_messages_interval = 3000;
    position_update_interval = 5000;
    send_points_interval = 3000;
    get_points_interval = 10000;
}

void InitSettings::loadSettings(const QString &filename) {
    QFile file(DATA_FOLDER + "/" + filename);
    QString data;
    QJsonDocument document;
    QJsonObject root_object;

    if (file.exists()) {
        file.open(QIODevice::ReadOnly);
        data = file.readAll();
        document = QJsonDocument::fromJson(data.toUtf8());
        if (document.isObject()) {
            root_object = document.object();
            if (root_object.contains("chat_cache_size"))
                this->chat_cache_size = root_object["chat_cache_size"].toInt();
            if (root_object.contains("check_messages_interval"))
                this->check_messages_interval = root_object["check_messages_interval"].toInt();
            if (root_object.contains("load_messages_count"))
                this->load_messages_count = root_object["load_messages_count"].toInt();
            if (root_object.contains("send_messages_interval"))
                this->send_messages_interval = root_object["send_messages_interval"].toInt();
            if (root_object.contains("position_update_interval"))
                this->position_update_interval = root_object["position_update_interval"].toInt();
            if (root_object.contains("send_points_interval"))
                this->send_points_interval = root_object["send_points_interval"].toInt();
            if (root_object.contains("get_points_interval"))
                this->get_points_interval = root_object["get_points_interval"].toInt();
        }
    }
    else {
        saveSettings(filename);
    }
}

void InitSettings::saveSettings(const QString &filename) {
    QFile file(DATA_FOLDER + "/" + filename);
    file.open(QIODevice::WriteOnly);
    file.write("{\"chat_cache_size\":");
    file.write(QString::number(this->chat_cache_size).toUtf8());
    file.write(", \"check_messages_interval\":");
    file.write(QString::number(this->check_messages_interval).toUtf8());
    file.write(", \"load_messages_count\":");
    file.write(QString::number(this->load_messages_count).toUtf8());
    file.write(", \"send_messages_interval\":");
    file.write(QString::number(this->send_messages_interval).toUtf8());
    file.write(", \"position_update_interval\":");
    file.write(QString::number(this->position_update_interval).toUtf8());
    file.write(", \"send_points_interval\":");
    file.write(QString::number(this->send_points_interval).toUtf8());
    file.write(", \"get_points_interval\":");
    file.write(QString::number(this->get_points_interval).toUtf8());
    file.write("}");
}

AppCore::AppCore(QObject *parent) : QObject(parent) {
    this->token = "";
    this->name = "";
    this->is_authorized = false;
    this->connecting = false;
    this->hunter_id = 0;
    this->address = "http://fork.pythonanywhere.com/api/v3.0";
    this->DATA_FOLDER = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    this->init_settings.setDataFolder(DATA_FOLDER);
}

bool AppCore::loadOperation() {
    qDebug() << DATA_FOLDER + "/" + OPERATION_SETTINGS_FILE;
    QFile file(DATA_FOLDER + "/" + OPERATION_SETTINGS_FILE);
    QString data;
    QJsonDocument document;
    QJsonObject root_object;

    if (file.exists()) {
        file.open(QIODevice::ReadOnly);
        data = file.readAll();
        document = QJsonDocument::fromJson(data.toUtf8());
        if (document.isObject()) {
            root_object = document.object();
            this->token = root_object["token"].toString();
            this->name = root_object["name"].toString();
            this->hunter_id = root_object["hunter_id"].toInt();
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
    QFile file(DATA_FOLDER + "/" + OPERATION_SETTINGS_FILE);
    file.open(QIODevice::WriteOnly);
    file.write("{\"token\":\"");
    file.write(session_data->token.toUtf8());
    file.write("\", \"name\":\"");
    file.write(session_data->name.toUtf8());
    file.write("\", \"hunter_id\":");
    file.write(QString::number(session_data->hunter_id).toUtf8());
    file.write("}");
}

void AppCore::deleteOperation() {
    QFile file(DATA_FOLDER + "/" + OPERATION_SETTINGS_FILE);
    if (file.exists()) file.remove();
}

void AppCore::checkCache() {
    QFile file(DATA_FOLDER + "/" + CACHE_VERSION_FILE);

    if (! file.exists()) {
        setCacheVersion();
        clearCache();
        return;
    }
    else {
        QString data;
        QJsonDocument document;
        QJsonObject root_object;
        file.open(QIODevice::ReadOnly);
        data = file.readAll();
        document = QJsonDocument::fromJson(data.toUtf8());
        if (document.isObject()) {
            root_object = document.object();
            if (root_object["version"].toInt() != cache_version) clearCache();
            else return;
        }
        else {
            setCacheVersion();
            clearCache();
            return;
        }
    }
}

void AppCore::setCacheVersion() {
    QFile file(DATA_FOLDER + "/" + CACHE_VERSION_FILE);
    file.open(QIODevice::WriteOnly);
    file.write("{\"version\":");
    file.write(QString::number(cache_version).toUtf8());
    file.write("}");
}

void AppCore::clearCache(bool all) {
    QFile file;
    QDir dir(DATA_FOLDER);
    if (all) {
        dir.removeRecursively();
    }
    else {
        file.setFileName(DATA_FOLDER + "/" + APP_INI_FILE);
        if (file.exists()) file.remove();
    }
}

void AppCore::initApp() {
    checkCache();
    init_settings.loadSettings(APP_INI_FILE);
    if (loadOperation()) {
        // check operation existance
        startSession();
    }
}

void AppCore::login(QString token, QString name) {
    this->token = token;
    this->name = name;
    connectAction();
}

void AppCore::connectAction() {
    if (! this->connecting) {
        this->connecting = true;

        QString send_data;
        send_data += "{\"token\":\"";
        send_data += this->token;
        send_data += "\", \"name\":\"";
        send_data += this->name;
        send_data += "\"}";

        QNetworkAccessManager *http_manager = new QNetworkAccessManager();
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(onConnectAction(QNetworkReply*)));
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), http_manager, SLOT(deleteLater()));
        QString url = this->address + "/hunter";
        QNetworkRequest request = QNetworkRequest(QUrl(url));
        request.setRawHeader(QByteArray("Content-Type"), QByteArray("application/json"));
        http_manager->post(request, send_data.toUtf8());
    }
}

void AppCore::onConnectAction(QNetworkReply *reply) {
    this->connecting = false;

    int status_code;
    QString result;
    if(reply->error()){
        showMessage("Ошибка подключения", "Код ошибки: " + QString::number(reply->error()));
    }
    else {
        status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

        QJsonDocument document;
        QJsonObject root;
        result = reply->readAll();
        document = QJsonDocument::fromJson(result.toUtf8());
        switch (status_code) {
            case 201:
                if (document.isObject()) {
                    root = document.object();
                    this->hunter_id = root["data"].toObject()["hunter_id"].toInt();
                    startSession();
                    qDebug() << result;
                }
                break;

            case 400:
                showMessage("Ошибка запроса", "Status code: 400\nНекорректные данные.");
                break;

            case 404:
                showMessage("Ошибка запроса", "Status code: 404\nНеверный токен.");
                break;

            case 500:
                showMessage("Ошибка запроса", "Status code: 500\nОшибка сервера.");
                break;

            default:
                showMessage("Неизвестная ошибка", "Unknown error");
        }
    }

    reply->deleteLater();
}

void AppCore::startSession() {
    session_data = new SessionData();
    session_data->parent = this;
    session_data->address = this->address;
    session_data->token = this->token;
    session_data->hunter_id = this->hunter_id;
    session_data->name = this->name;
    this->is_authorized = true;
    saveOperation();
    // load send messages cache <-----
    session_data->send_messages_timer->start(init_settings.send_messages_interval);
    // load send points cache <-----
    session_data->initGeoSource();
    session_data->send_points_timer->start(init_settings.send_points_interval);

    QQmlContext *context = engine->rootContext();
    context->setContextProperty("sessionData", session_data);
    emit loginResult(0);
}

void AppCore::endSession() {
    if (session_data != nullptr)
        delete session_data;
    this->is_authorized = false;
    deleteOperation();
    emit logout();
}

SessionData::SessionData(QObject *parent) : QObject(parent) {
    this->token = "";
    this->name = "";
    this->hunter_id = 0;

    this->first_message_id = -1;
    this->last_message_id = -1;
    this->new_messages = 0;
    this->is_update_tracks = false;

    check_last_message_timer = new QTimer();
    connect(check_last_message_timer, SIGNAL(timeout()), this, SLOT(checkLastMessageAction()));
    check_messages_timer = new QTimer();
    connect(check_messages_timer, SIGNAL(timeout()), this, SLOT(checkNewMessagesAction()));
    send_messages_timer = new QTimer();
    connect(send_messages_timer, SIGNAL(timeout()), this, SLOT(sendNextMessage()));
    send_points_timer = new QTimer();
    connect(send_points_timer, SIGNAL(timeout()), this, SLOT(sendNextPoints()));
    get_points_timer = new QTimer();
    connect(get_points_timer, SIGNAL(timeout()), this, SLOT(getPointsAction()));

    /*QTimer *fake_points_timer = new QTimer(this);
    connect(fake_points_timer, SIGNAL(timeout()), this, SLOT(addFakePoint()));
    fake_points_timer->start(5000);*/
}

QString SessionData::getTrackColor(int hunter_id) {
    int choose = hunter_id % 6;
    switch (choose) {
        case 0:
            return "#aaff0000";

        case 1:
            return "#aa00ff00";

        case 2:
            return "#aa0000ff";

        case 3:
            return "#aaffff00";

        case 4:
            return "#aaff00ff";

        case 5:
            return "#aa00ffff";
    }
    return "#aa000000";
}

bool SessionData::loadChatCache() {
    return false;
}

void SessionData::initSessionInterface() {
    emit updatedToken(token);
    emit updatedHunterId(QString::number(hunter_id));
    emit updatedName(name);

    if (loadChatCache()) {

    }
    else {
        checkLastMessageAction();
    }

    get_points_timer->start(parent->init_settings.get_points_interval);
    getPointsAction();
}

// functions

void SessionData::changeNameAction(QString new_name) {
    if (! request_status.changing_name) {
        request_status.changing_name = true;
        this->name = new_name;

        QString send_data;
        send_data += "{\"token\":\"";
        send_data += token;
        send_data += "\", \"hunter_id\":";
        send_data += QString::number(hunter_id);
        send_data += ", \"name\":\"";
        send_data += new_name;
        send_data += "\"}";

        QNetworkAccessManager *http_manager = new QNetworkAccessManager();
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(onChangeNameAction(QNetworkReply*)));
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), http_manager, SLOT(deleteLater()));
        QString url = this->address + "/hunter";
        QNetworkRequest request = QNetworkRequest(QUrl(url));
        request.setRawHeader(QByteArray("Content-Type"), QByteArray("application/json"));
        http_manager->put(request, send_data.toUtf8());
    }
}

void SessionData::onChangeNameAction(QNetworkReply *reply) {
        request_status.changing_name = false;

        int status_code;
        QString result;
        if(reply->error()){

        }
        else {
            status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

            QJsonDocument document;
            QJsonObject root;
            result = reply->readAll();
            document = QJsonDocument::fromJson(result.toUtf8());
            switch (status_code) {
                case 204:
                    updatedName(name);
                    parent->saveOperation();
                    break;

                case 400:

                    break;

                case 403:

                    break;

                case 404:

                    break;

                case 500:

                    break;
            }
        }

    reply->deleteLater();
}

// chat
void SessionData::getNextMessages() {
    if (last_message_id != -1) {
        if (new_messages > 0) {
            qDebug() << "request next: " << last_message_id;
            getMessagesAction(false);
        }
    }
}

void SessionData::getPreviousMessages() {
    if (first_message_id != -1) {
        if (first_message_id > 1) {
            qDebug() << "request previous: " << first_message_id;
            getMessagesAction(true);
        }
    }
}

void SessionData::addMessageToStack(QString text) {
    sending_messages.append(text);
    sendNextMessage();
}

void SessionData::sendNextMessage() {
    if (sending_messages.count() > 0) {
        sendMessageAction(sending_messages[0]);
    }
}

void SessionData::checkLastMessageAction() {
    if (! request_status.checking_last_message) {
        request_status.checking_last_message = true;

        QNetworkAccessManager *http_manager = new QNetworkAccessManager();
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(onCheckLastMessageAction(QNetworkReply*)));
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), http_manager, SLOT(deleteLater()));
        QString url = this->address + "/chat?token=" + token;
        QNetworkRequest request = QNetworkRequest(QUrl(url));
        http_manager->head(request);
    }
}

void SessionData::onCheckLastMessageAction(QNetworkReply *reply) {
        request_status.checking_last_message = false;

        if (! check_last_message_timer->isActive()) {
            check_last_message_timer->start(parent->init_settings.check_messages_interval);
        }

        int status_code;
        if(reply->error()){

        }
        else {
            status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

            switch (status_code) {
                case 200:
                    if (reply->hasRawHeader("last-message-id")) {
                        last_message_id = reply->rawHeader("last-message-id").toInt();
                        first_message_id = last_message_id + 1;
                        check_last_message_timer->stop();
                        check_messages_timer->start(parent->init_settings.check_messages_interval);
                    }
                    break;

                case 500:

                    break;
            }
        }

    reply->deleteLater();
}

void SessionData::checkNewMessagesAction() {
    if (! request_status.checking_new_messages) {
        request_status.checking_new_messages = true;

        QNetworkAccessManager *http_manager = new QNetworkAccessManager();
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(onCheckNewMessagesAction(QNetworkReply*)));
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), http_manager, SLOT(deleteLater()));
        QString url = this->address + "/chat?token=" + token + "&last_message_id=" + QString::number(last_message_id);
        QNetworkRequest request = QNetworkRequest(QUrl(url));
        http_manager->head(request);
    }
}

void SessionData::onCheckNewMessagesAction(QNetworkReply *reply) {
        request_status.checking_new_messages = false;

        int status_code;
        if(reply->error()) {

        }
        else {
            status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

            switch (status_code) {
                case 200:
                    if (reply->hasRawHeader("last-message-id")) {
                        new_messages = reply->rawHeader("last-message-id").toInt() - last_message_id;
                    }
                    break;

                case 500:

                    break;
            }
        }

    reply->deleteLater();
}

void SessionData::getMessagesAction(bool reverse) {
    if (! request_status.getting_messages) {
        request_status.getting_messages = true;
        request_status.getting_messages_reverse = reverse;
        int start_id;
        reverse ? start_id = first_message_id - 1 : start_id = last_message_id + 1;
        QString s_reverse;
        reverse ? s_reverse = "true" : s_reverse = "false";

        QNetworkAccessManager *http_manager = new QNetworkAccessManager();
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(onGetMessagesAction(QNetworkReply*)));
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), http_manager, SLOT(deleteLater()));
        QString url = this->address + "/chat?token=" + token + "&start=" + QString::number(start_id) + "&count=" + QString::number(parent->init_settings.load_messages_count) + "&reverse=" + s_reverse;
        qDebug() << url;
        QNetworkRequest request = QNetworkRequest(QUrl(url));
        http_manager->get(request);
    }
}

void SessionData::onGetMessagesAction(QNetworkReply *reply) {
        request_status.getting_messages = false;

        int status_code;
        QString result;
        if(reply->error()){

        }
        else {
            status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

            QJsonDocument document;
            QJsonObject root;
            QJsonArray messagesArr;
            QJsonObject messageObj;
            QJsonArray tArr;
            ChatMessage message;
            result = reply->readAll();
            document = QJsonDocument::fromJson(result.toUtf8());
            switch (status_code) {
                case 200:
                    if (document.isObject()) {
                        root = document.object();
                        messagesArr = root["data"].toObject()["messages"].toArray();
                        foreach (const QJsonValue &msgVal, messagesArr) {
                            messageObj = msgVal.toObject();
                            tArr = messageObj["timestamp"].toArray();
                            message.setTime(tArr[0].toInt(), tArr[1].toInt(), tArr[2].toInt(), tArr[3].toInt(), tArr[4].toInt(), 0);
                            message.sender_id = messageObj["hunter_id"].toInt();
                            message.sender_name = messageObj["name"].toString();
                            message.message_text = messageObj["text"].toString();
                            if (! request_status.getting_messages_reverse) {
                                last_message_id = messageObj["message_id"].toInt();
                                new_messages--;
                                messages.prepend(message);
                                emit prependMessage(message.getModel(hunter_id));
                            }
                            else {
                                first_message_id = messageObj["message_id"].toInt();
                                messages.append(message);
                                emit appendMessage(message.getModel(hunter_id));
                            }
                        }
                    }
                    break;

                case 400:

                    break;

                case 404:

                    break;

                case 500:

                    break;
            }
        }

    reply->deleteLater();
}

void SessionData::sendMessageAction(QString text) {
    qDebug() << "sending: " << sending_messages[0];
    if (! request_status.sending_message) {
        request_status.sending_message = true;

        QString send_data;
        send_data += "{\"token\":\"";
        send_data += token;
        send_data += "\", \"hunter_id\":";
        send_data += QString::number(hunter_id);
        send_data += ", \"text\":\"";
        send_data += text;
        send_data += "\"}";

        QNetworkAccessManager *http_manager = new QNetworkAccessManager();
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(onSendMessageAction(QNetworkReply*)));
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), http_manager, SLOT(deleteLater()));
        QString url = this->address + "/chat";
        QNetworkRequest request = QNetworkRequest(QUrl(url));
        request.setRawHeader(QByteArray("Content-Type"), QByteArray("application/json"));
        http_manager->post(request, send_data.toUtf8());
        qDebug() << "sending: " << sending_messages[0];
    }
}

void SessionData::onSendMessageAction(QNetworkReply *reply) {
        request_status.sending_message = false;
        qDebug() << "sended: " << sending_messages[0];

        int status_code;
        QString result;
        if(reply->error()){

        }
        else {
            status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

            QJsonDocument document;
            QJsonObject root;
            result = reply->readAll();
            document = QJsonDocument::fromJson(result.toUtf8());
            switch (status_code) {
                case 204:
                    sending_messages.remove(0);
                    sendNextMessage();
                    getMessagesAction(false);
                    break;

                case 400:

                    break;

                case 403:

                    break;

                case 404:

                    break;

                case 500:

                    break;
            }
        }

    reply->deleteLater();
}

void SessionData::setTracksVisible(bool is_visible) {
    setTracksVisibility(is_visible);
}

void SessionData::initGeoSource() {
    geo_source = QGeoPositionInfoSource::createDefaultSource(this);
    if (geo_source) {
        connect(geo_source, SIGNAL(positionUpdated(QGeoPositionInfo)), this, SLOT(positionUpdated(QGeoPositionInfo)));
        geo_source->setUpdateInterval(parent->init_settings.position_update_interval);
    }
}

void SessionData::setGeoSourceState(bool state) {
    if (geo_source) {
        if (state) {
            geo_source->startUpdates();
        }
        else {
            geo_source->stopUpdates();
        }
        is_update_tracks = state;
    }
}

void SessionData::setUpdateInterval(int msecs) {
    if (geo_source) {
        geo_source->setUpdateInterval(msecs);
    }
    parent->init_settings.position_update_interval = msecs;
    parent->init_settings.saveSettings();
}

void SessionData::positionUpdated(QGeoPositionInfo geoInfo) {
    if (is_update_tracks) {
        TrackPoint t_point;
        t_point.coord = geoInfo.coordinate();
        t_point.dt = QDateTime::currentDateTime();
        addPointToStack(t_point);
    }
}

void SessionData::addPointToStack(TrackPoint point) {
    sending_points.append(point);
    sendNextPoints();
}

void SessionData::sendNextPoints() {
    if (sending_points.count() > 0) {
        Track track;
        track.track_points = sending_points;
        sendPointsAction(track);
    }
}

void SessionData::sendPointsAction(Track track) {
    if (! request_status.sending_points) {
        request_status.sending_points = true;

        QString send_data;
        send_data += "{\"token\":\"";
        send_data += token;
        send_data += "\", \"hunter_id\":";
        send_data += QString::number(hunter_id);
        send_data += ", \"geo\":[";
        for (int i = 0; i < track.track_points.count(); i++) {
            send_data += "{\"lat\":";
            send_data += QString::number(track.track_points[i].coord.latitude());
            send_data += ", \"long\":";
            send_data += QString::number(track.track_points[i].coord.longitude());
            send_data += ", \"timestamp\":[";
            send_data += QString::number(track.track_points[i].dt.date().year());
            send_data += ",";
            send_data += QString::number(track.track_points[i].dt.date().month());
            send_data += ",";
            send_data += QString::number(track.track_points[i].dt.date().day());
            send_data += ",";
            send_data += QString::number(track.track_points[i].dt.time().hour());
            send_data += ",";
            send_data += QString::number(track.track_points[i].dt.time().minute());
            send_data += "]";
            send_data += "}";
            if (i < track.track_points.count() - 1) send_data += ",";
        }
        send_data += "]";
        send_data += "}";

        QNetworkAccessManager *http_manager = new QNetworkAccessManager();
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(onSendPointsAction(QNetworkReply*)));
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), http_manager, SLOT(deleteLater()));
        QString url = this->address + "/track";
        QNetworkRequest request = QNetworkRequest(QUrl(url));
        request.setRawHeader(QByteArray("Content-Type"), QByteArray("application/json"));
        http_manager->post(request, send_data.toUtf8());
    }
}

void SessionData::onSendPointsAction(QNetworkReply *reply) {
        int point_num = 0;
        request_status.sending_points = false;

        int status_code;
        QString result;
        if(reply->error()){

        }
        else {
            status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

            QJsonDocument document;
            QJsonObject root;
            result = reply->readAll();
            document = QJsonDocument::fromJson(result.toUtf8());
            switch (status_code) {
                case 201:
                    if (document.isObject()) {
                        root = document.object();
                        point_num = root["data"].toObject()["created"].toInt();
                    }
                    sending_points.remove(0, point_num);
                    sendNextPoints();
                    //parent->showMessage("Геолокация", "Точек отправлено: " + QString::number(point_num));
                    break;

                case 400:

                    break;

                case 404:

                    break;

                case 500:

                    break;
            }
        }

    reply->deleteLater();
}

/*
void SessionData::addFakePoint() {
    TrackPoint t_point;
    t_point.coord.setLatitude(1.0);
    t_point.coord.setLongitude(1.0);
    t_point.dt = QDateTime::currentDateTime();
    addPointToStack(t_point);
}*/

void SessionData::getPointsAction() {
    if (! request_status.getting_points) {
        request_status.getting_points = true;

        QNetworkAccessManager *http_manager = new QNetworkAccessManager();
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(onGetPointsAction(QNetworkReply*)));
        connect(http_manager, SIGNAL(finished(QNetworkReply*)), http_manager, SLOT(deleteLater()));
        QString url = this->address + "/track?token=" + token;
        qDebug() << url;
        QNetworkRequest request = QNetworkRequest(QUrl(url));
        http_manager->get(request);
    }
}

void SessionData::onGetPointsAction(QNetworkReply *reply) {
        request_status.getting_points = false;
        int status_code;
        QString result;
        if(reply->error()){

        }
        else {
            status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

            QJsonDocument document;
            QJsonObject root;
            QJsonArray tracks_arr;
            Track *track;
            QJsonArray points_arr;
            TrackPoint *point;
            QJsonArray tArr;
            result = reply->readAll();
            document = QJsonDocument::fromJson(result.toUtf8());
            switch (status_code) {
                case 200:
                    if (document.isObject()) {
                        tracks.clear();
                        clearMap();
                        root = document.object();
                        tracks_arr = root["data"].toObject()["tracks"].toArray();
                        foreach (const QJsonValue &track_val, tracks_arr) {
                            track = new Track();
                            track->hunter_id = track_val.toObject()["hunter_id"].toInt();
                            track->color = getTrackColor(track->hunter_id);
                            points_arr = track_val.toObject()["geo"].toArray();
                            foreach (const QJsonValue &point_val, points_arr) {
                                point = new TrackPoint();
                                point->coord.setLatitude(point_val.toObject()["lat"].toDouble());
                                point->coord.setLongitude(point_val.toObject()["long"].toDouble());
                                tArr = point_val.toObject()["timestamp"].toArray();
                                point->dt.setDate(QDate(tArr[0].toInt(), tArr[1].toInt(), tArr[2].toInt()));
                                point->dt.setTime(QTime(tArr[3].toInt(), tArr[4].toInt(), 0));
                                track->track_points.push_back(*point);
                                delete point;
                            }
                            tracks.push_back(*track);
                            setTrack(track->getModel());
                            delete track;
                        }
                    }
                    break;

                case 400:

                    break;

                case 404:

                    break;

                case 500:

                    break;
            }
        }

    reply->deleteLater();
}
