import QtQuick
import Qt5Compat.GraphicalEffects
import GlassOS

// Reusable frosted-glass surface: a blurred slice of the wallpaper behind a
// translucent tint, with a glossy top sheen and a light border.
// Set `backdrop` to the wallpaper item to get real acrylic blur.
Item {
    id: root
    property real radius: Theme.rLg
    property color tint: Theme.glassDeep
    property Item backdrop: null
    default property alias content: contentArea.data

    // ---- frosted backdrop (blurred wallpaper behind the glass) ----
    // Panels are direct children of the window and the wallpaper fills it at
    // (0,0), so the panel's (x,y) equals its position in wallpaper coords.
    Item {
        anchors.fill: parent
        visible: root.backdrop !== null

        ShaderEffectSource {
            id: shot
            anchors.fill: parent
            sourceItem: root.backdrop
            sourceRect: Qt.rect(root.x, root.y, root.width, root.height)
            live: true
            hideSource: false
        }
        FastBlur {
            id: fb
            anchors.fill: parent
            source: shot
            radius: 64
            visible: false
        }
        Rectangle {
            id: mask
            anchors.fill: parent
            radius: root.radius
            visible: false
        }
        OpacityMask {
            anchors.fill: parent
            source: fb
            maskSource: mask
        }
    }

    // ---- glass tint + gloss + border ----
    Rectangle {
        id: base
        anchors.fill: parent
        radius: root.radius
        color: root.tint
        border.color: Theme.glassBorder
        border.width: 1
        clip: true

        // top gloss sheen
        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: parent.height * 0.5
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.glossTop }
                GradientStop { position: 1.0; color: Theme.glossMid }
            }
        }
        // inner top highlight line
        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
            height: 1
            color: Qt.rgba(1, 1, 1, 0.7)
        }

        Item {
            id: contentArea
            anchors.fill: parent
        }
    }
}
