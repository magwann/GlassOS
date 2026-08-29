import QtQuick
import GlassOS

// A from-scratch photo gallery: a light-table of glossy tiles, tap to open a
// lightbox, tap the backdrop to go back.
Item {
    id: ph
    property int selected: -1
    property var pics: [
        { name: "Harbour Dawn",  c1: "#a6ecff", c2: "#0a4f8f" },
        { name: "Reef Glow",     c1: "#35e0c4", c2: "#0a7f7f" },
        { name: "Sky Meadow",    c1: "#7be495", c2: "#26b552" },
        { name: "Amber Coast",   c1: "#fff6d8", c2: "#f2a51c" },
        { name: "Violet Tide",   c1: "#b4a0ff", c2: "#6a4fd8" },
        { name: "Ice Bloom",     c1: "#bfeafe", c2: "#3fbdf6" },
        { name: "Deep Current",  c1: "#3fbdf6", c2: "#08324f" },
        { name: "Lagoon",        c1: "#35e0c4", c2: "#3fbdf6" },
        { name: "Sunset Glass",  c1: "#ffd36b", c2: "#e5443b" },
        { name: "Aurora",        c1: "#7be495", c2: "#b4a0ff" },
        { name: "Mist",          c1: "#f5ffff", c2: "#bfeafe" },
        { name: "Nightfall",     c1: "#123f57", c2: "#03121d" }
    ]

    GridView {
        id: gv
        anchors.fill: parent
        cellWidth: width / 4
        cellHeight: cellWidth * 0.8
        clip: false
        model: ph.pics.length
        delegate: Item {
            required property int index
            width: gv.cellWidth; height: gv.cellHeight
            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 10; height: parent.height - 10
                radius: Theme.rMd
                border.color: Theme.glassBorderLo; border.width: 1
                gradient: Gradient {
                    GradientStop { position: 0.0; color: ph.pics[index].c1 }
                    GradientStop { position: 1.0; color: ph.pics[index].c2 }
                }
                Rectangle {
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
                    height: parent.height * 0.42; radius: parent.radius
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.4) }
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.02) }
                    }
                }
                scale: pma.containsMouse ? 1.05 : 1.0
                Behavior on scale { NumberAnimation { duration: 120 } }
                MouseArea { id: pma; anchors.fill: parent; hoverEnabled: true; onClicked: ph.selected = index }
            }
        }
    }

    // lightbox
    Rectangle {
        anchors.fill: parent
        visible: ph.selected >= 0
        color: Qt.rgba(0, 0.05, 0.1, 0.78)
        radius: Theme.rMd
        MouseArea { anchors.fill: parent; onClicked: ph.selected = -1 }
        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.82; height: parent.height * 0.82
            radius: Theme.rLg
            border.color: Theme.glassBorder; border.width: 1
            gradient: Gradient {
                GradientStop { position: 0.0; color: ph.selected >= 0 ? ph.pics[ph.selected].c1 : "#000000" }
                GradientStop { position: 1.0; color: ph.selected >= 0 ? ph.pics[ph.selected].c2 : "#000000" }
            }
            Text {
                anchors { bottom: parent.bottom; bottomMargin: 16; horizontalCenter: parent.horizontalCenter }
                text: ph.selected >= 0 ? ph.pics[ph.selected].name : ""
                color: "white"; font.pixelSize: 18; font.bold: true; font.family: Theme.fontFamily
                style: Text.Raised; styleColor: Qt.rgba(0, 0, 0, 0.5)
            }
        }
    }
}
