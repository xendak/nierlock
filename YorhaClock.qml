import QtQuick
import "."

Column {
    id: root

    spacing: 5

    // Clock
    Text {
        text: Qt.formatDateTime(new Date(), "hh:mm")
        font.pixelSize: Config.fontBig
        color: Config.yorhaDark
        font.family: Config.monoFont
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        text: Qt.formatDateTime(new Date(), "yyyy.MM.dd")
        font.pixelSize: Config.fontSmall + 4
        color: Config.yorhaDark
        font.family: Config.monoFont
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0.7
    }

    Item {
        width: 1
        height: 30
    }

    // Title
    Column {
        spacing: 5
        anchors.horizontalCenter: parent.horizontalCenter

        YorhaText {
            text: "[   NieR:Automata   ]"
            fontSize: Config.fontLogin
            letterSpacing: 2
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "YoRHa Operating System"
            font.pixelSize: Config.fontMedium - 6
            color: Config.yorhaDark
            font.family: Config.mainFont
            opacity: 0.6
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: parent.width * 0.6
            height: 1
            color: Config.yorhaDark
            opacity: 0.4
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Item {
        width: 1
        height: 100
    }

    // Spinner Animation
    Item {
        id: spinner
        width: Config.spinnerSize
        height: Config.spinnerSize
        anchors.horizontalCenter: parent.horizontalCenter

        RotationAnimation on rotation {
            from: 0
            to: 360
            duration: 25000
            loops: Animation.Infinite
            running: true
        }

        // Circles
        Repeater {
            model: [Config.spinnerSize * 0.9, Config.spinnerSize * 0.6, Config.spinnerSize * 0.3]
            Rectangle {
                width: modelData
                height: modelData
                radius: width / 2
                color: "transparent"
                border.color: Config.yorhaDark
                border.width: 1
                opacity: 0.25
                anchors.centerIn: parent
            }
        }

        // Crossed lines
        Rectangle {
            width: Config.spinnerSize * 1.05
            height: 1
            color: Config.yorhaDark
            opacity: 0.4
            anchors.centerIn: parent
        }
        Rectangle {
            width: 1
            height: Config.spinnerSize * 1.05
            color: Config.yorhaDark
            opacity: 0.4
            anchors.centerIn: parent
        }

        // tick marks
        Repeater {
            model: 4
            Item {
                anchors.centerIn: parent
                rotation: 45 + (index * 90)
                Rectangle {
                    width: 1
                    height: 8
                    color: Config.yorhaDark
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: -(Config.spinnerSize * 0.475)
                }
            }
        }

        // Center filled circle
        Rectangle {
            width: 12
            height: 12
            radius: 6
            color: Config.yorhaDark
            anchors.centerIn: parent
        }
    }
}
