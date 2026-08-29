import QtQuick
import GlassOS

// Launch/running indicator shown under an app tile.
//   opening -> a shiny dot that blinks until the app's window is ready
//   active  -> the same shiny dot, now steady
Item {
    id: r
    property bool opening: false
    property bool active: false

    width: 7; height: 7
    visible: opening || active

    Rectangle {
        id: dot
        anchors.fill: parent
        radius: width / 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.98) }
            GradientStop { position: 1.0; color: Theme.aqua }
        }
        // tiny highlight so it reads as glass, not a flat LED
        Rectangle {
            x: parent.width * 0.18; y: parent.height * 0.12
            width: parent.width * 0.5; height: parent.height * 0.3
            radius: height / 2
            color: Qt.rgba(1, 1, 1, 0.9); opacity: 0.85
        }
    }

    SequentialAnimation {
        running: r.opening
        loops: Animation.Infinite
        alwaysRunToEnd: false
        NumberAnimation { target: dot; property: "opacity"; from: 1.0; to: 0.2; duration: 430; easing.type: Easing.InOutQuad }
        NumberAnimation { target: dot; property: "opacity"; from: 0.2; to: 1.0; duration: 430; easing.type: Easing.InOutQuad }
    }

    // when blinking stops, leave the dot fully lit (steady "running")
    onOpeningChanged: if (!opening) dot.opacity = 1.0
}
