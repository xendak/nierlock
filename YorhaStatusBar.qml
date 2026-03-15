import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "."

Item {
    id: root
    width: Config.statusWidth
    height: 300

    property string profilePath: "profile.svg"
    property var stats: ({})

    property var sysInfo: [
        {
            key: "Unit",
            val: "Loading..."
        },
        {
            key: "Host",
            val: "---"
        },
        {
            key: "Kernel",
            val: "---"
        },
        {
            key: "Uptime",
            val: "---"
        },
        {
            key: "Pkgs",
            val: "---"
        }
    ]

    function getTempStatus() {
        if (stats.cpuTemp > 85 || stats.gpuTemp > 80)
            return "SYSTEM STATE: CRITICAL OVERHEAT";
        if (stats.cpuTemp > 75 || stats.gpuTemp > 70)
            return "SYSTEM STATE: WARNING";
        return "SYSTEM STATE: NO ERROR";
    }

    // sysInfo
    Process {
        id: fetchSysInfo
        command: ["sh", "-c", "OS=$(grep 'PRETTY_NAME' /etc/os-release | cut -d'\"' -f2); HOST=$(uname -n); KERN=$(uname -r); UP=$(uptime -p | sed -s 's/up //g'); PKGS=$(nix-store --query --requisites /run/current-system | wc -l); echo \"$OS|$HOST|$KERN|$UP|$PKGS\""]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                console.log("sysinfo fetcher");
                let parts = text.trim().split("|");
                if (parts.length === 5) {
                    root.sysInfo = [
                        {
                            key: "OS",
                            val: parts[0]
                        },
                        {
                            key: "HOST",
                            val: parts[1]
                        },
                        {
                            key: "KERNEL",
                            val: parts[2]
                        },
                        {
                            key: "UPTIME",
                            val: parts[3]
                        },
                        {
                            key: "PACKAGES",
                            val: parts[4]
                        }
                    ];
                }
                fetchSysInfo.running = false;
            }
        }
    }
    Timer {
        id: sysInfoTimer
        interval: 60000 // 60 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: fetchSysInfo.running = true
    }

    // Header
    Rectangle {
        id: header
        width: parent.width
        height: 35
        color: Config.yorhaDark

        Text {
            text: "Status"
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            color: Config.yorhaBeige
            font.pixelSize: Config.fontHeader
            font.family: Config.mainFont
        }
    }

    Rectangle {
        anchors.top: header.bottom
        width: parent.width
        height: parent.height - header.height
        color: "transparent"
        border.color: Config.yorhaDark
        border.width: 1

        // Profile image
        Rectangle {
            id: profileFrame
            x: 20
            y: 20
            width: 100
            height: 110
            color: Config.yorhaDark

            Image {
                source: root.profilePath
                anchors.fill: parent
                anchors.topMargin: 10
                sourceSize.width: 1024
                sourceSize.height: 1024
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }
        }

        Column {
            anchors.left: profileFrame.right
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            y: 20
            spacing: 2

            Repeater {
                model: root.sysInfo
                delegate: Item {
                    width: parent.width
                    height: 22

                    Text {
                        text: modelData.key
                        color: Config.yorhaDark
                        font.pixelSize: Config.fontSmall - 2
                        opacity: 0.7
                    }
                    Text {
                        text: modelData.val
                        color: Config.yorhaDark
                        font.pixelSize: Config.fontSmall - 2
                        font.bold: true
                        anchors.right: parent.right
                    }
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Config.yorhaDark
                        opacity: 0.2
                        anchors.bottom: parent.bottom
                    }
                }
            }
        }

        Column {
            anchors.bottom: footer.top
            anchors.bottomMargin: 15
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            spacing: 12

            YorhaBar {
                label: "CPU:"
                ratio: stats.cpuPerc || 0
                valueText: (stats.cpuPerc * 100).toFixed(1) + "% [" + stats.cpuTemp + "°C]"
            }
            YorhaBar {
                label: "GPU:"
                ratio: stats.gpuPerc || 0
                valueText: (stats.gpuPerc * 100).toFixed(1) + "% [" + stats.gpuTemp + "°C]"
            }
            YorhaBar {
                label: "MEM:"
                ratio: stats.memPerc || 0
                valueText: (stats.memPerc * 100).toFixed(1) + "%"
            }
        }

        Text {
            id: footer
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.getTempStatus()
            font.pixelSize: Config.fontSmall - 4
            font.letterSpacing: 2
            opacity: 0.6
            color: (stats.cpuTemp > 80 || stats.gpuTemp > 75) ? Config.yorhaRed : Config.yorhaDark
        }
    }

    component YorhaBar: RowLayout {
        property string label: ""
        property string valueText: ""
        property real ratio: 0.0
        width: parent.width
        spacing: 10

        Text {
            text: label
            Layout.preferredWidth: 40
            color: Config.yorhaDark
            font.pixelSize: Config.fontSmall - 2
            opacity: 0.7
        }
        Text {
            text: valueText
            Layout.preferredWidth: 120
            color: Config.yorhaDark
            font.pixelSize: Config.fontSmall - 2
            font.bold: true
            horizontalAlignment: Text.AlignRight
        }
        Rectangle {
            height: 12
            Layout.fillWidth: true
            border.color: Config.yorhaDark
            border.width: 1
            color: "transparent"

            Rectangle {
                width: parent.width * Math.min(ratio, 1.0)
                height: parent.height
                // TODO: maybe do tihs in a better way of temperature i guess?
                color: ratio >= 0.9 ? Config.yorhaRed : Config.yorhaDark
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
                Behavior on width {
                    NumberAnimation {
                        duration: 500
                    }
                }
            }
        }
    }
}
