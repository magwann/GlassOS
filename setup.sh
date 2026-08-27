#!/bin/sh
# GlassOS first-time setup on FreeBSD: installs everything needed to build & run.
# Usage:  ./setup.sh    (run once on a fresh VM)
set -e

# pick a privilege tool
if command -v doas >/dev/null 2>&1; then SU=doas
elif command -v sudo >/dev/null 2>&1; then SU=sudo
else SU=""; fi

echo ">> Installing GlassOS dependencies..."
$SU pkg install -y \
    cmake ninja pkgconf \
    qt6-base qt6-declarative qt6-quickcontrols2 qt6-5compat qt6-svg \
    wayland wayland-protocols \
    labwc seatd foot

echo ">> Enabling seatd (needed to start the compositor)..."
$SU sysrc seatd_enable=YES
$SU service seatd start 2>/dev/null || true

echo ">> Adding $USER to the video/seatd groups..."
$SU pw groupmod video -m "$USER" 2>/dev/null || true
$SU pw groupmod seatd -m "$USER" 2>/dev/null || true

echo ""
echo ">> Done. Log out and back in (or reboot the VM) so group changes apply."
echo ">> Then:   cd shell && ./run.sh"
