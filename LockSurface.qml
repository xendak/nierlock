import "."
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    required property LockContext context

    property string userWhoAmI: "xendak"
    property bool accessGranted: false




    color: Config.yorhaBeige

    YorhaSounds {
        id: soundEngine
    }

    Component.onCompleted: {
        soundEngine.playBgm();
        console.log("Resolution Mode: ", Config.resolution);
    }
    Component.onDestruction: {
        soundEngine.stopBgm();
    }

    ShaderEffectSource {
        id: uiSource
        sourceItem: rootContent
        anchors.fill: parent
        live: true
        hideSource: glitchTimer.running || successTimer.running
    }

    ShaderEffect {
        id: glitchShader
        anchors.fill: parent
        property variant source: uiSource
        property real iTime: 0
        visible: glitchTimer.running
        z: 9999
        fragmentShader: "glitch.frag.qsb"
        NumberAnimation on iTime {
            from: 0
            to: 10
            duration: Config.shaderDelay
            running: glitchTimer.running
        }
    }

    Timer {
        id: glitchTimer
        interval: Config.shaderDelay
        onTriggered: root.context.showFailure = false
    }

    ShaderEffect {
        id: successShader
        anchors.fill: parent
        property variant source: uiSource
        property real iTime: 0
        visible: successTimer.running
        z: 9999
        fragmentShader: "success.frag.qsb"

        NumberAnimation on iTime {
            id: successAnim
            from: 0.0
            to: 1.0
            duration: Config.shaderDelay
            running: successTimer.running
            easing.type: Easing.InOutQuad
        }
    }

    Timer {
        id: successTimer
        interval: Config.shaderDelay
        onTriggered: {
            root.context.showSuccess = false;
            root.accessGranted = true;
            successShader.iTime = 0;
        }
    }

    Connections {
        target: root.context
        function onFailed() {
            if (root.context.showFailure) {
                soundEngine.play("error");
                glitchTimer.restart();
            }
        }
        function onShowSuccessChanged() {
            if (root.context.showSuccess) {
                soundEngine.play("error");
                successTimer.restart();
            }
        }
    }

    

    // Username
    Process {
        id: whoamiProc
        command: ["whoami"]
        running: true
        stdout: SplitParser {
            onRead: data => root.userWhoAmI = data.trim()
        }
    }

    // -------------------------------------------------------------------------
    Item {
        id: rootContent
        anchors.fill: parent

        // DEBUG: help to tst the shaders when iterating
        Keys.onPressed: event => {
            if (event.key === Qt.Key_G) {
                console.log("Manual glitch trigger start");
                glitchTimer.restart();
            }
            if (event.key === Qt.Key_S) {
                console.log("Manual success trigger start");
                successTimer.restart();
            }
        }

        // BG Image
        Image {
            source: "background.png"
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            opacity: 0.4
        }

        // Grid
        Canvas {
            anchors.fill: parent
            opacity: 0.15
            onPaint: {
                var ctx = getContext("2d");
                ctx.strokeStyle = Config.yorhaDark;
                ctx.lineWidth = 0.5;
                for (var x = 0; x < width; x += 40) {
                    ctx.beginPath();
                    ctx.moveTo(x, 0);
                    ctx.lineTo(x, height);
                    ctx.stroke();
                }
                for (var y = 0; y < height; y += 40) {
                    ctx.beginPath();
                    ctx.moveTo(0, y);
                    ctx.lineTo(width, y);
                    ctx.stroke();
                }
            }
        }

        Rectangle {
            id: topBar
            width: parent.width
            height: Config.barHeight
            color: Config.yorhaBlack
            anchors.top: parent.top
            z: 10

            YorhaBorder {
                anchors.top: parent.top
                anchors.topMargin: 2
                symbol: "▲"
            }

            YorhaBorder {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
            }
        }

        Rectangle {
            id: bottomBar
            width: parent.width
            height: Config.barHeight + 12
            color: Config.yorhaBlack
            anchors.bottom: parent.bottom
            z: 10

            YorhaBorder {
                anchors.top: parent.top
                anchors.topMargin: 2
                symbol: "▲"
            }

            YorhaBorder {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 60

                YorhaText {
                    text: "Enter credentials to proceed."
                    color: Config.yorhaBeige
                    shadowColor: Qt.rgba(Config.yorhaBeige.r, Config.yorhaBeige.g, Config.yorhaBeige.b, 0.15)
                    shadowOffset: 1.5
                    fontSize: Config.fontMedium
                    fontFamily: Config.mainFont
                    typeOnAppear: true
                    glitchEnabled: true
                    glitchRate: 2
                    glitchMaxOfs: 8
                }
                Item {
                    Layout.fillWidth: true
                }

                Row {
                    spacing: 30
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        // TODO: maybe get a unicode of something that doesnt distort the text?
                        // so i dont need this hardcoded ??
                        y: Config.resolution == 1 ? -4 : -2
                        text: "[ ↑↓ ] Select"
                        color: Config.yorhaBeige
                        font.pixelSize: Config.fontHeader
                        opacity: 0.6
                    }
                    Text {
                        text: "[ Enter ] Confirm"
                        color: Config.yorhaBeige
                        font.pixelSize: Config.fontHeader
                        opacity: 0.6
                    }
                }
            }
        }

        // Vertical Line Animation
        Rectangle {
            height: parent.height
            width: 1
            color: Config.yorhaDark
            opacity: 0.2
            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation {
                    from: 0
                    to: root.width
                    duration: 10000
                    easing.type: Easing.Linear
                }
                NumberAnimation {
                    from: root.width
                    to: 0
                    duration: 10000
                    easing.type: Easing.Linear
                }
            }
        }

        Item {
            id: glitchPool
            anchors.fill: parent
            z: 1
            Repeater {
                model: Config.glitchLines
                YorhaGlitchLine {
                    rootWidth: root.width
                    rootHeight: root.height
                }
            }
        }

        // LOGIN
        Column {
            anchors.left: parent.left
            anchors.top: topBar.bottom
            anchors.margins: Config.marginMedium
            spacing: 0

            Item {
                width: loginText.width
                height: loginText.height

                YorhaText {
                    id: loginText
                    text: "LOGIN"
                    bold: true
                    fontFamily: Config.mainFont
                    fontSize: Config.fontLogin
                    color: Config.yorhaDark
                }
            }

            Item {
                width: 380
                height: 35
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Config.yorhaDark
                    anchors.top: parent.top
                    opacity: 0.6
                }
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Config.yorhaDark
                    anchors.bottom: parent.bottom
                    opacity: 0.6
                }
                Text {
                    anchors.centerIn: parent
                    text: ". ".repeat(60)
                    color: Config.yorhaDark
                    opacity: 0.3
                    font.pixelSize: 10
                }
            }

            Rectangle {
                width: 380
                height: 45
                color: Config.yorhaDark
                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    spacing: 10
                    Rectangle {
                        width: 14
                        height: 14
                        radius: 7
                        color: "transparent"
                        border.color: Config.yorhaBeige
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter
                        Rectangle {
                            width: 4
                            height: 4
                            radius: 2
                            color: Config.yorhaBeige
                            anchors.centerIn: parent
                        }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.userWhoAmI
                        font.pixelSize: Config.fontHeader
                        color: Config.yorhaBeige
                        font.capitalization: Font.AllUppercase
                        font.family: Config.mainFont
                    }
                }
            }
        }

        // CLOCK
        YorhaClock {
            id: clockColumn
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -140
        }

        // ACCESS GRANTED EFFECT
        Item {
            id: accessGrantedBlock
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom:           bottomBar.top
            anchors.bottomMargin:     100
            width:   accessText.implicitWidth
            height:  accessText.implicitHeight + subLine.height + 8
            visible: root.accessGranted
            opacity: 0.0

            Behavior on opacity {
                NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
            }

            // Fade in AND start typing when shown — NOT typeOnAppear
            onVisibleChanged: {
                if (visible) {
                    opacity = 1.0
                    soundEngine.play("input")
                    accessText.startTyping()
                }
            }

            YorhaText {
                id:   accessText
                text: "ACCESS GRANTED"
                bold: true
                fontSize:   Config.fontLogin + 20
                showShadow: true

                typeOnAppear:    false
                typeInterval:    55

                glitchEnabled:   true
                glitchRate:      2
                glitchMaxOfs:    8
                glitchSubChance: 0.35

                typeSoundEnabled: true
                typeSound:        "input"
                typeSoundRate:    2
            }

            Rectangle {
                id: subLine
                anchors.top:              accessText.bottom
                anchors.topMargin:        8
                anchors.horizontalCenter: parent.horizontalCenter
                height:  1
                color:   Config.yorhaDark
                opacity: 0.5
                width:   0
                Behavior on width {
                    NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                }
                Connections {
                    target: accessText
                    function onTypingFinished() {
                        subLine.width = accessText.implicitWidth
                    }
                }
            }
        }

        YorhaStatusBar {
            id: systemStatus
            anchors.right: parent.right
            anchors.top: topBar.bottom
            anchors.margins: Config.marginLarge
            stats: ({
                    cpuPerc: SystemStats.cpuPerc,
                    gpuPerc: SystemStats.gpuPerc,
                    memPerc: SystemStats.memPerc,
                    cpuTemp: SystemStats.cpuTemp,
                    gpuTemp: SystemStats.gpuTemp
                })
        }

        // Mission
        YorhaMission {
            anchors.left:    parent.left
            anchors.bottom:  bottomBar.top
            anchors.margins: Config.marginLarge
      }

        
        YorhaAuthMenu {
            anchors.right: parent.right
            anchors.bottom: bottomBar.top
            anchors.rightMargin: 100
            anchors.bottomMargin: Config.resolution == 1 ? 100 : -20
            context: root.context
        }
    }
}
