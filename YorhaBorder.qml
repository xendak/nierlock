import QtQuick
import "Config.qml"

ListView {
    id: root

    // Default properties
    property string symbol: "▼"
    property color symbolColor: Config.yorhaBeige
    property real symbolOpacity: 0.2
    property int symbolSize: 8
    property real spacingWidth: 14

    width: parent.width
    height: symbolSize + 4
    orientation: ListView.Horizontal
    interactive: false

    model: Math.ceil(width / spacingWidth)

    delegate: Text {
        text: root.symbol
        color: root.symbolColor
        font.pixelSize: root.symbolSize
        opacity: root.symbolOpacity
        width: root.spacingWidth
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
