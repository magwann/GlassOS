# Running GlassOS on Ubuntu (aarch64, tested in UTM)

Ubuntu ships a virtio-GPU with working DRM, so the shell displays natively
(FreeBSD aarch64 lacks the GPU driver — see repo history).

## Install
```sh
sudo apt install -y build-essential cmake ninja-build pkg-config git \
  qt6-base-dev qt6-declarative-dev qt6-wayland libqt6svg6 \
  qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-window \
  qml6-module-qtquick-templates qml6-module-qtquick-layouts \
  qml6-module-qtqml-workerscript qml6-module-qt5compat-graphicaleffects \
  libgl1-mesa-dev libegl1-mesa-dev sway grim \
  foot pcmanfm-qt gnome-calculator epiphany-browser eog

cd shell && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release && cmake --build build
sudo cp build/glassos-shell /usr/local/bin/

sudo mkdir -p /etc/glassos
sudo cp ../packaging/ubuntu/sway.conf /etc/glassos/sway.conf
sudo cp ../packaging/ubuntu/glassos-session /usr/local/bin/ && sudo chmod +x /usr/local/bin/glassos-session
sudo cp ../packaging/ubuntu/glassos.desktop /usr/share/wayland-sessions/
```
Then pick **GlassOS** at the GDM login screen, or set it as the default session.

## Notes / gotchas (virtio-GPU, Qt 6.2)
- No `clip:true` and no backdrop blur — both render black on virgl/GL-2.1.
- Theme/Apps are C++ context properties (QML singletons miscompile on Qt 6.2).
- `WLR_NO_HARDWARE_CURSORS=1` fixes an upside-down cursor.
- Shell window is `Window.Windowed` (not FullScreen) so launched apps show on top.
