#ifndef APPCORE_H
#define APPCORE_H

#include <QObject>
#include <QVector>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QTimer>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QGeoLocation>
#include <QGeoPositionInfoSource>
#include <QGeoPositionInfo>

class TrackPoint {
public:
    QGeoCoordinate coord;
    QDateTime dt;

    TrackPoint() {}
    TrackPoint(QGeoCoordinate coord, QDateTime dt) {this->coord = coord; this->dt = dt;}
};



class Track {
public:
    int hunter_id;
    QString color;
    QVector<TrackPoint> track_points;

    QString getModel();
};



class ChatMessage {
public:
    int sender_id;
    QString sender_name;
    QString message_text;
    QDateTime sending_time;

    QString getModel(int hunter_id);
    void setTime(int year, int month, int day, int hour, int minute, int second);
};


class InitSettings {
private:
    QString DATA_FOLDER;

public:
    InitSettings();
    void setDataFolder(const QString &data_folder) {DATA_FOLDER = data_folder;}
    void loadSettings(const QString &filename);
    void saveSettings(const QString &filename);
    void saveSettings() {this->saveSettings(DATA_FOLDER);}
    int chat_cache_size;
    int check_messages_interval;
    int load_messages_count;
    int send_messages_interval;
    int position_update_interval;
    int send_points_interval;
    int get_points_interval;
};



class RequestStatus {
public:
    RequestStatus() {changing_name = false; checking_last_message = false; checking_new_messages = false; getting_messages = false; sending_message = false; sending_points = false; getting_points = false;}
    bool changing_name;
    bool checking_last_message;
    bool checking_new_messages;
    bool getting_messages;
    bool sending_message;
    bool sending_points;
    bool getting_points;

    bool getting_messages_reverse;
};


class AppCore;


class SessionData : public QObject {
    Q_OBJECT
public:
    explicit SessionData(QObject *parent = nullptr);
    AppCore *parent;

    RequestStatus request_status;
    QString address;

    // main data
    QString token;
    int hunter_id;
    QString name;

    // chat data
    int first_message_id, last_message_id, new_messages;
    QVector<ChatMessage> messages;
    QVector<QString> sending_messages;

    // geodata
    // tracks
    bool is_update_tracks;
    QGeoPositionInfoSource *geo_source;
    QVector<TrackPoint> sending_points;
    QVector<Track> tracks;

    QTimer *check_last_message_timer;
    QTimer *check_messages_timer;
    QTimer *send_messages_timer;
    QTimer *send_points_timer;
    QTimer *get_points_timer;

    QString getTrackColor(int hunter_id);

private:
    // chat
    bool loadChatCache();

public slots:
    void initSessionInterface();

    // functions
    void changeNameAction(QString new_name);
    void onChangeNameAction(QNetworkReply *reply);

    // chat
    void getNextMessages();
    void getPreviousMessages();
    void addMessageToStack(QString text);
    void sendNextMessage();

    void checkLastMessageAction();
    void onCheckLastMessageAction(QNetworkReply *reply);
    void checkNewMessagesAction();
    void onCheckNewMessagesAction(QNetworkReply *reply);
    void getMessagesAction(bool reverse);
    void onGetMessagesAction(QNetworkReply *reply);
    void sendMessageAction(QString text);
    void onSendMessageAction(QNetworkReply *reply);

    // tracks описать функции, добавить кеширование точек и параметр в файл инициализации, отвечающий за частоту получения геопозиции.
    // Добавить зависимость от настройки включения/выключения трекинга
    //interface
    void setTracksVisible(bool is_visible);
    //logic
    void initGeoSource();
    void setGeoSourceState(bool state);
    void setUpdateInterval(int msecs);
    void positionUpdated(QGeoPositionInfo geoInfo);
    void addPointToStack(TrackPoint point);
    void sendNextPoints();

    void sendPointsAction(Track track);
    void onSendPointsAction(QNetworkReply *reply);
    //void addFakePoint();
    void getPointsAction();
    void onGetPointsAction(QNetworkReply *reply);

signals:
    // system
    void showMessage(QString stitle, QString stext);

    // properties changed
    void updatedToken(QString token);
    void updatedHunterId(QString hunter_id);
    void updatedName(QString name);

    // chat
    void updateLastMessageId(int message_id);
    void updateFirstMessageId(int message_id);
    void prependMessage(QString element);
    void appendMessage(QString element);

    // tracks
    void setTracksVisibility(bool is_visible);
    void clearMap();
    void setTrack(QString element);
};



class AppCore : public QObject {
    Q_OBJECT
public:
    explicit AppCore(QObject *parent = nullptr);
    void setEngine(QQmlApplicationEngine *engine) {this->engine = engine;}
    bool loadOperation();
    void saveOperation();
    void deleteOperation();

    void checkCache();
    void setCacheVersion();
    void clearCache(bool all = false);

    InitSettings init_settings;

private:
    QString DATA_FOLDER;
    const char *CACHE_VERSION_FILE = "cacheversion.json";
    int cache_version = 3;
    const char *OPERATION_SETTINGS_FILE = "operationsettings.json";
    const char *APP_INI_FILE = "appini.json";
    QString address;
    QQmlApplicationEngine *engine;

    //data
    bool connecting;
    bool is_authorized;
    SessionData *session_data;

    // buff data
    QString token;
    int hunter_id;
    QString name;

signals:
    // system
    void showMessage(QString stitle, QString stext);

    // signals
    void loginResult(int code); // 0 - ок, 1 - токен не найден, 2 - ошибка подключения
    void logout();

public slots:
    // connect
    void initApp();
    void login(QString token, QString name);
    void connectAction();
    void onConnectAction(QNetworkReply *reply);
    void startSession();
    void endSession();
};

#endif // APPCORE_H
