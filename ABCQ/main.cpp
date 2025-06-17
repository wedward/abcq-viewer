// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QQmlContext>
#include <QIcon>

#include "filesystemmodel.h"
#include "renderwatcher.h"

// #include <QUrl>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    // qmlRegisterType<RenderWatcher>("CustomComponents", 1, 0, "RenderWatcher");
    qmlRegisterType<RenderWatcher>("RWatcher", 1, 0, "RenderWatcher");
    qmlRegisterType<FileSystemModel>("FModel", 1,0, "FileSystemModel");
    QGuiApplication::setOrganizationName("ABCQ");
    QGuiApplication::setApplicationName("ABCQ Viewer");
    QGuiApplication::setApplicationVersion("0.1.1");
    QGuiApplication::setWindowIcon(QIcon("abcq/icons/app_icon.svg"));

    QCommandLineParser parser;
    parser.setApplicationDescription("A Build123d and CadQuery Viewer");
    parser.addHelpOption();
    parser.addVersionOption();
    QCommandLineOption directoryOption(QStringList() << "d" << "directory",
                                       "Initial directory to display in the file browser.",
                                       "directory");
    parser.addOption(directoryOption);

    parser.addPositionalArgument("","Initial directory","[path]");
    parser.process(app);
    const auto args = parser.positionalArguments();
    QString initialDir = parser.value(directoryOption);



    QQmlApplicationEngine engine;

    // SET CONTEXT
    QString appRootPath = QCoreApplication::applicationDirPath().replace("\\", "/");
    QString backendStr = "cpp";
    engine.rootContext()->setContextProperty("appPath", appRootPath);
    engine.rootContext()->setContextProperty("backend",backendStr);



    engine.loadFromModule("ABCQ", "Main");
    if (engine.rootObjects().isEmpty())
        return -1;


    if (!initialDir.isEmpty())
    {
        auto *fileSystemModel = engine.singletonInstance<FileSystemModel*>(
            "ABCQ","FileSystemModel");
        fileSystemModel->setInitialDirectory(initialDir);
    }

    if (args.length() == 1) {
        QObject *rootObject = engine.rootObjects().constFirst();
        rootObject->setProperty("requestOpen", args[0]);
    }

    return QGuiApplication::exec(); // Start the event loop.
}
