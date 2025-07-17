import QtQuick
// import QtQuick.Layouts
import QtQuick.Controls.Basic
import "."
import Themes

Item{
    id: root

    signal pressed(var mouse)
    signal dragged(var dx, var dy)
    signal doubleClicked(var mouse)
    signal released()
    property real fontSize
    property alias text: txt.text
    property alias cursor: hh.cursorShape
    property alias hAlign: txt.horizontalAlignment

    Rectangle{
        anchors.fill: parent
        color: mouse.containsMouse || mouse.lc ? Theme.theme.controlBGHi : Theme.theme.controlBG
        clip: true
        radius: height*.15

        Label {
            id: txt
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
            color: mouse.containsMouse || mouse.lc ? Theme.theme.controlTextHi : Theme.theme.controlText
            property int tempSize: 0
            font.pixelSize: root.fontSize + tempSize

        }
    }

    MouseArea{
        id:mouse
        anchors.fill: parent

        property bool lc: false
        property real lastx
        property real lasty

        property alias tempFont: txt.font
        property bool btnHovered: false

        onContainsMouseChanged: {
            if (containsMouse) {
                btnHovered=true
                txt.tempSize += 1
            }
            else if (btnHovered){
                txt.tempSize -= 1
                btnHovered = false
            }
        }


        onPressed: (m) => {
            root.pressed(m)
            lc = true
            lastx = m.x
            lasty = m.y
        }

        onPositionChanged: (m) => {

            if (lc) {

                var dx = (m.x - lastx)
                var dy = (m.y - lasty)

                lastx = m.x
                lasty = m.y

                root.dragged(dx,dy)
            }

        }

        onReleased: {
            root.released()
            lc = false
        }
        onCanceled: {
            root.released()
            lc = false
        }

        onDoubleClicked: (m) => root.doubleClicked(m)

        hoverEnabled: true
        HoverHandler {
            id: hh
            cursorShape: Qt.PointingHandCursor
        }
    }
}
