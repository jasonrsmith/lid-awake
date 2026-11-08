# lid-awake ☕

An opt-in "keep running with the lid closed" mode for Linux laptops.

When it's **on**, closing the lid turns off the screen but does **not** suspend, so long-running jobs (builds, downloads, AI agents) keep going. When it's **off**, the lid behaves normally. Nothing changes system-wide: no root, no edits to `logind.conf`, and the mode ends on logout/reboot.

Includes a tray icon for the COSMIC panel (and any StatusNotifierItem tray): a **hollow cup** means off, a **full, steaming cup** means on.

## Install

```bash
git clone https://github.com/jasonrsmith/lid-awake
cd lid-awake
./install.sh            # ./install.sh --uninstall to remove
```

Requirements: systemd-logind, `python3` with `dbus-python` and PyGObject (`python3-dbus`, `python3-gi`), and an ACPI lid switch (`/proc/acpi/button/lid`). Tested on Pop!_OS 24.04 with COSMIC.

## Usage

```bash
lid-awake on | off | toggle | status
```

Tray icon (COSMIC):
- **Right-click**: toggle. The menu opens to show the new state; press Esc to close it.
- **Left-click**: toggle, with no menu.

## How it works

- `lid-awake on` starts a transient systemd user unit (`lid-awake.service`) that runs `systemd-inhibit --what=handle-lid-switch:sleep`, so logind ignores the lid and won't sleep. Because it's its own unit, closing the terminal or app that turned it on doesn't end the mode. `lid-awake off` stops the unit.
- While the mode is on, a watcher checks the lid state every second. When the lid closes it sets the backlight to 0 through logind's `SetBrightness` (no root needed), and puts the brightness back when the lid opens.
- `lid-awake-tray` is a small StatusNotifierItem + dbusmenu service in Python. It runs as the `lid-awake-tray.service` systemd user service, starts with your graphical session, and restarts if it crashes. It checks the mode every 2 seconds, so changes made from the terminal show up in the tray.

⚠️ With the lid closed the laptop is fully awake and still makes heat. Don't put it in a bag while the mode is on.

## License

MIT
