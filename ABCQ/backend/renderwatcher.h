#ifndef RENDERWATCHER_H
#define RENDERWATCHER_H

#include <QObject>
#include <QFileSystemWatcher>
#include <QTimer>



// class QTimer;
// class QFileSystemWatcher;

class RenderWatcher : public QObject
{
    Q_OBJECT
    Q_PROPERTY( QString watchPath READ watchPath WRITE setWatchPath NOTIFY watchPathChanged )
    Q_PROPERTY( int interval READ interval WRITE setInterval NOTIFY intervalChanged )
    Q_PROPERTY( bool listening READ listening WRITE setListening NOTIFY listeningChanged)
    Q_PROPERTY( bool counting READ counting WRITE setCounting NOTIFY countingChanged )

public:
    explicit RenderWatcher(QObject *parent = nullptr);

    QString watchPath() const;
    void setWatchPath(const QString &path);

    void setInterval( int msec);
    int interval() const;


    void setListening(bool state);
    bool listening() const;



    bool counting() const;
    void setCounting(const bool state);


// public slots:
    // void reload();
    // void startListening();
    // void stopListening();
    // void stop();

signals:
    void reloadTriggered();
    void reloadComplete();

    void intervalChanged();
    // void activeChanged();
    void watchPathChanged();
    void listeningChanged();
    void countingChanged();

private:
    void clearWatchlist();

    QTimer *_timer;
    QFileSystemWatcher *_watcher;

    QStringList pauseList;
    bool isListening;

signals:
};

#endif // RENDERWATCHER_H
