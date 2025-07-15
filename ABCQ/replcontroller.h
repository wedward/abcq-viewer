#ifndef REPLCONTROLLER_H
#define REPLCONTROLLER_H

#pragma once

#include <QObject>
#include <QProcess>

class ReplController : public QObject
{
    Q_OBJECT
public:
    explicit ReplController(QObject *parent = nullptr);

    Q_INVOKABLE void startRepl();
    Q_INVOKABLE void sendCommand(const QString &command);

signals:
    void replOutput(const QString &output);
    void replError(const QString &error);
    void replClosed();

private:
    QProcess *replProcess = nullptr;

private slots:
    void handleReadyRead();
    void handleReadyReadError();
    void handleFinished(int exitCode, QProcess::ExitStatus exitStatus);
};

#endif // REPLCONTROLLER_H
