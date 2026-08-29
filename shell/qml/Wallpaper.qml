import QtQuick
import Qt5Compat.GraphicalEffects

// Abstract Frutiger Aero wallpaper. All geometry binds to the live size so it
// works at any resolution (the old version sized blobs once at startup when the
// window was still 0x0, so they never appeared).
Item {
    id: root

    // deep sky base gradient (darkens to "night glass" in dark mode)
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0;  color: Theme.wallTop }
            GradientStop { position: 0.40; color: Theme.wallMid1 }
            GradientStop { position: 0.75; color: Theme.wallMid2 }
            GradientStop { position: 1.0;  color: Theme.wallBottom }
        }
    }

    // ---- drifting aurora blobs (soft, glowy) ----
    Item {
        id: blobs
        anchors.fill: parent
        opacity: Theme.blobOpacity

        Repeater {
            model: ListModel {
                ListElement { xf: 0.14; yf: 0.16; sf: 0.60; col: "#7be495"; dur: 9000 }
                ListElement { xf: 0.86; yf: 0.20; sf: 0.66; col: "#35e0c4"; dur: 11000 }
                ListElement { xf: 0.46; yf: 0.86; sf: 0.70; col: "#bfeafe"; dur: 10000 }
                ListElement { xf: 0.82; yf: 0.92; sf: 0.52; col: "#fff2c8"; dur: 13000 }
                ListElement { xf: 0.08; yf: 0.72; sf: 0.48; col: "#5ad2ff"; dur: 12000 }
            }
            delegate: Item {
                id: blob
                required property real xf
                required property real yf
                required property real sf
                required property color col
                required property int  dur
                width: sf * root.width
                height: width
                x: xf * root.width - width / 2
                y: yf * root.height - height / 2
                transform: Translate { id: tr }

                RadialGradient {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0;  color: blob.col }
                        GradientStop { position: 0.62; color: "transparent" }
                    }
                }

                SequentialAnimation {
                    running: true; loops: Animation.Infinite
                    NumberAnimation { target: tr; property: "x"; to:  root.width * 0.05;  duration: dur;     easing.type: Easing.InOutSine }
                    NumberAnimation { target: tr; property: "x"; to: -root.width * 0.035; duration: dur;     easing.type: Easing.InOutSine }
                    NumberAnimation { target: tr; property: "x"; to:  0;                  duration: dur;     easing.type: Easing.InOutSine }
                }
                SequentialAnimation {
                    running: true; loops: Animation.Infinite
                    NumberAnimation { target: tr; property: "y"; to:  root.height * 0.06; duration: dur * 1.3; easing.type: Easing.InOutSine }
                    NumberAnimation { target: tr; property: "y"; to: -root.height * 0.04; duration: dur * 1.3; easing.type: Easing.InOutSine }
                    NumberAnimation { target: tr; property: "y"; to:  0;                  duration: dur * 1.3; easing.type: Easing.InOutSine }
                }
            }
        }
    }
    // soften the whole aurora layer into a dreamy glow
    layer.enabled: false

    // ---- diagonal light sweep ----
    Rectangle {
        id: sweep
        width: parent.width * 1.6
        height: parent.height * 1.8
        y: -parent.height * 0.4
        rotation: 22
        opacity: 0.08
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.30; color: "transparent" }
            GradientStop { position: 0.50; color: "#ffffff" }
            GradientStop { position: 0.70; color: "transparent" }
        }
        SequentialAnimation on x {
            loops: Animation.Infinite
            NumberAnimation { from: -parent.width * 0.7; to: parent.width * 0.4; duration: 15000; easing.type: Easing.InOutSine }
            NumberAnimation { from: parent.width * 0.4; to: -parent.width * 0.7; duration: 15000; easing.type: Easing.InOutSine }
        }
    }

    // ---- rising bokeh bubbles ----
    Repeater {
        model: 12
        delegate: Rectangle {
            required property int index
            property real sz: 22 + (index * 41) % 150
            width: sz; height: sz
            radius: sz / 2
            x: ((index * 61) % 100) / 100 * root.width
            color: "transparent"
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                gradient: Gradient {
                    GradientStop { position: 0.0;  color: Qt.rgba(1,1,1,0.85) }
                    GradientStop { position: 0.42; color: Qt.rgba(1,1,1,0.12) }
                    GradientStop { position: 1.0;  color: "transparent" }
                }
            }
            opacity: 0.5
            SequentialAnimation on y {
                loops: Animation.Infinite
                PauseAnimation { duration: (index * 700) % 6000 }
                NumberAnimation {
                    from: root.height + sz
                    to: -sz
                    duration: 17000 + (index % 7) * 3000
                    easing.type: Easing.Linear
                }
            }
        }
    }

    // vignette for depth
    RadialGradient {
        anchors.fill: parent
        horizontalRadius: parent.width * 0.75
        verticalRadius: parent.height * 0.8
        gradient: Gradient {
            GradientStop { position: 0.6;  color: "transparent" }
            GradientStop { position: 1.0;  color: Qt.rgba(0.015, 0.09, 0.19, 0.28) }
        }
    }
}
