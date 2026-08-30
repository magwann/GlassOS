import QtQuick
import QtQuick.Controls.Basic
import GlassOS

// GlassOS App Store — a glassy catalog. "Installed" apps are the in-shell GlassOS
// apps and open right here via the window manager; "discover" apps show the
// install → installing → open flow. Set by AppWindow.onLoaded.
Item {
    id: store
    property var manager: null   // the WindowManager (see AppWindow.onLoaded)

    // catalog: installed:true apps open in-shell via manager.open()
    property var catalog: [
        {appId:"browser",  name:"Aqua Web",    glyph:"browser",  tint:"aqua",   cat:"Web",           blurb:"Glass browser shell",       installed:true},
        {appId:"files",    name:"Files",       glyph:"files",    tint:"teal",   cat:"System",        blurb:"Browse your stuff",         installed:true},
        {appId:"terminal", name:"Terminal",    glyph:"terminal", tint:"leaf",   cat:"Developer",     blurb:"A real shell in glass",     installed:true},
        {appId:"calc",     name:"Calculator",  glyph:"calc",     tint:"aqua",   cat:"Utilities",     blurb:"Numbers, beautifully",      installed:true},
        {appId:"music",    name:"Music",       glyph:"music",    tint:"violet", cat:"Media",         blurb:"Your library, glowing",     installed:true},
        {appId:"photos",   name:"Photos",      glyph:"photos",   tint:"warm",   cat:"Media",         blurb:"Memories under glass",      installed:true},
        {appId:"mail",     name:"Mail",        glyph:"mail",     tint:"teal",   cat:"Productivity",  blurb:"Inbox, aerated",            installed:true},
        {appId:"settings", name:"Settings",    glyph:"settings", tint:"violet", cat:"System",        blurb:"Tune your desktop",         installed:true},
        {appId:"_notes",   name:"Aqua Notes",  glyph:"files",    tint:"leaf",   cat:"Productivity",  blurb:"Frosted sticky notes",      installed:false},
        {appId:"_weather", name:"Skyglass",    glyph:"welcome",  tint:"aqua",   cat:"Lifestyle",     blurb:"Weather that shimmers",     installed:false},
        {appId:"_paint",   name:"Bokeh Paint", glyph:"photos",   tint:"violet", cat:"Creative",      blurb:"Paint with light blooms",   installed:false},
        {appId:"_pods",    name:"Ripple Pods", glyph:"music",    tint:"warm",   cat:"Media",         blurb:"Podcasts, dripping wet",    installed:false}
    ]

    Column {
        anchors.fill: parent
        spacing: 12

        // ---- store header ----
        Row {
            width: parent.width
            height: 52
            spacing: 12
            Rectangle {
                width: 48; height: 48; radius: 14
                anchors.verticalCenter: parent.verticalCenter
                border.color: Qt.rgba(1,1,1,0.6); border.width: 1
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#f2fffb" }
                    GradientStop { position: 1.0; color: "#6fdcc0" }
                }
                Image {
                    anchors.centerIn: parent; width: 26; height: 26
                    source: "../glyphs/appstore.svg"
                    sourceSize.width: 52; sourceSize.height: 52
                }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1
                Text {
                    text: "App Store"
                    color: Theme.inkInv
                    font.family: Theme.fontFamily; font.pixelSize: 22; font.bold: true
                    style: Text.Raised; styleColor: Qt.rgba(0,0.12,0.24,0.6)
                }
                Text {
                    text: "Glassware for GlassOS"
                    color: Qt.rgba(1,1,1,0.82)
                    font.family: Theme.fontFamily; font.pixelSize: 12
                }
            }
        }

        // ---- catalog grid ----
        GridView {
            id: grid
            width: parent.width
            height: parent.height - 52 - 12
            cellWidth: Math.floor(width / Math.max(1, Math.floor(width / 250)))
            cellHeight: 96
            clip: false   // stencil clip renders black on virgl/GL-2.1
            model: store.catalog

            delegate: Item {
                required property var modelData
                property bool installed: modelData.installed
                property bool installing: false
                width: grid.cellWidth
                height: grid.cellHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 6
                    radius: 16
                    color: cardHover.hovered ? Qt.rgba(1,1,1,0.20) : Qt.rgba(1,1,1,0.13)
                    border.color: Qt.rgba(1,1,1,0.30); border.width: 1
                    Behavior on color { ColorAnimation { duration: 120 } }
                    HoverHandler { id: cardHover }

                    AppTile {
                        id: ico
                        anchors.left: parent.left; anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        size: 52
                        glyph: modelData.glyph
                        tint: modelData.tint
                    }

                    Column {
                        anchors.left: ico.right; anchors.leftMargin: 12
                        anchors.right: parent.right; anchors.rightMargin: 12
                        anchors.top: parent.top; anchors.topMargin: 12
                        spacing: 2
                        Text {
                            text: modelData.name
                            color: Theme.ink
                            font.family: Theme.fontFamily; font.pixelSize: 15; font.bold: true
                            elide: Text.ElideRight; width: parent.width
                        }
                        Text {
                            text: modelData.cat
                            color: Theme.inkSoft
                            font.family: Theme.fontFamily; font.pixelSize: 11
                        }
                        Text {
                            text: modelData.blurb
                            color: Theme.inkSoft
                            font.family: Theme.fontFamily; font.pixelSize: 11
                            elide: Text.ElideRight; width: parent.width
                        }
                    }

                    // ---- Get / Open button ----
                    Rectangle {
                        id: btn
                        anchors.right: parent.right; anchors.rightMargin: 12
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 12
                        width: 74; height: 26; radius: 13
                        color: installed ? Qt.rgba(1,1,1,0.28)
                             : btnHover.hovered ? Theme.aqua : Theme.aquaDeep
                        border.color: Qt.rgba(1,1,1,0.5); border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text {
                            anchors.centerIn: parent
                            text: installing ? "Installing" : (installed ? "OPEN" : "GET")
                            color: installed ? Theme.ink : "white"
                            font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true
                        }
                        HoverHandler { id: btnHover }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (installing) return
                                if (installed) {
                                    if (store.manager)
                                        store.manager.open(modelData.appId, modelData.name, modelData.glyph, modelData.tint)
                                } else {
                                    installing = true
                                    installTimer.start()
                                }
                            }
                        }
                        Timer {
                            id: installTimer
                            interval: 1400
                            onTriggered: { installing = false; installed = true }
                        }
                    }
                }
            }
        }
    }
}
