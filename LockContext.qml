import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

Scope {
    id: root
    signal unlocked
    signal failed
    signal actionConfirmed

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property bool showSuccess: false

    onCurrentTextChanged: showFailure = false

    // TODO: maybe remove this now that i alr filmed? welp
    function stopRecording(): void {
        stopRecordings.command = ["sh", "-c", "kill $(cat /tmp/lock_recorder.pid) && rm /tmp/lock_recorder.pid"];
        stopRecordings.running = true;
    }

    Process {
        id: stopRecordings
        running: false
        onExited: running = false
    }

    function tryUnlock() {
        if (currentText === "")
            return;
        root.unlockInProgress = true;
        pam.start();
    }

    function confirmAction() {
        root.showSuccess = true;
        root.actionConfirmed();
    }

    PamContext {
        id: pam
        configDirectory: "pam"
        // TODO: maybe dont rely on the nodelay?
        config: "password.conf"

        onPamMessage: {
            if (this.responseRequired)
                this.respond(root.currentText);
        }

        onCompleted: result => {
            if (result == PamResult.Success) {
                root.showSuccess = true;
                successDelayTimer.start();
                console.log("yes");
            } else {
                root.currentText = "";
                root.showFailure = true;
                console.log("no");
                root.failed();
            }
            root.unlockInProgress = false;
        }
    }

    Timer {
        id: successDelayTimer
        interval: Config.shaderDelay + 1000
        onTriggered: {
            stopRecording();
            root.unlocked();
        }
    }
}
