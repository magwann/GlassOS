import QtQuick
import QtQuick.Controls.Basic
import QtWebEngine
import GlassOS

// Aqua Web — a real browser. Glass chrome on top, a live WebEngineView below.
Item {
    id: br

    function go(text) {
        var t = (text || "").trim()
        if (t.length === 0) return
        // treat as a URL if it looks like one, otherwise search
        if (/^[a-z][a-z0-9+.-]*:\/\//i.test(t)) {
            web.url = t
        } else if (/^[^ ]+\.[^ ]{2,}/.test(t)) {
            web.url = "https://" + t
        } else {
            web.url = "https://duckduckgo.com/?q=" + encodeURIComponent(t)
        }
    }

    Column {
        anchors.fill: parent
        spacing: 10

        Row {
            width: parent.width; height: 40; spacing: 8
            NavBtn { glyphText: "‹"; enabled: web.canGoBack;    onTapped: web.goBack() }
            NavBtn { glyphText: "›"; enabled: web.canGoForward; onTapped: web.goForward() }
            NavBtn { glyphText: web.loading ? "✕" : "⟳"
                     onTapped: web.loading ? web.stop() : web.reload() }
            Rectangle {
                width: parent.width - 3 * 40 - 3 * 8; height: 40; radius: 20
                color: Qt.rgba(1, 1, 1, 0.22)
                border.color: Theme.glassBorderLo; border.width: 1
                TextField {
                    id: addr
                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter
                    text: web.url == "" ? "" : web.url
                    color: Theme.ink
                    font.family: Theme.fontFamily; font.pixelSize: 14
                    selectByMouse: true
                    background: Item {}
                    onAccepted: br.go(text)
                }
                // thin progress shimmer along the bottom of the address bar
                Rectangle {
                    visible: web.loading
                    anchors.left: parent.left; anchors.bottom: parent.bottom
                    anchors.leftMargin: 6; anchors.bottomMargin: 3
                    width: (parent.width - 12) * web.loadProgress / 100
                    height: 2; radius: 1
                    color: Theme.aqua
                }
            }
        }

        Rectangle {
            width: parent.width; height: parent.height - 50
            radius: Theme.rMd
            color: Qt.rgba(1, 1, 1, 0.14)
            border.color: Theme.glassBorderLo; border.width: 1

            WebEngineView {
                id: web
                anchors.fill: parent
                anchors.margins: 3
                url: "https://duckduckgo.com"
                onNewWindowRequested: function(request) { request.openIn(web) }
            }
        }
    }

    component NavBtn: Rectangle {
        id: nb
        property string glyphText: ""
        property bool enabled: true
        signal tapped()
        width: 40; height: 40; radius: 12
        opacity: enabled ? 1 : 0.4
        color: nbma.containsMouse && enabled ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, 0.10)
        border.color: Theme.glassBorderLo; border.width: 1
        Behavior on color { ColorAnimation { duration: 120 } }
        Text { anchors.centerIn: parent; text: nb.glyphText; color: Theme.inkInv; font.pixelSize: 18; font.bold: true }
        MouseArea { id: nbma; anchors.fill: parent; hoverEnabled: true; onClicked: if (nb.enabled) nb.tapped() }
    }
}
