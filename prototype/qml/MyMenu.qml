// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls.Basic
import prototype
pragma ComponentBehavior: Bound
Menu {
    id: root
    property real fontUIx
    width: 210 + (5*fontUIx)


    delegate: MenuItem {
        id: menuItem
        contentItem: Item {
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 9

                width: parent.width-9

                textFormat: Text.RichText

                text: menuItem.text
                color: enabled ? Colors.text : Colors.disabledText
                font.pixelSize: fontUIx
            }
            Rectangle {
                id: indicator

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                width: 6
                height: 4

                visible: menuItem.highlighted
                color: Colors.color1
            }
        }
        background: Rectangle {
            // implicitWidth: 17*fontUIx
            implicitHeight: fontUIx * 2
            implicitWidth: root.width
            color: menuItem.highlighted ? Colors.active : "transparent"
        }
    }
    background: Rectangle {
        // implicitWidth: 17*fontUIx
        implicitHeight: fontUIx * 2
        implicitWidth: root.width
        color: Colors.surface2
    }
}
