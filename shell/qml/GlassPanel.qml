import QtQuick
import GlassOS

// Translucent glass surface: a see-through tint with a glossy top sheen and a
// light border. (Real backdrop blur is disabled — it renders as black boxes on
// virtio-GPU. The soft aurora wallpaper already reads as glass through the tint.)
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
