// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick

pragma Singleton

QtObject {
    id: dark
    // property color background: "#00CC00"
    property color surface2: "#CCCCCC"
    property color surface1: "#EEEEEE"

    property color text: "#050566" //w_navy
    property color textFile: text
    property color disabledText: "#2C313A"
    property color selection: "#E8FFF3"
    property color inactive: "#292828"
    property color folder: text
    property color icon: text
    property color iconIndicator: "firebrick" //"#089B08"
    property color color2:  folder
    property color color1: folder
    property color active: "#DEEFFF" //aliceblue

    property color controlText: text
    property color controlTextHi: Qt.lighter(text, 1.8)

    property color controlBG: surface2 // aliceblue
    property color controlBGHi: active //lavenderblush


        // FFEFB6 // cornsilk1 "#DACD9B" //cornsilk2 FFDEE8 // lavenederblush1
}

