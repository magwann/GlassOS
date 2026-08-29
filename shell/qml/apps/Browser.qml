import QtQuick
import QtQuick.Controls.Basic
import GlassOS

Item {
    id: br
    property string url: "glass://home"

    Column {
        anchors.fill: parent
        spacing: 10

        Row {
            width: parent.width; height: 40; spacing: 8
            NavBtn { glyphText: "‹" }
            NavBtn { glyphText: "›" }
            NavBtn { glyphText: "⟳" }
            Rectangle {
                width: parent.width - 3 * 40 - 3 * 8; height: 40; radius: 20
                color: Qt.rgba(1, 1, 1, 0.22)
                border.color: Theme.glassBorderLo; border.width: 1
                TextField {
                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter
                    text: br.url
                    color: Theme.ink
                    font.family: Theme.fontFamily; font.pixelSize: 14
                    background: Item {}
                    onAccepted: br.url = text
                }
            }
        }

        Rectangle {
            width: parent.width; height: parent.height - 50
            radius: Theme.rMd
            color: Qt.rgba(1, 1, 1, 0.14)
            border.color: Theme.glassBorderLo; border.width: 1
            Column {
                anchors.centerIn: parent
                width: parent.width - 60
                spacing: 12
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 60; height: 60
                    source: "../glyphs/browser.svg"
                    sourceSize.width: 120; sourceSize.height: 120
                    smooth: true
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Aqua Web"
                    color: Theme.inkInv
                    font.family: Theme.fontFamily; font.pixelSize: 22; font.bold: true
                }
                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "A glassy browser shell — tabs as squircle chips, translucent chrome, "
                        + "and the page glowing through the glass."
                    color: Qt.rgba(1, 1, 1, 0.82)
                    font.family: Theme.fontFamily; font.pixelSize: 13
                }
            }
        }
    }

    component NavBtn: Rectangle {
        id: nb
        property string glyphText: ""
        width: 40; height: 40; radius: 12
        color: nbma.containsMouse ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, 0.10)
        border.color: Theme.glassBorderLo; border.width: 1
        Behavior on color { ColorAnimation { duration: 120 } }
        Text { anchors.centerIn: parent; text: nb.glyphText; color: Theme.inkInv; font.pixelSize: 18; font.bold: true }
        MouseArea { id: nbma; anchors.fill: parent; hoverEnabled: true }
    }
}
