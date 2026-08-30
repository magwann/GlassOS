import QtQuick
import QtQuick.Window
import GlassOS

Window {
    id: win
    visible: true
    // Not FullScreen: under sway a fullscreen window covers launched apps.
    // As a normal window the compositor tiles it to fill the screen, and real
    // apps open as floating windows on top of it.
    visibility: Window.Windowed
    width: 1280
    height: 800
    title: "GlassOS"
    color: "#0a4f8f"

    // dev hook: GLASSOS_OPEN=<appId> auto-opens one window for headless testing
    Component.onCompleted: {
        if (typeof StartupApp !== "undefined" && StartupApp.length) {
            wm.open(StartupApp, StartupApp.charAt(0).toUpperCase() + StartupApp.slice(1), StartupApp, "aqua")
            // GLASSOS_SELFTEST=minrestore: minimize then reopen, to verify a
            // minimized window restores (exercises WindowManager.activate()).
            if (typeof SelfTest !== "undefined" && SelfTest === "minrestore") {
                selftestMin.start(); selftestRestore.start()
            }
        }
    }
    Timer { id: selftestMin;     interval: 1500; onTriggered: wm.minimize(StartupApp) }
    Timer { id: selftestRestore; interval: 2900
        onTriggered: wm.open(StartupApp, StartupApp.charAt(0).toUpperCase() + StartupApp.slice(1), StartupApp, "aqua") }

    // ---- wallpaper ----
    Wallpaper {
        id: wallpaper
        anchors.fill: parent
    }

    // click anywhere on the desktop closes the start menu
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: startMenu.shown = false
        acceptedButtons: Qt.LeftButton
        propagateComposedEvents: true
    }

    // ---- desktop icons (top-left column) ----
    Column {
        x: 26; y: 26
        spacing: 22
        z: 1
        Repeater {
            model: Apps
            delegate: Item {
                required property string appId
                required property string name
                required property string glyph
                required property string tint
                required property string exec
                visible: appId === "files" || appId === "settings" || appId === "browser" || appId === "terminal"
                width: visible ? 92 : 0
                height: visible ? 92 : 0

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    AppTile {
                        anchors.horizontalCenter: parent.horizontalCenter
                        size: 58
                        glyph: parent.parent.glyph
                        tint: parent.parent.tint
                        onActivated: wm.open(parent.parent.appId, parent.parent.name, parent.parent.glyph, parent.parent.tint)
                    }
                    RunDot {
                        anchors.horizontalCenter: parent.horizontalCenter
                        opening: wm.isOpening(parent.parent.appId)
                        active: wm.isOpen(parent.parent.appId)
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: parent.parent.name
                        color: Theme.inkInv
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        style: Text.Raised
                        styleColor: Qt.rgba(0,0.12,0.24,0.7)
                    }
                }
            }
        }
    }

    // ---- app windows layer (custom in-shell apps) ----
    // Kept below the dock/start menu (lower z) so those chrome elements always
    // stay on top of every open window.
    WindowManager {
        id: wm
        anchors.fill: parent
        z: 50
    }

    // ---- start menu (always on top of windows) ----
    StartMenu {
        id: startMenu
        z: 1000
        wm: wm
        backdrop: wallpaper
        x: 14
        width: 420
        height: Math.min(520, win.height * 0.62)
        y: win.height - taskbar.height - 24 - height
        onAppLaunched: shown = false
    }

    // ---- taskbar / dock (always on top of windows) ----
    Taskbar {
        id: taskbar
        z: 1000
        wm: wm
        backdrop: wallpaper
        height: 62
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.bottomMargin: 12
        startActive: startMenu.shown
        onStartToggled: startMenu.shown = !startMenu.shown
    }
}
