import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell
import "."

Item {
    id: root

    property var todoList: []
    property string currentLoc: Config.missionLocations[Math.floor(Math.random() * Config.missionLocations.length)]

    readonly property string syncValue: {
        if (todoList.length === 0)
            return "100.0%";
        let completed = todoList.filter(item => item.done).length;
        return ((completed / todoList.length) * 100).toFixed(1) + "%";
    }

    width: 450
    height: hudColumn.implicitHeight

    // TODO extraction
    Process {
        id: todoProc
        property string buffer: ""
        command: ["cat", Config.todoPath]
        running: true
        onStarted: buffer = ""
        onExited: {
            let parsed = [];
            for (let line of buffer.split('\n')) {
                let m = line.trim().match(/^-\s*\[(x| )?\]\s*(.*)/);
                if (m)
                    parsed.push({
                        task: m[2].trim(),
                        done: m[1] === 'x'
                    });
            }
            root.todoList = parsed.slice(0, 5);
        }
        stdout: SplitParser {
            onRead: data => todoProc.buffer += data + "\n"
        }
    }

    Column {
        id: hudColumn
        width: parent.width
        spacing: 10

        Rectangle {
            width: parent.width * 0.7
            height: 1
            color: Config.yorhaDark
            opacity: 0.4
        }

        Column {
            spacing: 2

            Text {
                text: "CURRENT LOCATION: " + root.currentLoc
                color: Config.yorhaDark
                font.pixelSize: Config.fontSmall - 2
                font.family: Config.mainFont
                opacity: 0.6
            }

            Text {
                text: "MISSION STATUS: " + (root.todoList.length > 0 ? "ACTIVE" : "INACTIVE")
                color: Config.yorhaDark
                font.pixelSize: Config.fontHeader
                font.bold: true
                font.family: Config.mainFont
            }
        }

        // Objectives
        Column {
            width: parent.width
            spacing: 8
            topPadding: 5

            Text {
                text: "Objective:"
                color: Config.yorhaDark
                font.pixelSize: Config.fontSmall - 2
                font.family: Config.mainFont
                opacity: 0.6
                visible: root.todoList.length > 0
            }

            Repeater {
                model: root.todoList

                Item {
                    width: hudColumn.width
                    // height tracks the text height once it's measured
                    height: taskText.implicitHeight + 4

                    Rectangle {
                        id: diamond
                        width: 10
                        height: 10
                        rotation: 45
                        color: modelData.done ? Config.todoDone : Config.todoPending
                        anchors.verticalCenter: parent.verticalCenter

                        SequentialAnimation on opacity {
                            running: taskHover.containsMouse
                            loops: Animation.Infinite
                            NumberAnimation {
                                from: 1
                                to: 0.2
                                duration: 200
                            }
                            NumberAnimation {
                                from: 0.2
                                to: 1
                                duration: 200
                            }
                        }
                        onVisibleChanged: opacity = 1.0
                    }

                    YorhaText {
                        id: taskText
                        anchors.left: diamond.right
                        anchors.leftMargin: 12
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        text: modelData.task
                        fontSize: Config.fontSmall
                        showShadow: false

                        typeOnAppear: true
                        typeInterval: 50
                        typeDelay: index * 450

                        glitchEnabled: true
                        glitchRate: 3
                        glitchMaxOfs: 4
                        glitchSubChance: 0.25
                    }

                    MouseArea {
                        id: taskHover
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }

            Text {
                text: "NO CURRENT OBJECTIVES"
                color: Config.yorhaDark
                font.pixelSize: Config.fontHeader - 4
                font.family: Config.mainFont
                opacity: 0.4
                visible: root.todoList.length === 0
            }
        }

        Column {
            spacing: 2
            topPadding: 15
            width: parent.width

            Text {
                text: "SYSTEM SYNCHRONIZATION: OPERATIONAL"
                color: Config.yorhaDark
                font.pixelSize: Config.fontSmall - 4
                font.family: Config.mainFont
                opacity: 0.4
            }

            RowLayout {
                width: parent.width * 0.7
                spacing: 0

                Text {
                    text: "POD 042 / 153 SYNC: "
                    color: Config.yorhaDark
                    font.pixelSize: Config.fontHeader - 4
                    font.family: Config.mainFont
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: root.syncValue
                    color: (parseFloat(root.syncValue) < 70.0) ? Config.yorhaRed : Config.yorhaGreen
                    font.pixelSize: Config.fontHeader - 4
                    font.family: Config.mainFont
                    font.bold: true
                }
            }

            Rectangle {
                width: parent.width * 0.7
                height: 1
                color: Config.yorhaDark
                opacity: 0.3
            }
        }
    }
}
