// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import "."

pragma Singleton

QtObject {
    id: colorMgr
    // property bool darkMode: Application.styleHints.colorScheme === Qt.ColorScheme.Dark
    property QtObject theme
    property string themeName

    function loadTheme(name) {

        themeName = name

        if (name==="Auto"){
            var darkmode = Application.styleHints.colorScheme === Qt.ColorScheme.Dark
            name = darkmode ? "Dark" : "Light"
        }

        var url = Qt.resolvedUrl("Themes/"+name+".qml")
        var component = Qt.createComponent(url)
        if (component.status === Component.Ready){
            theme = component.createObject(colorMgr)
        }
        else {
            console.error("Failed to load theme:", url, component.errorString())
        }


    }

    // Component.onCompleted: {

    //     if (themeName === null){
    //         loadTheme("Auto")
    //     }
    //     else{
    //         loadTheme()
    //     }
    // }

}

