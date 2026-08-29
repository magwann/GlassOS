import QtQuick
import GlassOS

Item {
    id: filesApp
    property var items: [
        { n: "Documents",    g: "files",    t: "teal" },
        { n: "Downloads",    g: "files",    t: "aqua" },
        { n: "Pictures",     g: "photos",   t: "warm" },
        { n: "Music",        g: "music",    t: "violet" },
        { n: "Projects",     g: "files",    t: "leaf" },
        { n: "Videos",       g: "photos",   t: "aqua" },
        { n: "Desktop",      g: "files",    t: "teal" },
        { n: "freebsd.conf", g: "terminal", t: "leaf" }
    ]

    GridView {
        anchors.fill: parent
        cellWidth: width / 4
        cellHeight: 108
        clip: false
        model: filesApp.items.length
        delegate: Item {
            required property int index
            width: GridView.view.cellWidth; height: GridView.view.cellHeight
            Column {
                anchors.centerIn: parent
                spacing: 8
                AppTile {
                    anchors.horizontalCenter: parent.horizontalCenter
                    size: 54
                    glyph: filesApp.items[index].g
                    tint: filesApp.items[index].t
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: filesApp.items[index].n
                    color: Theme.inkInv
                    font.family: Theme.fontFamily; font.pixelSize: 12
                    style: Text.Raised; styleColor: Qt.rgba(0, 0.12, 0.24, 0.6)
                }
            }
        }
    }
}
