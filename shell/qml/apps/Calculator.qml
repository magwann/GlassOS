import QtQuick
import GlassOS

// A from-scratch calculator — glossy glass keypad, real arithmetic.
Item {
    id: calc

    property string display: "0"
    property real acc: 0
    property string pendingOp: ""
    property bool fresh: true

    function digit(x) {
        if (fresh || display === "0") { display = x; fresh = false }
        else display += x
    }
    function dot() { if (display.indexOf(".") < 0) { display += "."; fresh = false } }
    function clearAll() { display = "0"; acc = 0; pendingOp = ""; fresh = true }
    function backspace() {
        if (display.length <= 1 || (display.length === 2 && display.charAt(0) === "-")) { display = "0"; fresh = true }
        else display = display.slice(0, -1)
    }
    function negate() { if (display !== "0") display = String(-parseFloat(display)) }
    function percent() { display = String(parseFloat(display) / 100); fresh = true }
    function setOp(op) {
        if (pendingOp !== "" && !fresh) equals()
        acc = parseFloat(display)
        pendingOp = op; fresh = true
    }
    function equals() {
        if (pendingOp === "") return
        var b = parseFloat(display), r = acc
        if (pendingOp === "+") r = acc + b
        else if (pendingOp === "−") r = acc - b
        else if (pendingOp === "×") r = acc * b
        else if (pendingOp === "÷") r = (b !== 0 ? acc / b : NaN)
        display = isFinite(r) ? String(parseFloat(r.toPrecision(12))) : "Error"
        pendingOp = ""; fresh = true
    }
    function press(m) {
        if (m.k === "d") digit(m.t)
        else if (m.k === "dot") dot()
        else if (m.k === "clear") clearAll()
        else if (m.k === "neg") negate()
        else if (m.k === "pct") percent()
        else if (m.k === "op") setOp(m.t)
        else if (m.k === "eq") equals()
        else if (m.k === "back") backspace()
    }

    Column {
        anchors.fill: parent
        spacing: 12

        Rectangle {
            width: parent.width; height: 74
            radius: Theme.rMd
            color: Qt.rgba(0, 0.08, 0.16, 0.35)
            border.color: Theme.glassBorderLo; border.width: 1
            Text {
                anchors { right: parent.right; rightMargin: 18; verticalCenter: parent.verticalCenter }
                text: calc.display
                color: Theme.inkInv
                font.family: Theme.fontFamily; font.pixelSize: 36; font.bold: true
                elide: Text.ElideLeft
                width: parent.width - 36
                horizontalAlignment: Text.AlignRight
            }
        }

        Grid {
            id: pad
            width: parent.width
            height: parent.height - 74 - 12
            columns: 4
            rowSpacing: 9; columnSpacing: 9
            property real cw: (width - columnSpacing * 3) / 4
            property real ch: (height - rowSpacing * 4) / 5

            Repeater {
                model: [
                    { t: "C", k: "clear", a: "fn" }, { t: "±", k: "neg", a: "fn" }, { t: "%", k: "pct", a: "fn" }, { t: "÷", k: "op", a: "op" },
                    { t: "7", k: "d", a: "d" }, { t: "8", k: "d", a: "d" }, { t: "9", k: "d", a: "d" }, { t: "×", k: "op", a: "op" },
                    { t: "4", k: "d", a: "d" }, { t: "5", k: "d", a: "d" }, { t: "6", k: "d", a: "d" }, { t: "−", k: "op", a: "op" },
                    { t: "1", k: "d", a: "d" }, { t: "2", k: "d", a: "d" }, { t: "3", k: "d", a: "d" }, { t: "+", k: "op", a: "op" },
                    { t: "0", k: "d", a: "d" }, { t: ".", k: "dot", a: "d" }, { t: "⌫", k: "back", a: "fn" }, { t: "=", k: "eq", a: "eq" }
                ]
                delegate: Rectangle {
                    required property var modelData
                    width: pad.cw; height: pad.ch
                    radius: Theme.rMd
                    border.color: Theme.glassBorderLo; border.width: 1
                    gradient: Gradient {
                        GradientStop { position: 0.0
                            color: modelData.a === "eq" ? Qt.rgba(0.25, 0.74, 0.96, 0.85)
                                 : modelData.a === "op" ? Qt.rgba(1, 1, 1, 0.30)
                                 : Qt.rgba(1, 1, 1, 0.16) }
                        GradientStop { position: 1.0
                            color: modelData.a === "eq" ? Qt.rgba(0.04, 0.52, 0.79, 0.85)
                                 : modelData.a === "op" ? Qt.rgba(1, 1, 1, 0.12)
                                 : Qt.rgba(1, 1, 1, 0.05) }
                    }
                    // gloss
                    Rectangle {
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
                        height: parent.height * 0.5; radius: parent.radius
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.45) }
                            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.02) }
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: modelData.t
                        color: Theme.inkInv
                        font.family: Theme.fontFamily; font.pixelSize: 22; font.bold: true
                    }
                    scale: km.pressed ? 0.92 : 1.0
                    Behavior on scale { NumberAnimation { duration: 80 } }
                    MouseArea { id: km; anchors.fill: parent; onClicked: calc.press(parent.modelData) }
                }
            }
        }
    }
}
