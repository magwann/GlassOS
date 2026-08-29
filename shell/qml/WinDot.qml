import QtQuick
import GlassOS

// A glossy, "wet" traffic-light window control (red/yellow/green) — matches the
// shiny circle language used on the start orb and app tiles.
Item {
    id: d
    property color color1: "#ffffff"
    property color color2: "#cccccc"
    signal tapped()

    width: 16; height: 16

    Rectangle {
        id: body
        anchors.fill: parent
        radius: width / 2
        border.color: Qt.rgba(1, 1, 1, 0.6); border.width: 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: d.color1 }
            GradientStop { position: 1.0; color: d.color2 }
        }
        // specular wet shine
        Rectangle {
            x: parent.width * 0.24; y: parent.height * 0.14
            width: parent.width * 0.42; height: parent.height * 0.28
            radius: height / 2
            color: Qt.rgba(1, 1, 1, 0.85); opacity: 0.8
        }
        scale: ta.pressed ? 0.85 : (ta.containsMouse ? 1.14 : 1.0)
        Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }
    }

    MouseArea {
        id: ta
        anchors.fill: parent
        hoverEnabled: true
        onClicked: d.tapped()
    }
}
