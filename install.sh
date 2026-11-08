#!/usr/bin/env bash
# Install (or `./install.sh --uninstall`) lid-awake for the current user.
set -euo pipefail
cd "$(dirname "$0")"
BIN="$HOME/.local/bin" SHARE="$HOME/.local/share/lid-awake" AUTO="$HOME/.config/autostart"

stop_tray() { pkill -f '^(/usr/bin/)?python3 .*/lid-awake-tray$' 2>/dev/null || true; }

if [ "${1:-}" = "--uninstall" ]; then
  "$BIN/lid-awake" off >/dev/null 2>&1 || true
  stop_tray
  rm -f "$BIN/lid-awake" "$BIN/lid-awake-tray" "$AUTO/lid-awake-tray.desktop"
  rm -rf "$SHARE"
  echo "lid-awake uninstalled"; exit 0
fi

mkdir -p "$BIN" "$SHARE" "$AUTO"
install -m755 lid-awake lid-awake-tray "$BIN/"
install -m644 icons/*.svg "$SHARE/"
cat > "$AUTO/lid-awake-tray.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Lid Awake Tray
Comment=Tray toggle for keeping the laptop running with the lid closed
Exec=$BIN/lid-awake-tray
Icon=$SHARE/cup-full-symbolic.svg
X-GNOME-Autostart-enabled=true
DESKTOP

stop_tray
setsid "$BIN/lid-awake-tray" >/dev/null 2>&1 < /dev/null &
echo "lid-awake installed; tray icon started (and will autostart on login)"
