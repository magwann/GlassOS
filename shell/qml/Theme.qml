pragma Singleton
import QtQuick

// GlassOS design tokens — single source of truth for the whole shell.
QtObject {
    // ---- palette ----
    readonly property color aqua:     "#3fbdf6"
    readonly property color aquaDeep: "#0a84c9"
    readonly property color teal:     "#35e0c4"
    readonly property color sky:      "#bfeafe"
    readonly property color leaf:     "#7be495"
    readonly property color warm:     "#fff6d8"
    readonly property color violet:   "#b4a0ff"

    readonly property color ink:      "#08324f"
    readonly property color inkInv:   "#f5ffff"
    readonly property color inkSoft:  Qt.rgba(0.035, 0.18, 0.28, 0.72)

    // ---- glass recipe ----
    readonly property color glassTint:  Qt.rgba(1, 1, 1, 0.14)
    readonly property color glassSoft:  Qt.rgba(1, 1, 1, 0.08)
    readonly property color glassDeep:  Qt.rgba(0.055, 0.18, 0.29, 0.30)
    readonly property color glassBorder:    Qt.rgba(1, 1, 1, 0.55)
    readonly property color glassBorderLo:  Qt.rgba(1, 1, 1, 0.22)

    // ---- gloss highlight ----
    readonly property color glossTop: Qt.rgba(1, 1, 1, 0.62)
    readonly property color glossMid: Qt.rgba(1, 1, 1, 0.06)

    // ---- geometry ----
    readonly property int rSm: 10
    readonly property int rMd: 16
    readonly property int rLg: 22
    readonly property int rXl: 30

    // ---- type ----
    readonly property string fontFamily: "Inter"

    // map a tint name -> [top color, bottom color] for app tiles
    function tileGradient(name) {
        switch (name) {
        case "aqua":   return [Qt.rgba(0.25,0.74,0.96,0.60), Qt.rgba(0.04,0.52,0.79,0.55)];
        case "teal":   return [Qt.rgba(0.21,0.88,0.77,0.60), Qt.rgba(0.04,0.59,0.59,0.55)];
        case "leaf":   return [Qt.rgba(0.48,0.89,0.58,0.60), Qt.rgba(0.16,0.67,0.43,0.55)];
        case "warm":   return [Qt.rgba(1.0,0.96,0.85,0.65),  Qt.rgba(1.0,0.75,0.47,0.55)];
        case "violet": return [Qt.rgba(0.71,0.63,1.0,0.60),  Qt.rgba(0.47,0.35,0.86,0.55)];
        default:       return [Qt.rgba(0.25,0.74,0.96,0.60), Qt.rgba(0.04,0.52,0.79,0.55)];
        }
    }
}
