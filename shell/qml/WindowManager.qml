import QtQuick
import GlassOS

// Manages the in-shell app windows. GlassOS apps are custom and open right here
// as glass windows (no external programs), so they open instantly and reliably.
// It also tracks per-app launch state so the dock can show a blinking "opening"
// dot that turns into a static "running" dot once the window is ready.
Item {
    id: wm

    // reactive id lists — reassigned (not mutated) so bindings re-evaluate
    property var openingIds: []
    property var openIds: []
    property var _wins: ({})     // appId -> AppWindow instance
    property int _ztop: 10

    signal appOpened()

    function isOpening(id) { return openingIds.indexOf(id) >= 0 }
    function isOpen(id)    { return openIds.indexOf(id) >= 0 }

    function _addOpening(id) { if (openingIds.indexOf(id) < 0) openingIds = openingIds.concat([id]) }
    function _rmOpening(id)  { openingIds = openingIds.filter(function (x) { return x !== id }) }
    function _addOpen(id)    { if (openIds.indexOf(id) < 0) openIds = openIds.concat([id]) }
    function _rmOpen(id)     { openIds = openIds.filter(function (x) { return x !== id }) }

    function open(appId, name, glyph, tint) {
        if (_wins[appId]) { activate(appId); return }
        var n = Object.keys(_wins).length
        var win = winComp.createObject(wm, {
            appId: appId, title: name, glyph: glyph, tint: tint, manager: wm,
            x: Math.max(40, wm.width / 2 - 310 + (n * 30) % 170),
            y: Math.max(28, wm.height / 2 - 250 + (n * 26) % 130),
            z: ++wm._ztop
        })
        if (!win) return
        _wins[appId] = win
        _addOpening(appId)
        win.readied.connect(function () { wm._rmOpening(appId); wm._addOpen(appId) })
        win.closed.connect(function () {
            wm._rmOpening(appId); wm._rmOpen(appId)
            delete wm._wins[appId]; win.destroy()
        })
        win.focusRequested.connect(function () { wm.activate(appId) })
        appOpened()
    }

    // NOTE: must NOT be named `focus` — that collides with QQuickItem's final
    // `focus` property, so the override is silently dropped and minimized
    // windows never restore (apps "won't reopen after being minimized").
    function activate(appId) {
        var win = _wins[appId]
        if (!win) return
        win.minimized = false
        win.z = ++wm._ztop
    }

    Component {
        id: winComp
        AppWindow {}
    }
}
