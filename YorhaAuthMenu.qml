import QtQuick
import Quickshell.Io
import Quickshell
import "."

Item {
    id: root
    width: Config.authWidth + 100
    height: 500

    required property var context

    function executeCommand(cmd: string) {
        executeAuthCommand.command = cmd;
        executeAuthCommand.startDetached();
    }

    Process {
        id: executeAuthCommand
        running: false
        onExited: running = false
    }

    Column {
        id: mainLayout
        anchors.right: parent.right
        spacing: 20

        YorhaText {
            text: "AUTHENTICATION"
            fontSize: Config.fontLogin
            bold: true
            fontFamily: Config.mainFont
            anchors.right: parent.right
        }

        // Password input
        Rectangle {
            id: authBox
            width: Config.authWidth
            height: 65
            color: Config.yorhaDark
            border.color: authInput.activeFocus ? Config.yorhaBeige : "transparent"
            border.width: 2

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.verticalCenter: parent.verticalCenter
                spacing: 15

                Repeater {
                    model: root.context.currentText.length
                    Rectangle {
                        width: 14
                        height: 14
                        rotation: 45
                        color: Config.yorhaBeige
                    }
                }

                Rectangle {
                    width: 14
                    height: 14
                    rotation: 45
                    color: Config.yorhaBeige
                    visible: authInput.activeFocus

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation {
                            from: 1
                            to: 0
                            duration: 450
                        }
                        NumberAnimation {
                            from: 0
                            to: 1
                            duration: 450
                        }
                    }
                }
            }

            TextInput {
                id: authInput
                anchors.fill: parent
                color: "transparent"
                focus: true
                KeyNavigation.up: btnLogout
                KeyNavigation.down: btnPower
                KeyNavigation.tab: btnPower
                onTextChanged: {
                    root.context.currentText = text;
                    soundEngine.play("input");
                }
                onAccepted: root.context.tryUnlock()
                // NOTE: why i needed both?
                cursorVisible: false
                cursorDelegate: Item {}
            }

            MouseArea {
                anchors.fill: parent
                onClicked: authInput.forceActiveFocus()
            }
        }

        // Buttons
        Column {
            id: buttonContainer
            anchors.right: parent.right
            spacing: 12

            YorhaButton {
                id: btnPower
                width: 350
                text: "Power Off"
                confirmSound: "poweroff"
                onClicked: {
                    root.context.confirmAction();
                    actionTimer.action = function () {
                        executeCommand("poweroff");
                        soundEngine.stopBgm();
                    };
                    actionTimer.restart();
                }

                KeyNavigation.up: authInput
                KeyNavigation.down: btnReboot
                KeyNavigation.tab: btnReboot
            }
            YorhaButton {
                id: btnReboot
                width: 350
                text: "Reboot"
                confirmSound: "reboot"
                onClicked: {
                    root.context.confirmAction();
                    actionTimer.action = function () {
                        executeCommand("reboot");
                        soundEngine.stopBgm();
                    };
                    actionTimer.restart();
                }

                KeyNavigation.up: btnPower
                KeyNavigation.down: btnLogout
                KeyNavigation.tab: btnLogout
            }
            YorhaButton {
                id: btnLogout
                width: 350
                text: "Logout"
                confirmSound: "logout"
                onClicked: {
                    root.context.confirmAction();
                    actionTimer.action = function () {
                        // executeCommand("niri msg action quit")
                        soundEngine.stopBgm();
                        root.context.unlocked();
                    };
                    actionTimer.restart();
                }

                KeyNavigation.up: btnReboot
                KeyNavigation.down: authInput
                KeyNavigation.tab: authInput
            }

            Timer {
                id: actionTimer
                interval: Config.shaderDelay + 1050
                property var action: null
                onTriggered: {
                    if (action)
                        action();
                }
            }
        }
    }

    // Animated menu cursor
    Item {
        id: cursorWrapper
        width: 40
        height: 20
        x: buttonContainer.x - width - 10 + 90

        property int targetY: {
            if (btnPower.activeFocus)
                return buttonContainer.y + btnPower.y + (btnPower.height / 2) - (height / 2);
            if (btnReboot.activeFocus)
                return buttonContainer.y + btnReboot.y + (btnReboot.height / 2) - (height / 2);
            if (btnLogout.activeFocus)
                return buttonContainer.y + btnLogout.y + (btnLogout.height / 2) - (height / 2);
            return buttonContainer.y + btnPower.y + (btnPower.height / 2) - (height / 2);
        }

        y: targetY
        Behavior on y {
            NumberAnimation {
                id: moveAnim
                duration: 250
                easing.type: Easing.OutBack
            }
        }

        opacity: (btnPower.activeFocus || btnReboot.activeFocus || btnLogout.activeFocus) ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }

        Image {
            id: globalCursor
            source: "cursor.svg"
            sourceSize.width: 240
            anchors.fill: parent
            smooth: true
            mipmap: true

            transform: Translate {
                SequentialAnimation on x {
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: -5
                        to: 5
                        duration: 1000
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        from: 5
                        to: -5
                        duration: 1000
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            SequentialAnimation on opacity {
                running: moveAnim.running
                loops: Animation.Infinite
                NumberAnimation {
                    from: 1
                    to: 0.3
                    duration: 40
                }
                NumberAnimation {
                    from: 0.3
                    to: 1
                    duration: 40
                }
            }
        }
    }
}
