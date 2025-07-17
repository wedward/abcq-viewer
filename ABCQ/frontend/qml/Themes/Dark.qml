// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick

pragma Singleton

QtObject {
    id: dark
    // property color background: "#292828"
    property color surface1: "#171819"
    property color surface2: "#090A0C"
    property color text: "#D4BE98"
    property color textFile: "#E1D2B7"
    property color disabledText: "#2C313A"
    property color selection: "#4B4A4A"
    property color inactive: "#292828"
    property color folder: "#383737"
    property color icon: "#383737"
    property color iconIndicator:  text
    property color color1:  "#A7B464"
    property color color2: "#D3869B"
    property color active: "#222228"

    property color controlText: "#D4BE98"
    property color controlTextHi: "#FDEC99"

    property color controlBG: "#2C313A"  //lavenderblush1
    property color controlBGHi: Qt.lighter(controlBG, 1.075)


}

