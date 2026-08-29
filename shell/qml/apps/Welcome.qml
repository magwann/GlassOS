import QtQuick
import GlassOS

Item {
    Column {
        anchors.centerIn: parent
        width: parent.width - 40
        spacing: 16
        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 72; height: 72
            source: "../glyphs/sprout.svg"
            sourceSize.width: 144; sourceSize.height: 144
            smooth: true
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Welcome to GlassOS"
            color: Theme.inkInv
            font.family: Theme.fontFamily; font.pixelSize: 26; font.bold: true
            style: Text.Raised; styleColor: Qt.rgba(0, 0.12, 0.24, 0.6)
        }
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: "A clean, transparent desktop — Frutiger Aero, reborn for 2026. "
                + "Everything you see is live glass. Every app here is custom-built "
                + "from scratch and opens right in the shell."
            color: Qt.rgba(1, 1, 1, 0.85)
            font.family: Theme.fontFamily; font.pixelSize: 14
        }
    }
}
