pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root

    // Sounds
    readonly property string soundsPath: Quickshell.shellDir + "/sounds/"
    readonly property string bgmFile: soundsPath + "Significance.mp3"
    readonly property real bgmVolume: 1.0
    readonly property real sfxVolume: 0.7

    // Animations
    readonly property int shaderDelay: 700
    readonly property int glitchLines: 8

    // Resolution
    readonly property int resolution: Screen.height >= 1440 ? 1 : 0

    // Colors
    readonly property color yorhaBeige: "#bab5a1"
    readonly property color yorhaDark: "#454138"
    readonly property color yorhaBlack: "#1a1814"
    readonly property color yorhaGreen: "#578D4E"
    readonly property color yorhaRed: "#ab4642"

    // from Nier's UI blogpost
    readonly property color yorhaSystem: "#746e61"
    readonly property color yorhaAttack: "#b69581"
    readonly property color yorhaDefense: "#bba891"
    readonly property color yorhaSupport: "#e4d8ac"
    readonly property color yorhaHacking: "#e5e1d3"

    // Mission
    readonly property var missionLocations: ["CITY RUINS [SECTOR 0-1]", "DESERT ZONE [ZONE C]", "FOREST KINGDOM", "ABANDONED FACTORY", "COPIED CITY", "BUNKER: HANGAR"]
    // TODO
    readonly property color todoDone: yorhaGreen
    readonly property color todoPending: yorhaRed
    readonly property string todoPath: Quickshell.env("HOME") + "/Documents/Notes/TODO.md"

    // Fonts
    readonly property string mainFont: "FOT Rodin Pro"
    readonly property string monoFont: "FOT Rodin Pro"

    // Sizes
    readonly property int barHeight: resolution === 1 ? 70 : 55
    readonly property int fontSmall: resolution === 1 ? 16 : 13
    readonly property int fontHeader: resolution === 1 ? 22 : 18
    readonly property int fontMedium: resolution === 1 ? 36 : 28
    readonly property int fontBig: resolution === 1 ? 72 : 56
    readonly property int fontLogin: resolution === 1 ? 48 : 36
    readonly property int marginLarge: resolution === 1 ? 80 : 50
    readonly property int marginMedium: resolution === 1 ? 50 : 30
    readonly property int spinnerSize: resolution === 1 ? 200 : 150
    readonly property int authWidth: resolution === 1 ? 500 : 400
    readonly property int statusWidth: resolution === 1 ? 480 : 380
}
