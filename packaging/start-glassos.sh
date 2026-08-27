#!/bin/sh
# GlassOS session launcher.
# Starts the labwc Wayland compositor with the GlassOS shell as its "panel".

export XDG_CURRENT_DESKTOP=GlassOS
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
# Fallback to xcb if wayland platform plugin is unavailable:
# export QT_QPA_PLATFORM="wayland;xcb"

# Nice-to-haves for Qt on Wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_AUTO_SCREEN_SCALE_FACTOR=1

# labwc autostart runs the shell; keep this script alive as the session.
exec labwc -C "${HOME}/.config/labwc" -s "glassos-shell"
