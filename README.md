# argvus-taskbar-calendar

Native ARGVUS calendar popup for Wayland/Hyprland.

Version `0.1.0` provides a compact Relm4/GTK4 popup, layer-shell positioning for Waybar, SQLite storage, ICS import/export, configurable reminder scheduling with desktop notifications, and an internal CalDAV/WebDAV client foundation.

Arch packaging is owned by this repository through `packaging/arch/{ci,local}/PKGBUILD`.

## Commands

```bash
argvus-taskbar-calendar
argvus-taskbar-calendar toggle
argvus-taskbar-calendar show
argvus-taskbar-calendar hide
argvus-taskbar-calendar config
argvus-taskbar-calendar config-path
argvus-taskbar-calendar reload
argvus-taskbar-calendar import file.ics
argvus-taskbar-calendar export --output calendar.ics
argvus-taskbar-calendar sync
argvus-taskbar-calendar status
argvus-taskbar-calendar service
```

Waybar:

```json
"on-click": "/usr/lib/argvus-taskbar-calendar/waybar-launcher --root {x} {y}"
```

## Paths

- Config: `/etc/argvus/taskbar/calendar/config.toml` (system-wide; the package ships a default)
- Themes: `/etc/argvus/taskbar/calendar/style.css`, `/etc/argvus/taskbar/calendar/theme.css`, `/etc/argvus/taskbar/calendar/themes/`
- Data/database: `$XDG_DATA_HOME/argvus-taskbar-calendar/` or `~/.local/share/argvus-taskbar-calendar/`
- State: `$XDG_STATE_HOME/argvus/taskbar/calendar/` or `~/.local/state/argvus/taskbar/calendar/` (persisted events/reminders toggle in `events-enabled`)
- Cache: `$XDG_CACHE_HOME/argvus-taskbar-calendar/` or `~/.cache/argvus-taskbar-calendar/`

The active ARGVUS highlight color is read from
`$XDG_CONFIG_HOME/argvus/data/.accent-color` (or `~/.config/argvus/data/.accent-color`)
and is applied at runtime without replacing the selected theme.

## Configuration

All argvus-taskbar-calendar configuration lives in `/etc/argvus/taskbar/calendar/`. The application uses built-in defaults when `config.toml` is missing. Open the file for editing with:

```bash
argvus-taskbar-calendar config
```

This opens the file in a terminal with `sudo` (terminal from `$TERMINAL` or the `[terminal]` setting, editor from `$VISUAL`/`$EDITOR` or the `[editor]` setting, default `nano`).

Print the path with:

```bash
argvus-taskbar-calendar config-path
```

Example:

```toml
[appearance]
font_family = "monospace"
font_size = 12 # valid range: 8-32

[locale]
language = "auto" # auto (system language) | en-US | pt-BR

[calendar]
week_start = "monday" # monday | sunday
show_events = false # experimental; disabled until enabled in settings
default_event_duration_minutes = 60
default_reminder_minutes = 10
sync_interval_minutes = 15

[editor]
command = "" # falls back to $VISUAL, then $EDITOR, then nano
args = []

[terminal]
command = "" # falls back to $TERMINAL, then kitty
args = []
```

The gear button opens the same config file. The popup reloads the config on each restart; `reload` refreshes the external CSS/theme on the running popup.

## Current Notes

- The popup is a single-instance layer-shell surface: it stays running after hiding, so `toggle`/`show`/`hide` go through a UNIX socket IPC (`$XDG_CACHE_HOME/argvus-taskbar-calendar/`). Argvus Waybar supplies `{x_root}`/`{y_root}` from the original button event relative to its surface; the launcher adds the stable layer origin and forwards immutable desktop coordinates through IPC. The popup opens at that fixed X coordinate and 12 pixels below the click. It closes when you click anywhere outside it, click the date again, press Escape, or when it loses focus.
- The experimental events section starts disabled, is controlled by the in-window toggle and is persisted in `$XDG_STATE_HOME/argvus/taskbar/calendar/events-enabled` (default `~/.local/state/argvus/taskbar/calendar/events-enabled`); `show_events` remains only as a legacy/config fallback.
- Local non-recurring events are automatically removed 10 minutes after they end. CalDAV, ICS and recurring events are preserved. New events cannot be created on past dates.
- Events notify at their start time. Additional reminders can be configured in hours and minutes before the start; all-day events can additionally repeat their notification at a chosen interval during the day.
- All-day events run from local midnight to the following midnight; start and end time controls are disabled while `ALL DAY` is active.
- CalDAV support is implemented as a maintained internal HTTP/XML client foundation. Account management and full DB reconciliation are the next integration step.
- Reminders are reliable when `argvus-taskbar-calendar service` is running, or when installed as the provided user systemd service.
- Provider-specific account setup, such as Google Calendar and assisted Nextcloud setup, is planned for `0.2`.
- The `auto` language follows the operating system locale: Portuguese when the system is set to `pt-*`, English otherwise. An explicit `en-US` or `pt-BR` in the settings always wins.
- Styling is external: `/etc/argvus/taskbar/calendar/style.css` provides structure, `/etc/argvus/taskbar/calendar/theme.css` provides the packaged default, `/etc/argvus/taskbar/calendar/themes/` contains ARGVUS themes, and `$XDG_CACHE_HOME/argvus-taskbar-calendar/theme.css` is the user-level active theme written by the ARGVUS theme switcher.
- Supported ARGVUS themes include all official theme families and modes, including ARGVUS GitHub Light and ARGVUS Solarized Light. Theme CSS is selected generically from `/etc/argvus/taskbar/calendar/themes/` by the active theme ID.
