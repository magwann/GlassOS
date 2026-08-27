import QtQuick
import GlassOS

// Reusable translucent glass surface with a glossy top sheen + light border.
// Content goes inside via default property (children are placed in `content`).
Item {
    id: root
    property real radius: Theme.rLg
    property color tint: Theme.glassDeep
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
