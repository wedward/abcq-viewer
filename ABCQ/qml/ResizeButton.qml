// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick.Controls.Basic
import QtQuick
import "."
pragma ComponentBehavior: Bound

Button {
    // required property ApplicationWindow resizeWindow

    rightPadding: 0
    bottomPadding: 0
    leftPadding: 0
    topPadding: 0

    Behavior on opacity {
        OpacityAnimator {
            duration: 400
        }
    }

    background: null
    checkable: false
    // display: AbstractButton.IconOnly

}

