import QtQuick
import QtQuick.Effects
import QtQuick.Controls.Basic
import "."
pragma ComponentBehavior: Bound
import Themes
// import FModel


Rectangle {
    id: root

    signal fileClicked(string filePath)
    property alias rootIndex: fileSystemTreeView.rootIndex
    property real fontUIx
    signal requestOpen(string filePath)

    TreeView {
        id: fileSystemTreeView

        property int lastIndex: -1

        anchors.fill: parent
        model: FileSystemModel
        rootIndex: FileSystemModel.rootIndex
        boundsBehavior: Flickable.StopAtBounds
        boundsMovement: Flickable.StopAtBounds
        clip: true

        Component.onCompleted: fileSystemTreeView.toggleExpanded(0)

        // The delegate represents a single entry in the filesystem.
        delegate: TreeViewDelegate {
            id: treeDelegate
            indentation: 8
            implicitWidth: fileSystemTreeView.width > 0 ? fileSystemTreeView.width : 250
            implicitHeight: fontUIx * 1.5

            // Since we have the 'ComponentBehavior Bound' pragma, we need to
            // require these properties from our model. This is a convenient way
            // to bind the properties provided by the model's role names.
            required property int index
            required property url filePath
            required property string fileName

            indicator: Image {
                id: directoryIcon

                x: treeDelegate.leftMargin + (treeDelegate.depth * treeDelegate.indentation)
                anchors.verticalCenter: parent.verticalCenter
                source: treeDelegate.hasChildren ? (treeDelegate.expanded
                            ? "icons/folder_open.svg" : "icons/folder_closed.svg")
                        : "icons/generic_file.svg"
                sourceSize.width: 20
                sourceSize.height: 20
                fillMode: Image.PreserveAspectFit

                smooth: true
                antialiasing: true
                asynchronous: true
                width: fontUIx
                height: fontUIx

            }

            contentItem: Text {
                id: mytext
                text: treeDelegate.fileName
                color: Theme.theme.text
                font.pixelSize: fontUIx

            }

            background: Rectangle {
                color: (treeDelegate.index === fileSystemTreeView.lastIndex)
                    ? Theme.theme.selection
                    : (hoverHandler.hovered ? Theme.theme.active : "transparent")


            }

            // We color the directory icons with this MultiEffect, where we overlay
            // the colorization color ontop of the SVG icons.
            MultiEffect {
                id: iconOverlay

                anchors.fill: directoryIcon
                source: directoryIcon
                colorization: 1.0
                brightness: 1.0
                colorizationColor: {
                    const isFile = treeDelegate.index === fileSystemTreeView.lastIndex
                                    && !treeDelegate.hasChildren;
                    if (isFile)
                        return Qt.lighter(Theme.theme.folder, 3)

                    const isExpandedFolder = treeDelegate.expanded && treeDelegate.hasChildren;
                    if (isExpandedFolder)
                        return Theme.theme.color2
                    else
                        return Theme.theme.folder
                }
            }

            HoverHandler {
                id: hoverHandler
            }

            TapHandler {
                acceptedButtons: Qt.LeftButton
                // acceptedModifiers: Qt.NoModifier | Qt.ControlModifier
                onTapped: {
                    switch(point.modifiers) {

                        case Qt.NoModifier:
                            fileSystemTreeView.toggleExpanded(treeDelegate.row)
                            fileSystemTreeView.lastIndex = treeDelegate.index
                            // If this model item doesn't have children, it means it's
                            // representing a file.
                            if (!treeDelegate.hasChildren)
                                root.fileClicked(treeDelegate.filePath)
                        break;

                        case Qt.ControlModifier:
                            if (!treeDelegate.hasChildren)
                                root.requestOpen(treeDelegate.filePath)

                        break;
                    }
                }
            }



            // MyMenu {
            //     id: contextMenu
            //     Action {
            //         text: qsTr("Set as root index")
            //         onTriggered: {
            //             fileSystemTreeView.rootIndex = fileSystemTreeView.index(treeDelegate.row, 0)
            //         }
            //     }
            //     Action {
            //         text: qsTr("Reset root index")
            //         onTriggered: fileSystemTreeView.rootIndex = undefined
            //     }
            // }
        }

        // Provide our own custom ScrollIndicator for the TreeView.
        ScrollIndicator.vertical: ScrollIndicator {
            active: true
            implicitWidth: 15

            contentItem: Rectangle {
                implicitWidth: 6
                implicitHeight: 6

                color: Theme.theme.color1
                opacity: fileSystemTreeView.movingVertically ? 0.5 : 0.0

                Behavior on opacity {
                    OpacityAnimator {
                        duration: 500
                    }
                }
            }
        }
    }
}
