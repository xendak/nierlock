import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool bgmEnabled: true
    property real bgmVolume: Config.bgmVolume
    property real sfxVolume: Config.sfxVolume

    function play(name) {
        let path = Config.soundsPath + name + ".ogg";
        console.log("PLAYING: " + path);
        sfxProc.command = ["pw-play", "--volume", sfxVolume.toString(), path];
        sfxProc.startDetached();
    }

    function playBgm() {
        bgmEnabled = true;
        if (!bgmProc.running)
            bgmProc.running = true;
    }

    function stopBgm() {
        bgmEnabled = false;
        bgmProc.running = false;
        bgmRetryTimer.stop();
    }

    Process {
        id: sfxProc
    }

    Process {
        id: bgmProc
        command: ["pw-play", "--volume", bgmVolume.toString(), Config.bgmFile]

        onRunningChanged: {
            if (!running && bgmEnabled) {
                bgmRetryTimer.start();
            }
        }
    }

    Timer {
        id: bgmRetryTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (root.bgmEnabled) {
                bgmProc.running = true;
            }
        }
    }

    onBgmEnabledChanged: {
        if (bgmEnabled) {
            bgmProc.running = true;
        } else {
            bgmProc.running = false;
            bgmRetryTimer.stop();
        }
    }

    Component.onCompleted: {
        if (bgmEnabled)
            bgmProc.running = true;
    }
}
