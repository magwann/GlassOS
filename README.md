# GlassOS

The cleanest FreeBSD desktop — **Frutiger Aero**, reborn for 2026. Live glass
everywhere, an abstract aquatic-light wallpaper, and every app icon contained in
one consistent rounded-square tile.

![status](https://img.shields.io/badge/status-early%20bring--up-blue)

## What's here

| Path | What |
|---|---|
| `index.html` · `style.css` · `app.js` | **Web prototype** — the design lab. Open `index.html` in any browser. |
| `shell/` | **Native shell** — Qt6/QML desktop shell for FreeBSD. |
| `packaging/` | labwc session config, session launcher, `.desktop` entry. |
| `shell/BUILD-FreeBSD.md` | Full build + install guide. |

## Try the prototype (any machine)
Open `index.html` in a browser. Click the orb, launch apps, drag windows.

## Build the real shell (FreeBSD, aarch64)
```sh
# one-time deps
doas pkg install -y cmake ninja pkgconf qt6-base qt6-declarative \
    qt6-quickcontrols2 qt6-5compat qt6-svg wayland labwc seatd foot

# build + run
cd shell
./run.sh
```
See `shell/BUILD-FreeBSD.md` for the full guide and troubleshooting.

## Stack
Qt6/QML shell on a **labwc** (wlroots) Wayland compositor. The shell provides all
the branded glass chrome (wallpaper, dock, launcher, tray); real apps open as
normal Wayland windows.

## Roadmap
- [ ] First clean build on FreeBSD
- [ ] Night glass (dark mode)
- [ ] True per-window background blur (blur-capable compositor)
- [ ] Themed window decorations
- [ ] FreeBSD port/pkg (`pkg install glassos`)
