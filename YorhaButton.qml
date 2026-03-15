import QtQuick
import Quickshell.Io
import "."

Item {
    id: root
    width: 400
    height: 50
    property real volume: 1
    property alias text: label.text
    signal clicked

    readonly property bool active: root.activeFocus || mouseArea.containsMouse

    property string cursorSound: "cursor"
    property string mouseSound: "mouse"
    property string confirmSound: "confirm"

    onActiveFocusChanged: if (activeFocus)
        soundEngine.play(cursorSound)

    // Top line
    Rectangle {
        width: parent.width
        height: 1
        color: Config.yorhaDark
        anchors.top: parent.top
        opacity: 0.8
    }
    // Bottom line
    Rectangle {
        width: parent.width
        height: 1
        color: Config.yorhaDark
        anchors.bottom: parent.bottom
        opacity: 0.8
    }

    // fill
    Rectangle {
        id: selectionBar
        height: parent.height - 4
        anchors.verticalCenter: parent.verticalCenter
        color: Config.yorhaDark
        width: root.active ? parent.width : 0
        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }

    Text {
        id: label
        anchors.centerIn: parent
        color: root.active ? Config.yorhaBeige : Config.yorhaDark
        font.pixelSize: Config.fontSmall
        font.bold: true
        font.family: Config.mainFont
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 1
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    Keys.onReturnPressed: {
        soundEngine.play(confirmSound);
        root.clicked();
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            soundEngine.play(mouseSound);
            root.clicked();
        }
    }
}
