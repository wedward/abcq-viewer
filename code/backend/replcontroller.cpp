#include "replcontroller.h"
#include <QDebug>
// #include <QDir>
#include <QCoreApplication>


ReplController::ReplController(QObject *parent)
    : QObject(parent)
{}

void ReplController::startRepl()
{
    if (replProcess) {
        qWarning() << "REPL already running.";
        return;
    }

    replProcess = new QProcess(this);

    // Unbuffered output: add -u flag
    // QString program = "python.exe";
    // QStringList arguments;
    // arguments << "-u" << "repl2.py";

    QString program = "repl2.exe";
    QStringList arguments;
    arguments << "";

    // QString home = QDir::homePath();

    // Set working directory where python.exe and repl.py are
    // replProcess->setWorkingDirectory(QDir::homePath());

    QString appDir = QCoreApplication::applicationDirPath();
    replProcess->setWorkingDirectory(appDir);

    connect(replProcess, &QProcess::readyReadStandardOutput,
            this, &ReplController::handleReadyRead);

    connect(replProcess, &QProcess::readyReadStandardError,
            this, &ReplController::handleReadyReadError);

    connect(replProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &ReplController::handleFinished);

    qDebug() << "[BACKEND]: Starting Build123d";
    replProcess->start(program, arguments);

    if (!replProcess->waitForStarted()) {
        qWarning() << "Failed to start REPL process.";
        delete replProcess;
        replProcess = nullptr;
    }
}

void ReplController::sendCommand(const QString &command)
{
    if (replProcess && replProcess->state() == QProcess::Running) {
        QByteArray input = command.toUtf8() + "\n";
        replProcess->write(input);
    } else {
        qWarning() << "REPL not running.";
    }
}

void ReplController::handleReadyRead()
{
    QString output = QString::fromUtf8(replProcess->readAllStandardOutput());
    emit replOutput(output);
}

void ReplController::handleReadyReadError()
{
    QString error = QString::fromUtf8(replProcess->readAllStandardError());
    emit replError(error);
}

void ReplController::handleFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    qDebug() << "REPL finished with code:" << exitCode;
    emit replClosed();
    replProcess->deleteLater();
    replProcess = nullptr;
}
