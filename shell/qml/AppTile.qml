import QtQuick
import GlassOS

// THE canonical app icon shape for all of GlassOS: a rounded square with a
// glossy top highlight and a centered glyph. Nothing ever pokes outside it.
// NOTE: no `clip` — stencil clipping renders black on virgl/GL-2.1; the gloss
// is rounded to fit instead.
Item {
    id: root
    property string glyph: "files"
    property string tint: "aqua"
    property real size: 58
    signal activated()

    width: size
    height: size

    Rectangle {
        id: tile
        anchors.fill: parent
        radius: size * 0.27
        border.color: Theme.glassBorderLo
        border.width: 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.tileGradient(root.tint)[0] }
            GradientStop { position: 1.0; color: Theme.tileGradient(root.tint)[1] }
        }

        // glossy top half
        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
            height: parent.height * 0.5
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.6) }
                GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.05) }
            }
        }

        // glyph
        Image {
            anchors.centerIn: parent
            width: parent.width * 0.52
            height: parent.height * 0.52
            source: "glyphs/" + root.glyph + ".svg"
            sourceSize.width: width * 2
            sourceSize.height: height * 2
            smooth: true
        }
    }

    scale: tapArea.pressed ? 0.93 : 1.0
    Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }

    MouseArea {
        id: tapArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.activated()
    }
}
