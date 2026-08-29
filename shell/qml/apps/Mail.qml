import QtQuick
import GlassOS

Item {
    id: mail
    property var msgs: [
        { from: "FreeBSD Foundation", subj: "Welcome to GlassOS", prev: "Thanks for trying the cleanest desktop…", c: "teal" },
        { from: "Aero Weekly",        subj: "Frutiger is back",   prev: "Gloss, glass, and light in 2026…",       c: "aqua" },
        { from: "jack",               subj: "Notes to self",      prev: "Ship the custom apps, fix the dock layer…", c: "violet" },
        { from: "Photos",             subj: "New album shared",   prev: "12 shiny new pictures in your gallery…",  c: "warm" }
    ]

    ListView {
        anchors.fill: parent
        clip: false
        spacing: 8
        model: mail.msgs.length
        delegate: Rectangle {
            required property int index
            width: ListView.view.width; height: 66
            radius: Theme.rMd
            color: mma.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)
            border.color: Theme.glassBorderLo; border.width: 1
            Row {
                anchors.fill: parent; anchors.margins: 12; spacing: 12
                Rectangle {
                    width: 42; height: 42; radius: 12
                    anchors.verticalCenter: parent.verticalCenter
                    border.color: Theme.glassBorderLo; border.width: 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.tileGradient(mail.msgs[index].c)[0] }
                        GradientStop { position: 1.0; color: Theme.tileGradient(mail.msgs[index].c)[1] }
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 66
                    spacing: 2
                    Text { text: mail.msgs[index].from; color: Theme.inkInv; font.pixelSize: 14; font.bold: true; font.family: Theme.fontFamily }
                    Text { text: mail.msgs[index].subj; color: Theme.inkInv; font.pixelSize: 13; font.family: Theme.fontFamily }
                    Text {
                        width: parent.width
                        text: mail.msgs[index].prev
                        color: Qt.rgba(1, 1, 1, 0.7); font.pixelSize: 12; font.family: Theme.fontFamily
                        elide: Text.ElideRight
                    }
                }
            }
            MouseArea { id: mma; anchors.fill: parent; hoverEnabled: true }
        }
    }
}
