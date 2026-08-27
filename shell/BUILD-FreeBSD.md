# Building GlassOS on FreeBSD

This builds the **GlassOS shell** (Qt6/QML) and runs it as a Wayland session
on top of the **labwc** compositor. Tested target: FreeBSD 15.x / 14.x, aarch64,
in a virtualized VM (UTM on Apple Silicon).

> Heads-up: the shell was authored on macOS and **not compile-tested on FreeBSD**.
> Expect to fix a few small things on first build — that's normal for first bring-up.
> The visual tuning (blur strength, colors, spacing) is meant to happen on-device.

---

## 1. Install dependencies

```sh
doas pkg install -y \
    cmake ninja pkgconf \
    qt6-base qt6-declarative qt6-5compat qt6-svg \
    wayland wayland-protocols \
    labwc seatd foot
```

> On FreeBSD, QtQuick Controls ships inside `qt6-declarative` — there is no
> separate `qt6-quickcontrols2` package (installing it aborts the whole command).

- `qt6-5compat` provides `Qt5Compat.GraphicalEffects` (RadialGradient etc.)
- `qt6-svg` lets the square tiles load the SVG glyphs
- `labwc` is the wlroots compositor; `foot` is a Wayland terminal; `seatd` handles seat access

Enable seatd (needed to start a compositor from a TTY):

```sh
doas sysrc seatd_enable=YES
doas service seatd start
doas pw groupmod video -m "$USER"     # GPU access
doas pw groupmod seatd -m "$USER"     # if a seatd group exists
```

Log out/in (or reboot the VM) so the group changes take effect.

---

## 2. Build the shell

```sh
cd /path/to/GlassOS/shell
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
doas cmake --install build            # installs `glassos-shell` to /usr/local/bin
```

If `find_package(Qt6 ...)` fails, point CMake at the Qt6 prefix:

```sh
cmake -B build -G Ninja -DCMAKE_PREFIX_PATH=/usr/local/lib/qt6
```

---

## 3. Quick test (nested — easiest first run)

Run the shell inside your current session as a normal window before wiring it as
a full session. From a Wayland session:

```sh
glassos-shell
```

Or nested inside labwc (works even from an X session or another compositor):

```sh
labwc &
glassos-shell
```

You should see the animated wallpaper, the glass dock, and the launcher.

---

## 4. Install as a real session

```sh
# session launcher + labwc config
doas install -m 755 ../packaging/start-glassos.sh /usr/local/bin/start-glassos.sh
mkdir -p ~/.config/labwc
install -m 644 ../packaging/labwc/rc.xml       ~/.config/labwc/rc.xml
install -m 644 ../packaging/labwc/environment  ~/.config/labwc/environment

# make labwc autostart the shell
printf '%s\n' 'glassos-shell &' >> ~/.config/labwc/autostart
chmod +x ~/.config/labwc/autostart 2>/dev/null || true
```

### Start it from a TTY
```sh
start-glassos.sh
```

### Or add it to a login manager (SDDM/greetd)
Copy the session entry so the greeter lists "GlassOS":
```sh
doas install -m 644 ../packaging/glassos.desktop /usr/local/share/wayland-sessions/glassos.desktop
```

---

## 5. Troubleshooting

| Symptom | Fix |
|---|---|
| `module "Qt5Compat.GraphicalEffects" is not installed` | `pkg install qt6-5compat` |
| Square tiles show empty (no glyphs) | `pkg install qt6-svg` |
| `QT_QPA_PLATFORM` errors | try `export QT_QPA_PLATFORM="wayland;xcb"` |
| Compositor won't start from TTY | ensure `seatd` is running and you're in the `video`/`seatd` groups |
| No blur / looks flat | expected in a VM without GPU accel — enable virtio-gpu + virgl in UTM |
| Black screen, shell not visible | run `glassos-shell` directly to see QML errors on stderr |

---

## What's implemented (v1)
- Animated abstract Frutiger Aero wallpaper (drifting blobs, light sweep, bokeh)
- Glass dock with start orb, pinned square app tiles, tray, live clock
- Glass Start launcher (search field + square-tile app grid + power)
- Desktop icons
- Real app launching via `/bin/sh -c <exec>` (edit `qml/Apps.qml` to match installed apps)

## Not yet (next milestones)
- True per-window background blur (needs compositor-side blur — Hyprland-style)
- Night glass (dark mode)
- Window decorations themed to match
- FreeBSD **port/pkg** so it installs with `pkg install glassos`
