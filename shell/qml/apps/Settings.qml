import QtQuick
import GlassOS

Item {
    Column {
        anchors.fill: parent
        spacing: 2
        SettingRow {
            label: "Night glass (dark mode)"
            value: Theme.dark
            onToggled: function (v) { Theme.dark = v; Launcher.setGtkDark(Theme.dark) }
        }
        SettingRow { label: "Transparency";         value: true }
        SettingRow { label: "Live wallpaper";        value: true }
        SettingRow { label: "Glass blur intensity";  value: true }
        SettingRow { label: "Reduce motion";         value: false }
    }

    component SettingRow: Item {
        id: sr
        property string label: ""
        property bool value: false
        signal toggled(bool v)
        width: parent ? parent.width : 400
        height: 54

        Text {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            text: sr.label
            color: Theme.inkInv
            font.family: Theme.fontFamily; font.pixelSize: 15
        }
        Rectangle {
            id: sw
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            width: 52; height: 28; radius: 14
            color: sr.value ? Theme.teal : Qt.rgba(1, 1, 1, 0.2)
            border.color: Theme.glassBorderLo; border.width: 1
            Behavior on color { ColorAnimation { duration: 150 } }
            Rectangle {
                width: 22; height: 22; radius: 11; y: 3
                x: sr.value ? parent.width - 25 : 3
                color: "white"
                Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            }
            MouseArea { anchors.fill: parent; onClicked: { sr.value = !sr.value; sr.toggled(sr.value) } }
        }
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Qt.rgba(1, 1, 1, 0.12) }
    }
}
