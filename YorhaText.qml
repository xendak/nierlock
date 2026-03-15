import QtQuick
import "."

Item {
    id: root

    property string text: ""

    // Appearance
    property color  color:         Config.yorhaDark
    property int    fontSize:      Config.fontHeader
    property bool   bold:          false
    property string fontFamily:    Config.mainFont
    property real   letterSpacing: 0
    property alias  opacityMain:   mainText.opacity

   // Shadow
    property bool  showShadow:   true
    property real  shadowOffset: 3
    property color shadowColor: Qt.rgba(color.r, color.g, color.b, 0.30)

    // Typing
    property bool  typeOnAppear: false
    property int   typeInterval: 55
    property int   typeDelay:    0

    // Glitch
    property bool  glitchEnabled:    false
    property int   glitchRate:       2
    property real  glitchMaxOfs:     6
    property real  glitchSubChance:  0.35

    // Sound
    property bool   typeSoundEnabled: false
    property string typeSound:        "input"
    property int    typeSoundRate:    1

    // Diamond shaped cursor
    property real   cursorSize:  0
    readonly property real _cursorSize: cursorSize > 0 ? cursorSize : Math.round(fontSize * 0.55)


    // Anchors

    signal typingStarted
    signal typingFinished

    function startTyping() {
        _charCount   = 0
        _glitchOfs   = 0
        _glitchChar  = ""
        _glitchIndex = -1
        _cursorOn    = true
        _typingDone  = false
        _tickCount   = 0
        if (typeDelay > 0)
            _delayTimer.restart()
        else
            _typeTimer.restart()
    }

    implicitWidth:  mainText.implicitWidth
                  + (showShadow ? shadowOffset : 0)
                  + (!_typingDone ? _cursorSize + 4 : 0)
    implicitHeight: mainText.implicitHeight + (showShadow ? shadowOffset : 0)

    property int    _charCount:  typeOnAppear ? 0 : text.length
    property real   _glitchOfs:  0
    property string _glitchChar: ""
    property int    _glitchIndex: -1
    property bool   _cursorOn:   false
    property int    _tickCount:  0
    property bool   _typingDone: !typeOnAppear

    readonly property string _displayText: {
        if (_typingDone) return text

        let visible = text.substring(0, _charCount)
        if (glitchEnabled && _glitchIndex >= 0 && _glitchIndex < _charCount) {
            visible = visible.substring(0, _glitchIndex)
                    + _glitchChar
                    + visible.substring(_glitchIndex + 1)
        }
        return visible
    }

    // Shadow First
    Text {
        id: shadowText
        text:               root._displayText
        font.pixelSize:     root.fontSize
        font.bold:          root.bold
        font.family:        root.fontFamily
        font.letterSpacing: root.letterSpacing
        color:              root.shadowColor
        x:                  root.shadowOffset + root._glitchOfs * 0.4
        y:                  root.shadowOffset
        visible:            root.showShadow
    }

    // Then text
    Text {
        id: mainText
        text:               root._displayText
        font.pixelSize:     root.fontSize
        font.bold:          root.bold
        font.family:        root.fontFamily
        font.letterSpacing: root.letterSpacing
        color:              root.color
        x:                  root._glitchOfs
    }

    // Cursor
    Rectangle {
        id: diamondCursor

        width:    root._cursorSize
        height:   root._cursorSize
        rotation: 45
        color:    root.color

        x: mainText.x + mainText.implicitWidth + 4
        y: (mainText.implicitHeight - root._cursorSize) / 2

        visible: !root._typingDone && root._cursorOn

        SequentialAnimation on opacity {
            running:  !root._typingDone
            loops:    Animation.Infinite
            NumberAnimation { from: 1.0; to: 0.0; duration: 450 }
            NumberAnimation { from: 0.0; to: 1.0; duration: 450 }
        }
    }

    Timer {
        id: _delayTimer
        interval: root.typeDelay
        repeat:   false
        onTriggered: _typeTimer.restart()
    }

    Timer {
        id: _typeTimer
        interval: root.typeInterval
        repeat:   true

        onRunningChanged: if (running) root.typingStarted()

        onTriggered: {
            root._tickCount++

            // Glitching idea, based on shader idr where :')
            if (root.glitchEnabled && root._tickCount % root.glitchRate === 0) {
                let dir = (Math.random() > 0.5 ? 1 : -1)
                root._glitchOfs = dir * Math.random() * root.glitchMaxOfs

                if (Math.random() < root.glitchSubChance && root._charCount > 1) {
                    let idx  = Math.floor(Math.random() * (root._charCount - 1))
                    let pool = "█▓▒░│┤╡╢╖╕╣║╗╝╜╛┐└╒╓╫╪┘┌"
                    root._glitchChar  = pool[Math.floor(Math.random() * pool.length)]
                    root._glitchIndex = idx
                } else {
                    root._glitchIndex = -1
                }
                _glitchClearTimer.restart()
            } else {
                root._glitchOfs = 0
            }

            // move forward
            if (root._charCount < root.text.length) {
                root._charCount++
                if (root.typeSoundEnabled && root._charCount % root.typeSoundRate === 0)
                    if (typeof soundEngine !== 'undefined')
                        soundEngine.play(root.typeSound)
            } else {
                // destroy
                running               = false
                _glitchClearTimer.stop()
                root._glitchOfs       = 0
                root._glitchIndex     = -1
                root._glitchChar      = ""
                root._cursorOn        = false
                root._typingDone      = true
               root.typingFinished()
            }
        }
    }

    Timer {
        id: _glitchClearTimer
        interval: root.typeInterval * 0.6
        repeat:   false
        onTriggered: { root._glitchOfs = 0; root._glitchIndex = -1 }
    }

    Component.onCompleted: {
        if (typeOnAppear) startTyping()
    }
}
