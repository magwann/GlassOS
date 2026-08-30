import QtQuick
import GlassOS

// A draggable glass app window. Dragging uses a DragHandler, which keeps its
// pointer grab even when the cursor leaves the window — so windows no longer
// shake/jump when the mouse moves off the frame during a drag.
Item {
    id: awin

    property string appId: ""
    property string title: "App"
    property string glyph: "files"
    property string tint: "aqua"
    property bool loading: true
    property bool minimized: false
    property bool maximized: false
    property rect _restore: Qt.rect(0, 0, 0, 0)
    property var manager: null          // the WindowManager — apps use it to open other apps

    property int minW: 380
    property int minH: 260

    signal readied()          // window finished "opening"
    signal closed()
    signal focusRequested()

    width: 640; height: 470
    visible: !minimized
    opacity: 0
    scale: 0.96
    transformOrigin: Item.Center

    Behavior on opacity { NumberAnimation { duration: 160 } }
    Behavior on scale   { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }

    Component.onCompleted: { opacity = 1; scale = 1; loadTimer.start() }

    Timer {
        id: loadTimer
        interval: 620
        onTriggered: { awin.loading = false; awin.readied() }
    }

    function compFor(id) {
        var map = {
            welcome: "Welcome", files: "Files", browser: "Browser", terminal: "Terminal",
            settings: "Settings", mail: "Mail", music: "Music", photos: "Photos", calc: "Calculator",
            appstore: "AppStore"
        }
        return map[id] || "Welcome"
    }

    function toggleMax() {
        if (!awin.maximized) {
            awin._restore = Qt.rect(awin.x, awin.y, awin.width, awin.height)
            awin.x = 24; awin.y = 24
            awin.width = awin.parent.width - 48
            awin.height = awin.parent.height - 48 - 86   // keep clear of the dock
            awin.maximized = true
        } else {
            awin.x = awin._restore.x; awin.y = awin._restore.y
            awin.width = awin._restore.width; awin.height = awin._restore.height
            awin.maximized = false
        }
    }

    // clicking anywhere on the window raises it (empty areas fall through to here)
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onPressed: function (mouse) { awin.focusRequested(); mouse.accepted = false }
    }

    GlassPanel {
        id: frame
        anchors.fill: parent
        radius: Theme.rLg
        tint: Theme.glassDeep

        // ---- titlebar ----
        Item {
            id: bar
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 44

            DragHandler {
                target: awin
                enabled: !awin.maximized
                xAxis.minimum: -awin.width + 90
                xAxis.maximum: awin.parent ? awin.parent.width - 90 : 2000
                yAxis.minimum: 0
                yAxis.maximum: awin.parent ? awin.parent.height - 60 : 2000
                onActiveChanged: if (active) awin.focusRequested()
            }
            TapHandler { onDoubleTapped: awin.toggleMax() }

            Row {
                anchors.left: parent.left; anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 20; height: 20
                    source: "glyphs/" + awin.glyph + ".svg"
                    sourceSize.width: 40; sourceSize.height: 40
                    smooth: true
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: awin.title
                    color: Theme.inkInv
                    font.family: Theme.fontFamily; font.pixelSize: 14; font.bold: true
                    style: Text.Raised; styleColor: Qt.rgba(0, 0.12, 0.24, 0.6)
                }
            }

            // shiny R/Y/G controls on the right
            Row {
                anchors.right: parent.right; anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                spacing: 9
                WinDot { color1: "#ffe08a"; color2: "#f2a51c"; onTapped: awin.minimized = true }   // minimize
                WinDot { color1: "#9ff0b0"; color2: "#26b552"; onTapped: awin.toggleMax() }         // maximize
                WinDot { color1: "#ff9a8f"; color2: "#e5443b"; onTapped: awin.closed() }            // close
            }
        }

        // ---- content ----
        Loader {
            id: bodyLoader
            anchors {
                left: parent.left; right: parent.right
                top: bar.bottom; bottom: parent.bottom
                leftMargin: 14; rightMargin: 14; topMargin: 2; bottomMargin: 14
            }
            source: awin.loading ? "" : ("apps/" + awin.compFor(awin.appId) + ".qml")
            opacity: awin.loading ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 200 } }
            // hand the loaded app a reference to the window manager if it wants one
            onLoaded: if (item && item.manager !== undefined) item.manager = awin.manager
        }

        // ---- loading shimmer ----
        Item {
            anchors.centerIn: parent
            visible: awin.loading
            width: 44; height: 44
            Rectangle {
                id: spin
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: 4
                border.color: Qt.rgba(1, 1, 1, 0.85)
                opacity: 0.9
                // gap so the ring reads as a spinner
                Rectangle {
                    width: 6; height: 6; radius: 3
                    color: Theme.aqua
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: -3
                }
                RotationAnimation on rotation {
                    running: awin.loading
                    loops: Animation.Infinite
                    from: 0; to: 360; duration: 900
                }
            }
        }

        // ---- resize grips ----
        // Drag from an edge or the bottom-right corner to resize. Deltas are read
        // from the pointer's *scene* position so the grip moving with the window
        // as it grows never feeds back into the size.
        component Grip: Item {
            property bool horiz: false
            property bool vert: false
            property real _w0: 0
            property real _h0: 0
            visible: !awin.maximized
            DragHandler {
                target: null
                dragThreshold: 0
                onActiveChanged: if (active) { _w0 = awin.width; _h0 = awin.height; awin.focusRequested() }
                onActiveTranslationChanged: if (active) {
                    if (horiz) {
                        var nw = _w0 + (centroid.scenePosition.x - centroid.scenePressPosition.x)
                        var maxW = awin.parent ? awin.parent.width - awin.x - 6 : 4000
                        awin.width = Math.max(awin.minW, Math.min(maxW, nw))
                    }
                    if (vert) {
                        var nh = _h0 + (centroid.scenePosition.y - centroid.scenePressPosition.y)
                        var maxH = awin.parent ? awin.parent.height - awin.y - 6 : 4000
                        awin.height = Math.max(awin.minH, Math.min(maxH, nh))
                    }
                }
            }
        }

        Grip {   // right edge
            horiz: true
            width: 8
            anchors { right: parent.right; top: parent.top; bottom: parent.bottom
                      topMargin: 44; bottomMargin: 16 }
        }
        Grip {   // bottom edge
            vert: true
            height: 8
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom
                      leftMargin: 16; rightMargin: 16 }
        }
        Grip {   // bottom-right corner
            horiz: true; vert: true
            width: 18; height: 18
            anchors { right: parent.right; bottom: parent.bottom }
        }
    }
}
