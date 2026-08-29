import QtQuick
import GlassOS

// A from-scratch music player: album art, transport controls, seekable
// progress and a playlist. Playback is simulated (no external player), but the
// controls, seeking and track switching all work.
Item {
    id: music

    property int idx: 0
    property bool playing: false
    property real pos: 0
    property var tracks: [
        { title: "Aqua Drift",   artist: "Frutiger",    len: 212, c1: "#3fbdf6", c2: "#0a84c9" },
        { title: "Glass Bloom",  artist: "Aero",        len: 184, c1: "#35e0c4", c2: "#0a7f7f" },
        { title: "Sunlit Water", artist: "Reflections", len: 242, c1: "#b4a0ff", c2: "#6a4fd8" },
        { title: "Bubble Field", artist: "GlassOS",     len: 167, c1: "#7be495", c2: "#26b552" }
    ]

    function cur() { return tracks[idx] }
    function fmt(s) { s = Math.floor(s); var m = Math.floor(s / 60), r = s % 60; return m + ":" + (r < 10 ? "0" : "") + r }
    function next() { idx = (idx + 1) % tracks.length; pos = 0 }
    function prev() { if (pos > 3) { pos = 0; return } idx = (idx - 1 + tracks.length) % tracks.length; pos = 0 }

    Timer {
        interval: 1000; running: music.playing; repeat: true
        onTriggered: { music.pos += 1; if (music.pos >= music.cur().len) music.next() }
    }

    Row {
        anchors.fill: parent
        spacing: 18

        // album art
        Rectangle {
            width: Math.min(parent.height, parent.width * 0.42); height: width
            radius: Theme.rLg
            border.color: Theme.glassBorderLo; border.width: 1
            gradient: Gradient {
                GradientStop { position: 0.0; color: music.cur().c1 }
                GradientStop { position: 1.0; color: music.cur().c2 }
            }
            Rectangle {
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
                height: parent.height * 0.5; radius: parent.radius
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.55) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.03) }
                }
            }
            Image {
                anchors.centerIn: parent
                width: parent.width * 0.4; height: width
                source: "../glyphs/music.svg"
                sourceSize.width: 160; sourceSize.height: 160
                smooth: true
            }
        }

        // info + controls + playlist
        Column {
            width: parent.width - Math.min(parent.height, parent.width * 0.42) - 18
            height: parent.height
            spacing: 10

            Text { text: music.cur().title; color: Theme.inkInv; font.family: Theme.fontFamily; font.pixelSize: 22; font.bold: true }
            Text { text: music.cur().artist; color: Qt.rgba(1, 1, 1, 0.82); font.family: Theme.fontFamily; font.pixelSize: 14 }

            // seek bar
            Item {
                width: parent.width; height: 18
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width; height: 6; radius: 3
                    color: Qt.rgba(1, 1, 1, 0.2)
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * (music.pos / music.cur().len); height: 6; radius: 3
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Theme.teal }
                        GradientStop { position: 1.0; color: Theme.aqua }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: function (mouse) { music.pos = (mouse.x / width) * music.cur().len }
                }
            }
            Item {
                width: parent.width; height: 14
                Text { anchors.left: parent.left; text: music.fmt(music.pos); color: Qt.rgba(1, 1, 1, 0.8); font.pixelSize: 12; font.family: Theme.fontFamily }
                Text { anchors.right: parent.right; text: music.fmt(music.cur().len); color: Qt.rgba(1, 1, 1, 0.8); font.pixelSize: 12; font.family: Theme.fontFamily }
            }

            // transport
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                MusicBtn { glyphText: "◀◀"; onTapped: music.prev() }
                MusicBtn { glyphText: music.playing ? "II" : "▶"; big: true; onTapped: music.playing = !music.playing }
                MusicBtn { glyphText: "▶▶"; onTapped: music.next() }
            }

            // playlist
            Column {
                width: parent.width
                spacing: 4
                Repeater {
                    model: music.tracks.length
                    delegate: Rectangle {
                        required property int index
                        width: parent.width; height: 30; radius: 8
                        color: index === music.idx ? Qt.rgba(1, 1, 1, 0.18)
                             : (rowMa.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")
                        Text {
                            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                            text: (index + 1) + ".  " + music.tracks[index].title + " — " + music.tracks[index].artist
                            color: Theme.inkInv; font.pixelSize: 12; font.family: Theme.fontFamily
                        }
                        MouseArea {
                            id: rowMa
                            anchors.fill: parent; hoverEnabled: true
                            onClicked: { music.idx = index; music.pos = 0; music.playing = true }
                        }
                    }
                }
            }
        }
    }

    component MusicBtn: Rectangle {
        id: mbtn
        property string glyphText: ""
        property bool big: false
        signal tapped()
        width: big ? 56 : 42; height: big ? 56 : 42; radius: width / 2
        border.color: Theme.glassBorderLo; border.width: 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.30) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.10) }
        }
        scale: mb.pressed ? 0.9 : 1.0
        Behavior on scale { NumberAnimation { duration: 90 } }
        Text {
            anchors.centerIn: parent
            text: mbtn.glyphText; color: Theme.inkInv
            font.pixelSize: mbtn.big ? 20 : 14; font.bold: true
        }
        MouseArea { id: mb; anchors.fill: parent; onClicked: mbtn.tapped() }
    }
}
