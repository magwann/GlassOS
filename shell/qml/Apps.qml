pragma Singleton
import QtQuick

// The GlassOS app registry. `exec` is the real command run on FreeBSD.
// Swap execs for whatever packages you install (pkg install ...).
ListModel {
    ListElement { appId: "welcome";  name: "Welcome";    glyph: "welcome";  tint: "aqua";   exec: "" }
    ListElement { appId: "files";    name: "Files";      glyph: "files";    tint: "teal";   exec: "pcmanfm-qt" }
    ListElement { appId: "browser";  name: "Aqua Web";   glyph: "browser";  tint: "aqua";   exec: "firefox" }
    ListElement { appId: "terminal"; name: "Terminal";   glyph: "terminal"; tint: "leaf";   exec: "foot || xterm" }
    ListElement { appId: "settings"; name: "Settings";   glyph: "settings"; tint: "violet"; exec: "" }
    ListElement { appId: "mail";     name: "Mail";       glyph: "mail";     tint: "teal";   exec: "thunderbird" }
    ListElement { appId: "music";    name: "Music";      glyph: "music";    tint: "violet"; exec: "" }
    ListElement { appId: "photos";   name: "Photos";     glyph: "photos";   tint: "warm";   exec: "" }
    ListElement { appId: "calc";     name: "Calculator"; glyph: "calc";     tint: "aqua";   exec: "" }
}
