#!/usr/bin/env bash
# Install (or `./install.sh --uninstall`) lid-awake for the current user.
set -euo pipefail
cd "$(dirname "$0")"
BIN="$HOME/.local/bin" SHARE="$HOME/.local/share/lid-awake"
UNITS="$HOME/.config/systemd/user" SVC=lid-awake-tray.service
OLD_AUTOSTART="$HOME/.config/autostart/lid-awake-tray.desktop"  # from older installs

stop_tray() {
  systemctl --user disable --now "$SVC" 2>/dev/null || true
  pkill -f '^(/usr/bin/)?python3 .*/lid-awake-tray$' 2>/dev/null || true
}

if [ "${1:-}" = "--uninstall" ]; then
  "$BIN/lid-awake" off >/dev/null 2>&1 || true
  stop_tray
  rm -f "$BIN/lid-awake" "$BIN/lid-awake-tray" "$UNITS/$SVC" "$OLD_AUTOSTART"
  rm -rf "$SHARE"
  systemctl --user daemon-reload
  echo "lid-awake uninstalled"; exit 0
fi

mkdir -p "$BIN" "$SHARE" "$UNITS"
install -m755 lid-awake lid-awake-tray "$BIN/"
install -m644 icons/*.svg "$SHARE/"
rm -f "$OLD_AUTOSTART"
cat > "$UNITS/$SVC" <<UNIT
[Unit]
Description=lid-awake tray icon
PartOf=graphical-session.target
After=graphical-session.target

[Service]
ExecStart=$BIN/lid-awake-tray
Restart=on-failure
RestartSec=3

[Install]
WantedBy=graphical-session.target
UNIT

stop_tray
systemctl --user daemon-reload
systemctl --user enable --now "$SVC"
echo "lid-awake installed; tray icon running as $SVC (starts with your graphical session)"
