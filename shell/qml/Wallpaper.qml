import QtQuick
import Qt5Compat.GraphicalEffects

// Abstract Frutiger Aero wallpaper: deep sky base + drifting colour blobs,
// a slow diagonal light sweep, and rising bokeh. All soft, so translucent
// glass panels layered on top read as glass without per-panel blur.
Item {
    id: root

    // base gradient (deep aqua sky)
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#9fe6ff" }
            GradientStop { position: 0.35; color: "#4bb6ef" }
            GradientStop { position: 0.7;  color: "#1f7fc9" }
            GradientStop { position: 1.0;  color: "#0a4f8f" }
        }
    }

    // ---- drifting colour blobs ----
    Component {
        id: blobComp
        Item {
            id: blob
            property color tint: "white"
            property real driftX: 60
            property real driftY: 40
            property int dur: 26000
            RadialGradient {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: blob.tint }
                    GradientStop { position: 0.68; color: "transparent" }
                }
            }
            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { from: blob.x; to: blob.x + blob.driftX; duration: blob.dur; easing.type: Easing.InOutSine }
                NumberAnimation { from: blob.x + blob.driftX; to: blob.x; duration: blob.dur; easing.type: Easing.InOutSine }
            }
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { from: blob.y; to: blob.y + blob.driftY; duration: blob.dur * 1.2; easing.type: Easing.InOutSine }
                NumberAnimation { from: blob.y + blob.driftY; to: blob.y; duration: blob.dur * 1.2; easing.type: Easing.InOutSine }
            }
        }
    }

    Item {
        id: blobLayer
        anchors.fill: parent
        opacity: 0.8

        Component.onCompleted: {
            const W = root.width, H = root.height;
            blobComp.createObject(blobLayer, { x: -W*0.15, y: -H*0.2, width: W*0.7, height: W*0.7,
                tint: Qt.rgba(0.48,0.89,0.58,0.85), driftX: W*0.06, driftY: H*0.05, dur: 26000 });
            blobComp.createObject(blobLayer, { x: W*0.55, y: H*0.02, width: W*0.65, height: W*0.65,
                tint: Qt.rgba(0.21,0.88,0.77,0.8), driftX: -W*0.05, driftY: H*0.06, dur: 32000 });
            blobComp.createObject(blobLayer, { x: W*0.2, y: H*0.55, width: W*0.6, height: W*0.6,
                tint: Qt.rgba(0.75,0.92,1.0,0.85), driftX: W*0.04, driftY: -H*0.05, dur: 30000 });
            blobComp.createObject(blobLayer, { x: W*0.6, y: H*0.6, width: W*0.5, height: W*0.5,
                tint: Qt.rgba(1.0,0.96,0.85,0.7), driftX: -W*0.04, driftY: -H*0.04, dur: 38000 });
        }
    }

    // ---- diagonal light sweep ----
    Rectangle {
        id: sweep
        width: parent.width * 1.6
        height: parent.height * 1.6
        x: -parent.width * 0.3
        y: -parent.height * 0.3
        rotation: 25
        opacity: 0.16
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.4; color: "transparent" }
            GradientStop { position: 0.5; color: Qt.rgba(1,1,1,0.9) }
            GradientStop { position: 0.6; color: "transparent" }
        }
        SequentialAnimation on x {
            loops: Animation.Infinite
            NumberAnimation { from: -parent.width * 0.6; to: parent.width * 0.3; duration: 14000; easing.type: Easing.Linear }
        }
    }

    // ---- rising bokeh ----
    Repeater {
        model: 14
        delegate: Rectangle {
            required property int index
            property real sz: 24 + (index * 37) % 150
            width: sz; height: sz
            radius: sz / 2
            x: ((index * 53) % 100) / 100 * root.width
            opacity: 0.5
            // soft glassy bubble look
            color: "transparent"
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1,1,1,0.85) }
                    GradientStop { position: 0.45; color: Qt.rgba(1,1,1,0.12) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
            SequentialAnimation on y {
                loops: Animation.Infinite
                PauseAnimation { duration: (index * 800) % 6000 }
                NumberAnimation {
                    from: root.height + parent.sz
                    to: -parent.sz
                    duration: 18000 + (index % 7) * 3000
                    easing.type: Easing.Linear
                }
            }
        }
    }

    // vignette
    RadialGradient {
        anchors.fill: parent
        horizontalRadius: parent.width * 0.75
        verticalRadius: parent.height * 0.75
        gradient: Gradient {
            GradientStop { position: 0.55; color: "transparent" }
            GradientStop { position: 1.0; color: Qt.rgba(0.015,0.09,0.19,0.35) }
        }
    }
}
