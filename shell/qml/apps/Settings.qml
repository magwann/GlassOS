import QtQuick
import GlassOS

// GlassOS Settings — full system settings, our own. Sidebar of categories +
// detail panes. High-value controls are wired to the real system (dark mode,
// volume, About); the rest hold state in the glass UI.
Item {
    id: root
    property string current: "appearance"

    // Sidebar has 17 fixed categories and we can't clip (stencil clip renders
    // black on virgl), so size each row to fit the window height — otherwise the
    // list spills out past the bottom of the window.
    property real sideRowH: Math.max(20, Math.min(40, (height - 16) / cats.length))

    // ---------- reusable glass controls (inline components) ----------
    component Card: Rectangle {
        default property alias data_: col.data
        property string title: ""
        width: parent ? parent.width : 100
        radius: 16
        color: Qt.rgba(1,1,1,0.16)
        border.color: Qt.rgba(1,1,1,0.35)
        border.width: 1
        height: col.implicitHeight + (title ? 44 : 20)
        Text {
            visible: title.length > 0
            text: title; x: 16; y: 12
            color: Theme.ink; font.family: Theme.fontFamily; font.pixelSize: 13; font.bold: true
            opacity: 0.85
        }
        Column {
            id: col
            x: 8; width: parent.width - 16
            y: title ? 38 : 10
            spacing: 2
        }
    }

    component Row_: Item {
        property string label: ""
        property string sub: ""
        default property alias control: slot.data
        width: parent ? parent.width : 100
        height: 50
        Column {
            anchors.left: parent.left; anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text { text: label; color: Theme.ink; font.family: Theme.fontFamily; font.pixelSize: 14 }
            Text { visible: sub.length>0; text: sub; color: Theme.inkSoft; font.family: Theme.fontFamily; font.pixelSize: 12 }
        }
        Item { id: slot; anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter; width: 220; height: parent.height
               // right-align the single control placed inside
               onChildrenChanged: if (children.length) { var c = children[0]; c.anchors.right = slot.right; c.anchors.verticalCenter = slot.verticalCenter } }
    }

    component Sep: Rectangle { width: parent ? parent.width-8 : 100; x:4; height:1; color: Qt.rgba(1,1,1,0.18) }

    component Toggle_: Item {
        property bool on: false
        signal toggled(bool value)
        width: 48; height: 28
        Rectangle {
            anchors.fill: parent; radius: height/2
            color: on ? Theme.teal : Qt.rgba(1,1,1,0.35)
            border.color: Qt.rgba(1,1,1,0.5); border.width: 1
            Behavior on color { ColorAnimation { duration: 150 } }
            Rectangle {
                width: 22; height: 22; radius: 11
                y: 3; x: parent.parent.on ? parent.width-25 : 3
                gradient: Gradient {
                    GradientStop { position:0; color:"#ffffff" }
                    GradientStop { position:1; color:"#e6f4ff" }
                }
                border.color: Qt.rgba(0,0,0,0.08); border.width:1
                Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            }
        }
        MouseArea { anchors.fill: parent; onClicked: { parent.on = !parent.on; parent.toggled(parent.on) } }
    }

    component Slider_: Item {
        property real value: 0.5     // 0..1
        signal moved(real v)
        width: 200; height: 28
        Rectangle {
            id: track; anchors.verticalCenter: parent.verticalCenter
            width: parent.width; height: 6; radius: 3
            color: Qt.rgba(1,1,1,0.35)
            Rectangle { width: parent.width * parent.parent.value; height: parent.height; radius: 3
                gradient: Gradient { orientation: Gradient.Horizontal
                    GradientStop { position:0; color: Theme.teal } GradientStop { position:1; color: Theme.aqua } } }
        }
        Rectangle {
            width: 20; height: 20; radius: 10
            x: (parent.width-20) * parent.value
            anchors.verticalCenter: parent.verticalCenter
            gradient: Gradient { GradientStop{position:0;color:"#fff"} GradientStop{position:1;color:"#dcefff"} }
            border.color: Qt.rgba(0,0,0,0.12); border.width:1
        }
        MouseArea {
            anchors.fill: parent
            function set(mx){ var v = Math.max(0, Math.min(1, mx/parent.width)); parent.value=v; parent.moved(v) }
            onPressed: (m)=> set(m.x)
            onPositionChanged: (m)=> { if(pressed) set(m.x) }
        }
    }

    component Select_: Item {
        property var options: ["Option"]
        property int idx: 0
        signal picked(int index)
        width: 150; height: 32
        Rectangle {
            anchors.fill: parent; radius: 9
            color: selHover.hovered ? Qt.rgba(1,1,1,0.4) : Qt.rgba(1,1,1,0.28)
            border.color: Qt.rgba(1,1,1,0.5); border.width:1
            Text { anchors.left: parent.left; anchors.leftMargin:12; anchors.verticalCenter: parent.verticalCenter
                text: parent.parent.options[parent.parent.idx]; color: Theme.ink; font.family: Theme.fontFamily; font.pixelSize:13 }
            Text { anchors.right: parent.right; anchors.rightMargin:12; anchors.verticalCenter: parent.verticalCenter
                text: "▾"; color: Theme.inkSoft; font.pixelSize:12 }
            HoverHandler { id: selHover }
            MouseArea { anchors.fill: parent; onClicked: {
                parent.parent.idx = (parent.parent.idx+1) % parent.parent.options.length
                parent.parent.picked(parent.parent.idx) } }
        }
    }

    component Panel: Flickable {
        default property alias body: pcol.data
        anchors.fill: parent
        contentHeight: pcol.implicitHeight + 40
        clip: false
        Column { id: pcol; x: 24; y: 20; width: parent.width - 48; spacing: 16 }
    }

    // ---------- categories ----------
    property var cats: [
        {key:"wifi",     name:"Wi-Fi",            tint:"#3fbdf6"},
        {key:"bluetooth",name:"Bluetooth",        tint:"#4a7bff"},
        {key:"network",  name:"Network",          tint:"#35c0e0"},
        {key:"appearance",name:"Appearance",      tint:"#b4a0ff"},
        {key:"notifications",name:"Notifications", tint:"#ff8a5c"},
        {key:"sound",    name:"Sound",            tint:"#35e0c4"},
        {key:"power",    name:"Power",            tint:"#7be495"},
        {key:"displays", name:"Displays",         tint:"#3fbdf6"},
        {key:"mouse",    name:"Mouse & Touchpad", tint:"#9be0a0"},
        {key:"keyboard", name:"Keyboard",         tint:"#c0c8d0"},
        {key:"region",   name:"Region & Language",tint:"#ffd36e"},
        {key:"datetime", name:"Date & Time",      tint:"#5ad2ff"},
        {key:"accessibility",name:"Accessibility",tint:"#7bc0ff"},
        {key:"privacy",  name:"Privacy",          tint:"#8fd6a0"},
        {key:"users",    name:"Users",            tint:"#ffb0c0"},
        {key:"apps",     name:"Default Apps",     tint:"#b4a0ff"},
        {key:"about",    name:"About",            tint:"#cfe8f5"}
    ]

    Row {
        anchors.fill: parent
        spacing: 0

        // -------- sidebar --------
        Rectangle {
            width: 190; height: parent.height
            color: Qt.rgba(1,1,1,0.10)
            Column {
                anchors.fill: parent; anchors.topMargin: 8; anchors.bottomMargin: 8
                id: sideCol; spacing: 0
                Repeater {
                    model: root.cats
                    delegate: Rectangle {
                        required property var modelData
                        width: sideCol.width - 8; x: 4; height: root.sideRowH; radius: 9
                        color: root.current===modelData.key ? Qt.rgba(1,1,1,0.30)
                              : sHover.hovered ? Qt.rgba(1,1,1,0.15) : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Row {
                            anchors.left: parent.left; anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter; spacing: 10
                            Rectangle { width: Math.min(20, root.sideRowH-6); height: width; radius: width*0.3
                                color: modelData.tint; anchors.verticalCenter: parent.verticalCenter
                                border.color: Qt.rgba(1,1,1,0.5); border.width:1 }
                            Text { anchors.verticalCenter: parent.verticalCenter; text: modelData.name
                                color: Theme.ink; font.family: Theme.fontFamily; font.pixelSize: 13 }
                        }
                        HoverHandler { id: sHover }
                        MouseArea { anchors.fill: parent; onClicked: root.current = modelData.key }
                    }
                }
            }
        }

        // -------- content --------
        Item {
            width: parent.width - 190; height: parent.height
            Loader { anchors.fill: parent; sourceComponent: root.panelFor(root.current) }
        }
    }

    function panelFor(k){
        switch(k){
            case "wifi": return wifiPanel;         case "bluetooth": return btPanel;
            case "network": return netPanel;       case "appearance": return appearancePanel;
            case "notifications": return notifPanel;case "sound": return soundPanel;
            case "power": return powerPanel;        case "displays": return displaysPanel;
            case "mouse": return mousePanel;        case "keyboard": return keyboardPanel;
            case "region": return regionPanel;      case "datetime": return datetimePanel;
            case "accessibility": return a11yPanel; case "privacy": return privacyPanel;
            case "users": return usersPanel;        case "apps": return appsPanel;
            default: return aboutPanel;
        }
    }

    // ================= PANELS =================
    Component { id: wifiPanel; Panel {
        Card { title:"Wi-Fi"
            Row_ { label:"Wi-Fi"; sub:"GlassNet 5G"; Toggle_ { on:true } }
            Sep {}
            Row_ { label:"GlassNet 5G"; sub:"Connected · secured" ; Text{text:"✓"; color:Theme.teal; font.pixelSize:16} }
            Row_ { label:"Aqua-Guest"; sub:"Open" }
            Row_ { label:"FRUTIGER-2G"; sub:"Secured" }
        }
        Card { title:"Details"
            Row_ { label:"IPv4"; Text{text:"192.168.64.3"; color:Theme.inkSoft; font.pixelSize:13} }
            Row_ { label:"Router"; Text{text:"192.168.64.1"; color:Theme.inkSoft; font.pixelSize:13} }
        }
    }}

    Component { id: btPanel; Panel {
        Card { title:"Bluetooth"
            Row_ { label:"Bluetooth"; Toggle_ { on:false } }
        }
        Card { title:"Devices"
            Row_ { label:"Glass Buds"; sub:"Not connected" }
            Row_ { label:"Aqua Keyboard"; sub:"Paired" }
        }
    }}

    Component { id: netPanel; Panel {
        Card { title:"Network"
            Row_ { label:"Wired"; sub:"Connected · 1000 Mb/s"; Text{text:"✓"; color:Theme.teal; font.pixelSize:16} }
            Row_ { label:"VPN"; sub:"Not set up"; Toggle_{ on:false } }
            Row_ { label:"Proxy"; Select_ { options:["Off","Manual","Automatic"] } }
        }
    }}

    Component { id: appearancePanel; Panel {
        Card { title:"Style"
            Row_ { label:"Night glass (dark mode)"; sub:"Dim the whole desktop"
                Toggle_ { on: Theme.dark; onToggled: (v)=>{ Theme.dark = v; Launcher.setGtkDark(v) } } }
            Sep {}
            Row_ { label:"Accent colour"
                Row { spacing:8
                    Repeater { model:[Theme.teal, Theme.aqua, Theme.leaf, Theme.violet, Theme.warm]
                        delegate: Rectangle { required property var modelData; width:22;height:22;radius:11;color:modelData
                            border.color:Qt.rgba(1,1,1,0.6); border.width:1 } } } }
        }
        Card { title:"Wallpaper"
            Row_ { label:"Background"; Select_ { options:["Aurora","Ocean","Meadow","Solid"] } }
            Row_ { label:"Animated bokeh"; Toggle_ { on:true } }
        }
        Card { title:"Dock"
            Row_ { label:"Auto-hide dock"; Toggle_ { on:false } }
            Row_ { label:"Icon size"; Slider_ { value:0.6; width:180 } }
        }
    }}

    Component { id: notifPanel; Panel {
        Card { title:"Notifications"
            Row_ { label:"Do Not Disturb"; Toggle_ { on:false } }
            Row_ { label:"Lock screen notifications"; Toggle_ { on:true } }
            Row_ { label:"Notification banners"; Toggle_ { on:true } }
        }
        Card { title:"Per-app"
            Row_ { label:"Aqua Web"; Toggle_ { on:true } }
            Row_ { label:"Mail"; Toggle_ { on:true } }
            Row_ { label:"Music"; Toggle_ { on:false } }
        }
    }}

    Component { id: soundPanel; Panel {
        id: sp
        Component.onCompleted: {
            var o = Launcher.run("wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print $2}'")
            var v = parseFloat(o); if (!isNaN(v)) outVol.value = Math.min(1, v)
        }
        Card { title:"Output"
            Row_ { label:"Output volume"
                Slider_ { id: outVol; value:0.65; width:180
                    onMoved: (v)=> Launcher.launch("wpctl set-volume @DEFAULT_AUDIO_SINK@ " + Math.round(v*100) + "%") } }
            Row_ { label:"Mute"; Toggle_ { on:false; onToggled:(v)=> Launcher.launch("wpctl set-mute @DEFAULT_AUDIO_SINK@ " + (v?"1":"0")) } }
            Row_ { label:"Output device"; Select_ { options:["Speakers","Headphones","HDMI"] } }
        }
        Card { title:"Input"
            Row_ { label:"Input volume"; Slider_ { value:0.5; width:180 } }
            Row_ { label:"Alert sound"; Select_ { options:["Drip","Bubble","Glass","None"] } }
        }
    }}

    Component { id: powerPanel; Panel {
        id: pp
        property string batt: "—"
        Component.onCompleted: {
            var o = Launcher.run("cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1")
            batt = o.trim().length ? o.trim()+"%" : "On AC power"
        }
        Card { title:"Power"
            Row_ { label:"Battery"; Text{text:pp.batt; color:Theme.inkSoft; font.pixelSize:13} }
            Row_ { label:"Power mode"; Select_ { options:["Balanced","Power Saver","Performance"] } }
            Row_ { label:"Blank screen after"; Select_ { options:["5 min","10 min","15 min","Never"]; idx:1 } }
            Row_ { label:"Automatic suspend"; Toggle_ { on:false } }
        }
    }}

    Component { id: displaysPanel; Panel {
        Card { title:"Display"
            Row_ { label:"Resolution"; Select_ { options:["1280×800","1360×768","1920×1080"]; idx:1 } }
            Row_ { label:"Scale"; Select_ { options:["100%","125%","150%","200%"] } }
            Row_ { label:"Night light"; Toggle_ { on:false } }
        }
    }}

    Component { id: mousePanel; Panel {
        Card { title:"Mouse"
            Row_ { label:"Pointer speed"; Slider_ { value:0.5; width:180 } }
            Row_ { label:"Natural scrolling"; Toggle_ { on:true } }
        }
        Card { title:"Touchpad"
            Row_ { label:"Tap to click"; Toggle_ { on:true } }
            Row_ { label:"Two-finger scroll"; Toggle_ { on:true } }
        }
    }}

    Component { id: keyboardPanel; Panel {
        Card { title:"Typing"
            Row_ { label:"Repeat delay"; Slider_ { value:0.4; width:180 } }
            Row_ { label:"Repeat speed"; Slider_ { value:0.6; width:180 } }
            Row_ { label:"Show on-screen keyboard"; Toggle_ { on:false } }
        }
        Card { title:"Shortcuts"
            Row_ { label:"Launcher"; Text{text:"Super"; color:Theme.inkSoft; font.pixelSize:13} }
            Row_ { label:"Terminal"; Text{text:"Super+Return"; color:Theme.inkSoft; font.pixelSize:13} }
        }
    }}

    Component { id: regionPanel; Panel {
        Card { title:"Region & Language"
            Row_ { label:"Language"; Select_ { options:["English (US)","English (UK)","Français","日本語","Español"] } }
            Row_ { label:"Format"; Select_ { options:["United States","United Kingdom","Japan"] } }
            Row_ { label:"Temperature"; Select_ { options:["Fahrenheit","Celsius"] } }
        }
    }}

    Component { id: datetimePanel; Panel {
        id: dt
        property string now: Qt.formatDateTime(new Date(), "dddd, MMMM d  ·  hh:mm")
        Timer { interval:1000; running:true; repeat:true; onTriggered: dt.now = Qt.formatDateTime(new Date(), "dddd, MMMM d  ·  hh:mm") }
        Card { title:"Date & Time"
            Row_ { label:"Current"; Text{text:dt.now; color:Theme.inkSoft; font.pixelSize:13} }
            Row_ { label:"Automatic date & time"; Toggle_ { on:true } }
            Row_ { label:"24-hour time"; Toggle_ { on:true } }
            Row_ { label:"Time zone"; Select_ { options:["Auto","UTC","US/Pacific","US/Eastern","Europe/London"] } }
        }
    }}

    Component { id: a11yPanel; Panel {
        Card { title:"Seeing"
            Row_ { label:"Large text"; Toggle_ { on:false } }
            Row_ { label:"High contrast"; Toggle_ { on:false } }
            Row_ { label:"Cursor size"; Slider_ { value:0.3; width:180 } }
        }
        Card { title:"Hearing & Interaction"
            Row_ { label:"Screen reader"; Toggle_ { on:false } }
            Row_ { label:"Sticky keys"; Toggle_ { on:false } }
        }
    }}

    Component { id: privacyPanel; Panel {
        Card { title:"Privacy"
            Row_ { label:"Location services"; Toggle_ { on:false } }
            Row_ { label:"Camera access"; Toggle_ { on:true } }
            Row_ { label:"Microphone access"; Toggle_ { on:true } }
            Row_ { label:"Usage & diagnostics"; Toggle_ { on:false } }
        }
    }}

    Component { id: usersPanel; Panel {
        Card { title:"Users"
            Row_ { label:"jack"; sub:"Administrator · logged in"
                Rectangle{width:36;height:36;radius:18;gradient:Gradient{GradientStop{position:0;color:Theme.sky}GradientStop{position:1;color:Theme.aquaDeep}}
                    border.color:Qt.rgba(1,1,1,0.6);border.width:1} }
            Sep {}
            Row_ { label:"Automatic login"; Toggle_ { on:true } }
            Row_ { label:"Add user…" }
        }
    }}

    Component { id: appsPanel; Panel {
        Card { title:"Default Applications"
            Row_ { label:"Web"; Select_ { options:["Aqua Web","Firefox","Chromium"] } }
            Row_ { label:"Mail"; Select_ { options:["Mail","Thunderbird"] } }
            Row_ { label:"Terminal"; Select_ { options:["Terminal","gnome-terminal"] } }
            Row_ { label:"Files"; Select_ { options:["Files","Nautilus"] } }
        }
    }}

    Component { id: aboutPanel; Panel {
        id: ap
        property string osName:"GlassOS"; property string kernel:"—"; property string host:"—"
        property string mem:"—"; property string disk:"—"; property string cpu:"—"
        Component.onCompleted: {
            osName = "GlassOS 1.0  ·  " + Launcher.run(". /etc/os-release 2>/dev/null; printf %s \"$PRETTY_NAME\"").trim()
            kernel = Launcher.run("uname -r").trim()
            host   = Launcher.run("hostname").trim()
            cpu    = Launcher.run("nproc").trim() + " cores (" + Launcher.run("uname -m").trim() + ")"
            mem    = Launcher.run("free -h 2>/dev/null | awk '/Mem:/{print $2}'").trim()
            disk   = Launcher.run("df -h / 2>/dev/null | awk 'NR==2{print $4\" free of \"$2}'").trim()
        }
        Card {
            Item { width: parent.width; height: 90
                Rectangle { id: logo; width:64; height:64; radius:18; anchors.verticalCenter:parent.verticalCenter; x:8
                    gradient:Gradient{GradientStop{position:0;color:"#f2fffb"}GradientStop{position:1;color:"#6fdcc0"}}
                    border.color:Qt.rgba(1,1,1,0.6); border.width:1
                    Image{anchors.centerIn:parent;width:34;height:34;source:"glyphs/sprout.svg";sourceSize.width:68;sourceSize.height:68} }
                Column { anchors.left: logo.right; anchors.leftMargin:16; anchors.verticalCenter:parent.verticalCenter; spacing:2
                    Text{text:"GlassOS"; color:Theme.ink; font.family:Theme.fontFamily; font.pixelSize:24; font.bold:true}
                    Text{text:"Frutiger Aero, reborn"; color:Theme.inkSoft; font.family:Theme.fontFamily; font.pixelSize:13} }
            }
        }
        Card { title:"System"
            Row_ { label:"OS"; Text{text:ap.osName; color:Theme.inkSoft; font.pixelSize:13} }
            Row_ { label:"Kernel"; Text{text:ap.kernel; color:Theme.inkSoft; font.pixelSize:13} }
            Row_ { label:"Hostname"; Text{text:ap.host; color:Theme.inkSoft; font.pixelSize:13} }
            Row_ { label:"Processor"; Text{text:ap.cpu; color:Theme.inkSoft; font.pixelSize:13} }
            Row_ { label:"Memory"; Text{text:ap.mem; color:Theme.inkSoft; font.pixelSize:13} }
            Row_ { label:"Disk"; Text{text:ap.disk; color:Theme.inkSoft; font.pixelSize:13} }
        }
        Card { title:"GlassOS"
            Row_ { label:"Desktop"; Text{text:"GlassOS Shell (Qt6/QML)"; color:Theme.inkSoft; font.pixelSize:13} }
            Row_ { label:"Check for updates…" }
        }
    }}
}
