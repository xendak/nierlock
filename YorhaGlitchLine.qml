import QtQuick
import "."

Rectangle {
    id: root
    height: 1
    color: Config.yorhaDark
    opacity: 0

    required property int rootWidth
    required property int rootHeight

    SequentialAnimation {
        id: anim
        loops: Animation.Infinite
        running: true

        PauseAnimation {
            duration: Math.random() * 5000
        }

        ScriptAction {
            script: {
                let dir = Math.random() > 0.5 ? 1 : 0;
                root.width = 100 + Math.random() * 300;
                root.y = Math.random() * rootHeight;
                root.opacity = 0.2 + Math.random() * 0.3;
                moveAnim.from = dir === 0 ? -root.width : rootWidth;
                moveAnim.to = dir === 0 ? rootWidth : -root.width;
                moveAnim.duration = 1000 + Math.random() * 1200;
            }
        }

        NumberAnimation {
            id: moveAnim
            target: root
            property: "x"
            easing.type: Easing.Linear
        }

        PropertyAction {
            target: root
            property: "opacity"
            value: 0
        }
    }
}
