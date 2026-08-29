import QtQuick
import QtQuick.Controls.Basic
import GlassOS

// The GlassOS launcher: search + app grid (square tiles) + user/power footer.
GlassPanel {
    id: root
    radius: Theme.rXl
    tint: Theme.glassDeep

    property bool shown: false
    property var wm: null
    signal appLaunched()

    visible: opacity > 0.01
    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.92
    transformOrigin: Item.BottomLeft
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    Behavior on scale   { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        // ---- search ----
        Rectangle {
            width: parent.width
            height: 44
            radius: height / 2
            color: Qt.rgba(1,1,1,0.28)
            border.color: Qt.rgba(1,1,1,0.5)
            border.width: 1

            Row {
                anchors.fill: parent
                anchors.leftMargin: 14
                spacing: 10
                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16; height: 16
                    source: "glyphs/search.svg"
                    sourceSize.width: 32; sourceSize.height: 32
                }
                TextField {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 40
                    placeholderText: "Search GlassOS…"
                    color: Theme.ink
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    background: Item {}
                }
            }
        }

        // ---- app grid ----
        GridView {
            id: grid
            width: parent.width
            height: parent.height - 44 - 48 - 28
            cellWidth: width / 4
            cellHeight: 96
            clip: false   // stencil clip renders black on virgl/GL-2.1
            model: Apps
            delegate: Item {
                required property string appId
                required property string name
                required property string glyph
                required property string tint
                required property string exec
                width: grid.cellWidth
                height: grid.cellHeight

                Column {
                    anchors.centerIn: parent
                    spacing: 7
                    AppTile {
                        anchors.horizontalCenter: parent.horizontalCenter
                        size: 52
                        glyph: parent.parent.glyph
                        tint: parent.parent.tint
                        onActivated: {
                            root.wm.open(parent.parent.appId, parent.parent.name, parent.parent.glyph, parent.parent.tint)
                            root.appLaunched()
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: parent.parent.name
                        color: Theme.inkInv
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        style: Text.Raised
                        styleColor: Qt.rgba(0,0.12,0.24,0.6)
                    }
                }
            }
        }

        // ---- footer ----
        Item {
            width: parent.width
            height: 40

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Rectangle {
                    width: 34; height: 34; radius: 17
                    anchors.verticalCenter: parent.verticalCenter
                    border.color: Qt.rgba(1,1,1,0.6); border.width: 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.sky }
                        GradientStop { position: 1.0; color: Theme.aquaDeep }
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "jack"
                    color: Theme.inkInv
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 34; height: 34; radius: 17
                color: powerHover.hovered ? Qt.rgba(1,0.47,0.47,0.5) : Qt.rgba(1,1,1,0.15)
                border.color: Qt.rgba(1,1,1,0.5); border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
                Image {
                    anchors.centerIn: parent
                    width: 18; height: 18
                    source: "glyphs/power.svg"
                    sourceSize.width: 36; sourceSize.height: 36
                }
                HoverHandler { id: powerHover }
                MouseArea { anchors.fill: parent; onClicked: Launcher.poweroff() }
            }
        }
    }
}
