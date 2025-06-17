# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
from __future__ import annotations

"""
This example shows how to customize Qt Quick Controls by implementing a simple filesystem explorer.
"""


from filemodel import FileSystemModel  # noqa: F401
from watcher import RenderWatcher 
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType
from PySide6.QtCore import QCommandLineParser, qVersion, QCoreApplication


import sys

if __name__ == '__main__':
    app = QGuiApplication(sys.argv)
    # qmlRegisterType(RenderWatcher, "CustomComponents", 1,0, "CustomComponents")
    app.setOrganizationName("QtProject")
    app.setApplicationName("File System Explorer")
    app.setApplicationVersion(qVersion())
    app.setWindowIcon(QIcon(sys.path[0] + "/ABCQ/icons/app_icon.svg"))

    parser = QCommandLineParser()
    parser.setApplicationDescription("Qt Filesystemexplorer Example")
    parser.addHelpOption()
    parser.addVersionOption()
    parser.addPositionalArgument("", "Initial directory", "[path]")
    parser.process(app)
    args = parser.positionalArguments()

    engine = QQmlApplicationEngine()
    # app_root_path = QCoreApplication.applicationDirPath().replace("\\", "/")

    engine.rootContext().setContextProperty("backend", "py")
    engine.rootContext().setContextProperty("appPath", sys.path[0])
    # Include the path of this file to search for the 'qmldir' module
    engine.addImportPath(sys.path[0])
    # print(sys.path[0])
    engine.loadFromModule("ABCQ", "Main")
    


    if not engine.rootObjects():
        sys.exit(-1)

    if (len(args) == 1):
        fsm = engine.singletonInstance("ABCQ", "FileSystemModel")
        fsm.setInitialDirectory(args[0])

    exit_code = app.exec()
    del engine
    sys.exit(exit_code)
