// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick

pragma Singleton

QtObject {
    id: dark
    property color background: theme.background
    property color surface1: theme.surface1
    property color surface2: theme.surface2
    property color text: theme.text
    property color textFile: theme.textFile
    property color disabledText: theme.disabledText
    property color selection: theme.selection
    property color inactive: theme.inactive
    property color folder: theme.folder
    property color icon: theme.icon
    property color iconIndicator: theme.iconIndicator
    property color color1: theme.color1
    property color color2: theme.color2

}

