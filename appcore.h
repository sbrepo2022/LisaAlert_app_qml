#ifndef APPCORE_H
#define APPCORE_H

#include <QObject>
#include <QVector>
#include <QNetworkAccessManager>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QStandardPaths>

class TrackPoint {
public:
    double x, y;
    int year, month, day, hour, minute;

    TrackPoint() {}
    TrackPoint(double x, double y, int year, int month, int day, int hour, int minute)
    {this->x = x; this->y = y; this->year = year; this->month = month; this->day = day; this->hour = hour; this->minute = minute;}
};

class Track {
public:
    int hunter_id;
    QString name;
    QVector<TrackPoint> track_points;
};

class AppCore : public QObject
{
    Q_OBJECT
public:
    explicit AppCore(QObject *parent = nullptr);

private:
    const char *SETTINGS_FILE = "operationsettings.json";

    //data
    bool is_authorized;
    QString token;
    void setToken(QString token) {this->token = token; emit tokenChanged(token);}
    int hunter_id;
    void setHunterId(int hunter_id) {this->hunter_id = hunter_id; emit hunterIdChanged(hunter_id);}
    QString name;
    void setName(QString name) {this->name = name; emit nameChanged(name);}

    bool loadOperation();
    void saveOperation();
    void deleteOperation();

signals:
    // properties changed
    void tokenChanged(QString token);
    void hunterIdChanged(int hunter_id);
    void nameChanged(QString name);

    // signals
    void loginResult(int code); // 0 - ок, 1 - токен не найден, 2 - ошибка подключения
    void logout();

public slots:
    void initApp();
    void login(QString token, QString name);
    void connectAction();
    void onConnectAction(QNetworkReply *result);
    void startSession();
    void endSession();
};

#endif // APPCORE_H
