// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick

pragma Singleton

QtObject {
    id: dark
    // property color background: "#00CC00"
    property color surface2: "#DEEFFF" //aliceblue
    property color surface1: "#E8FFF3" //mintcream
    property color text: "#050566" //w_navy
    property color textFile: text
    property color disabledText: "#2C313A"
    property color selection: "#FFEFB6" //cornsilk
    property color inactive: "#292828"
    property color folder: "#C9C9F3" //lavender
    property color icon: Qt.darker(folder,1.6)
    property color iconIndicator:  "black"
    property color color2:  folder
    property color color1: folder
    property color active: "#FFDEE8" //lavenderblush

    property color controlText: text
    property color controlTextHi: Qt.lighter(text, 1.8)

    property color controlBG: "#DEEFFF" // aliceblue
    property color controlBGHi: "#FFDEE8" //lavenderblush


        // FFEFB6 // cornsilk1 "#DACD9B" //cornsilk2 FFDEE8 // lavenederblush1
}

