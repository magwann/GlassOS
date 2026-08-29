import QtQuick
import GlassOS

// Bottom glass dock: start orb + app tiles + tray + clock.
GlassPanel {
    id: root
    radius: Theme.rXl
    tint: Theme.glassDeep

    signal startToggled()
    property bool startActive: false

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        // ---- start orb ----
        Item {
            width: 46; height: 46
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: orb
                anchors.fill: parent
                radius: width / 2
                border.color: Qt.rgba(1,1,1,0.6)
                border.width: 1
                // glossy light base so the green sprout reads as "wet"
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#f2fffb" }
                    GradientStop { position: 0.55; color: "#c8f7e4" }
                    GradientStop { position: 1.0; color: "#6fdcc0" }
                }
                scale: orbTap.pressed ? 0.93 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }

                // specular highlight (wet shine)
                Rectangle {
                    x: parent.width * 0.22; y: parent.height * 0.13
                    width: parent.width * 0.46; height: parent.height * 0.32
                    radius: height / 2
                    color: Qt.rgba(1,1,1,0.9)
                    opacity: 0.75
                }
                Image {
                    anchors.centerIn: parent
                    width: 26; height: 26
                    source: "glyphs/sprout.svg"
                    sourceSize.width: 52; sourceSize.height: 52
                    smooth: true
                }
                // active ring
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: Qt.rgba(1,1,1,0.35)
                    border.width: 3
                    visible: root.startActive
                }
                MouseArea {
                    id: orbTap
                    anchors.fill: parent
                    onClicked: root.startToggled()
                }
            }
        }

        // divider
        Rectangle {
            width: 1; height: 34
            anchors.verticalCenter: parent.verticalCenter
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1,1,1,0.05) }
                GradientStop { position: 0.5; color: Qt.rgba(1,1,1,0.5) }
                GradientStop { position: 1.0; color: Qt.rgba(1,1,1,0.05) }
            }
        }

        // ---- pinned apps ----
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            Repeater {
                model: Apps
                delegate: Item {
                    required property string appId
                    required property string name
                    required property string glyph
                    required property string tint
                    required property string exec
                    visible: appId !== "welcome"
                    width: visible ? 46 : 0
                    height: 46

                    Rectangle {
                        anchors.fill: parent
                        radius: 13
                        color: hover.hovered ? Qt.rgba(1,1,1,0.18) : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                    AppTile {
                        anchors.centerIn: parent
                        size: 40
                        glyph: parent.glyph
                        tint: parent.tint
                        onActivated: if (parent.exec !== "") Launcher.launch(parent.exec)
                    }
                    HoverHandler { id: hover }
                }
            }
        }
    }

    // ---- tray + clock (right aligned) ----
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Repeater {
            model: ["wifi", "volume", "battery"]
            delegate: Rectangle {
                required property string modelData
                width: 34; height: 34; radius: 10
                color: trayHover.hovered ? Qt.rgba(1,1,1,0.24) : Qt.rgba(1,1,1,0.10)
                Behavior on color { ColorAnimation { duration: 120 } }
                Image {
                    anchors.centerIn: parent
                    width: 18; height: 18
                    source: "glyphs/" + modelData + ".svg"
                    sourceSize.width: 36; sourceSize.height: 36
                }
                HoverHandler { id: trayHover }
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
            Text {
                id: timeText
                text: Qt.formatTime(new Date(), "hh:mm")
                color: Theme.inkInv
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.bold: true
                horizontalAlignment: Text.AlignRight
                anchors.right: parent.right
            }
            Text {
                text: Qt.formatDate(new Date(), "MMM d")
                color: Qt.rgba(1,1,1,0.8)
                font.family: Theme.fontFamily
                font.pixelSize: 10
                anchors.right: parent.right
            }
        }
    }

    Timer {
        interval: 10000; running: true; repeat: true
        onTriggered: timeText.text = Qt.formatTime(new Date(), "hh:mm")
    }
}
