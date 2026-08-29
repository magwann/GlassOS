import QtQuick
import QtQuick.Controls.Basic
import GlassOS

// A from-scratch terminal: type a command, press Enter, it runs via Launcher.run
// and prints the output. `clear` wipes the scrollback.
Item {
    id: term
    property string buffer: "GlassOS 1.0 — FreeBSD glass terminal\nType a command and press Enter.  ('clear' to reset)\n\n"

    Column {
        anchors.fill: parent
        spacing: 8

        Rectangle {
            width: parent.width
            height: parent.height - 46
            radius: Theme.rMd
            color: Qt.rgba(0.02, 0.10, 0.17, 0.55)
            border.color: Theme.glassBorderLo; border.width: 1

            Flickable {
                id: flick
                anchors.fill: parent
                anchors.margins: 12
                contentWidth: width
                contentHeight: outText.height
                clip: false
                Text {
                    id: outText
                    width: flick.width
                    text: term.buffer
                    color: "#d7fff4"
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    textFormat: Text.PlainText
                    font.family: "monospace"; font.pixelSize: 13
                    onHeightChanged: flick.contentY = Math.max(0, height - flick.height)
                }
            }
        }

        Row {
            width: parent.width; height: 38; spacing: 8
            Text {
                text: "$"; color: Theme.teal
                font.family: "monospace"; font.pixelSize: 16; font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
            Rectangle {
                width: parent.width - 24; height: 38; radius: Theme.rMd
                color: Qt.rgba(1, 1, 1, 0.14)
                border.color: Theme.glassBorderLo; border.width: 1
                TextField {
                    id: input
                    anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.inkInv
                    font.family: "monospace"; font.pixelSize: 14
                    placeholderText: "e.g. uname -a"
                    background: Item {}
                    onAccepted: {
                        var cmd = text
                        if (cmd.trim().length === 0) return
                        if (cmd.trim() === "clear") { term.buffer = ""; text = ""; return }
                        term.buffer += "$ " + cmd + "\n"
                        var out = Launcher.run(cmd)
                        if (out.length > 0)
                            term.buffer += out + (out.charAt(out.length - 1) === "\n" ? "" : "\n")
                        text = ""
                    }
                }
            }
        }
    }
}
