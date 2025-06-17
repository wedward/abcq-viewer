// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include "watcher.h"
#include <QObject>
#include <QDebug>


Watcher::Watcher(QObject *parent)
    : QObject(parent),
    m_filePath("C:/Users/wehos/output.gltf")
{

}

QString Watcher::filePath() const
{
    return m_filePath;
}
void Watcher::setFilePath(const QString &path)
{

    registerPath(path);
    m_filePath = path;
    emit filePathChanged();

}

void Watcher::registerPath(const QString &path)
{
    qDebug() << "file changed: " << path;
}

