// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#ifndef WATCHER_H
#define WATCHER_H

#include <QObject>
#include <QFileSystemWatcher>
#include <QTimer>
// #include <QXmlStreamEntityDeclaration>
#include <QQmlEngine>
#include <qabstractitemmodel.h>

class Watcher : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(FileWatcher)
    QML_SINGLETON
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)
public:
    QString filePath() const;
    explicit Watcher(QObject *parent = nullptr);

    // Functions invokable from QML
    // Q_INVOKABLE QString readFile(const QString &filePath);
    // Q_INVOKABLE int currentLineNumber(QQuickTextDocument *textDocument, int cursorPosition);


    // Member functions from here
    // QModelIndex rootIndex() const;
    void setFilePath(const QString &path);


signals:
    void filePathChanged();

private:
    QString m_filePath;
    void registerPath(const QString &path);
};

#endif
