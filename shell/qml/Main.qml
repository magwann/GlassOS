import QtQuick
import QtQuick.Window
import GlassOS

Window {
    id: win
    visible: true
    visibility: Window.FullScreen
    title: "GlassOS"
    color: "#0a4f8f"

    // ---- wallpaper ----
    Wallpaper {
        id: wallpaper
        anchors.fill: parent
    }

    // ---- desktop icons (top-left column) ----
    Column {
        x: 26; y: 26
        spacing: 22
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
                    spacing: 8
                    AppTile {
                        anchors.horizontalCenter: parent.horizontalCenter
                        size: 58
                        glyph: parent.parent.glyph
                        tint: parent.parent.tint
                        onActivated: if (parent.parent.exec !== "") Launcher.launch(parent.parent.exec)
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

    // click anywhere on the desktop closes the start menu
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: startMenu.shown = false
        acceptedButtons: Qt.LeftButton
        propagateComposedEvents: true
    }

    // ---- start menu ----
    StartMenu {
        id: startMenu
        backdrop: wallpaper
        x: 14
        width: 420
        height: Math.min(520, win.height * 0.62)
        y: win.height - taskbar.height - 24 - height
        onAppLaunched: shown = false
    }

    // ---- taskbar ----
    Taskbar {
        id: taskbar
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
