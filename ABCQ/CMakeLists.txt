# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

cmake_minimum_required(VERSION 3.16)
project(ABCQ LANGUAGES CXX)

if (ANDROID OR IOS)
    message(FATAL_ERROR "Platform is not supported")
    return()
endif ()

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Svg)
qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(abcq
    main.cpp
    icons/app_icon.svg icons/folder_closed.svg icons/folder_open.svg icons/generic_file.svg   icons/light_bulb.svg  icons/read.svg
)

set_target_properties(abcq
    PROPERTIES
        WIN32_EXECUTABLE TRUE
        MACOSX_BUNDLE TRUE
)

set_source_files_properties(qml/Colors.qml
    PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
)

target_link_libraries(abcq
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Svg
)

qt_add_qml_module(abcq
    URI ABCQ
    RESOURCES
        "icons/folder_closed.svg"
        "icons/folder_open.svg"
        "icons/generic_file.svg"
        "icons/light_bulb.svg"
        "icons/read.svg"
        "icons/app_icon.svg"
    QML_FILES
        "Main.qml"
        "qml/ViewerWindow.qml"
        "qml/Colors.qml"
        "qml/Viewer.qml"
        "qml/FileSystemView.qml"
        "qml/MyMenu.qml"
        "qml/MyMenuBar.qml"
        "qml/Sidebar.qml"
        "qml/ResizeButton.qml"
        "qml/WindowDragHandler.qml"
        "qml/Controls.qml"
        "qml/ControlButton.qml"

    SOURCES
        filesystemmodel.cpp
        filesystemmodel.h
        renderwatcher.h
        renderwatcher.cpp


)
target_compile_definitions(abcq PRIVATE QT_QML_DEBUG)

install(TARGETS abcq
    BUNDLE  DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

qt_generate_deploy_qml_app_script(
    TARGET abcq
    OUTPUT_SCRIPT deploy_script
    MACOS_BUNDLE_POST_BUILD
    NO_UNSUPPORTED_PLATFORM_ERROR
    DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
)
install(SCRIPT ${deploy_script})
