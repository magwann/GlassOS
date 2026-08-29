import QtQuick
import GlassOS

// Translucent glass surface with a glossy top sheen and a light border.
// NOTE: no `clip` — stencil clipping renders as black boxes on the virgl/ANGLE
// OpenGL-2.1 stack used by virtio-GPU. The gloss is rounded to fit instead.
Item {
    id: root
    property real radius: Theme.rLg
    property color tint: Theme.glassDeep
    property Item backdrop: null   // kept for API compatibility; unused
    default property alias content: contentArea.data

    Rectangle {
        id: base
        anchors.fill: parent
        radius: root.radius
        color: root.tint
        border.color: Theme.glassBorder
        border.width: 1

        // top gloss sheen (rounded to match the panel instead of clipping)
        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
            height: parent.height * 0.5
            radius: root.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.glossTop }
                GradientStop { position: 1.0; color: Theme.glossMid }
            }
        }

        Item {
            id: contentArea
            anchors.fill: parent
        }
    }
}
