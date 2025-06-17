#include "renderwatcher.h"
#include <QTimer>
#include <QDebug>
#include <QUrl>
#include <QFileSystemWatcher>



RenderWatcher::RenderWatcher( QObject* parent )
    : QObject( parent ),
    _watcher(new QFileSystemWatcher(this)),
    _timer( new QTimer( this ) ),
    isListening(true)
{
    _timer->setInterval(50);
    _timer->setSingleShot(true);


    connect( _watcher, &QFileSystemWatcher::fileChanged, this, &RenderWatcher::reloadTriggered );
    connect( _timer, &QTimer::timeout, this, &RenderWatcher::reloadComplete );
}


QString RenderWatcher::watchPath() const
{
    const QStringList files = _watcher->files();
    return files.isEmpty() ? QString() : files.constFirst();
}
void RenderWatcher::setWatchPath(const QString& path )
{
    if (!_watcher->files().isEmpty()){
        clearWatchlist();
    }

    if (!path.isEmpty())
        _watcher->addPath(path);
    emit watchPathChanged();
    // emit listeningChanged();
}


int RenderWatcher::interval() const
{
    return _timer->interval();
}
void RenderWatcher::setInterval(int msec)
{
    _timer->setInterval(msec);
    emit intervalChanged();
}

bool RenderWatcher::listening() const
{
    return isListening;
}
void RenderWatcher::setListening(bool state)
{
    if (!state && isListening){
        pauseList =  _watcher->files();
        clearWatchlist();
    }

    else if (state && !pauseList.isEmpty()) {
        _watcher->addPaths(pauseList);
        pauseList.clear();
    }

    qDebug() << "watch" << _watcher->files() << "pause" << pauseList;

    isListening = !_watcher->files().isEmpty();
    emit listeningChanged();

}

bool RenderWatcher::counting() const
{
    return _timer->isActive();
}
void RenderWatcher::setCounting(bool state)
{
    if(state){
            _timer->start();
        }
    else {
        _timer->stop();
        }

        emit countingChanged();
}


void RenderWatcher::clearWatchlist()
{
    const QStringList files = _watcher->files();
    if(!files.isEmpty())
        _watcher->removePaths(files);
}


