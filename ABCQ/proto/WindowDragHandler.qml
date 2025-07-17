// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls.Basic
pragma ComponentBehavior: Bound
// Allows dragging the window when placed on an unused section of the UI.
DragHandler {

    required property ApplicationWindow dragWindow

    target: null
    onActiveChanged: {
        if (active) dragWindow.startSystemMove()
    }

}
