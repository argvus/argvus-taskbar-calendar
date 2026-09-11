#!/usr/bin/env sh
#
# Installs argvus-taskbar-calendar system-wide, mirroring the Arch PKGBUILD:
#   - /usr/bin/argvus-taskbar-calendar
#   - /usr/lib/argvus-taskbar-calendar/waybar-launcher
#   - /etc/argvus/taskbar/calendar/{config.toml, style.css, theme.css, themes/*.css}
#   - /usr/lib/systemd/user/argvus-taskbar-calendar.service
#   - /usr/share/licenses/argvus-taskbar-calendar/LICENSE
#
# Existing files under /etc/argvus/taskbar/calendar are backed up to file~ before
# being overwritten, so local edits survive reinstallation.
#
# Requires root. Run as: sudo tools/install.sh

set -eu

BINDIR=/usr/bin
LIBEXECDIR=/usr/lib/argvus-taskbar-calendar
ETCDIR=/etc/argvus/taskbar/calendar
THEMEDIR="$ETCDIR/themes"
UNITDIR=/usr/lib/systemd/user
LICDIR=/usr/share/licenses/argvus-taskbar-calendar

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

if [ "$(id -u)" -ne 0 ]; then
    echo "error: run as root (sudo tools/install.sh)" >&2
    exit 1
fi

if [ ! -x "$ROOT/target/release/argvus-taskbar-calendar" ]; then
    echo "error: $ROOT/target/release/argvus-taskbar-calendar not found; run 'make build' first" >&2
    exit 1
fi

install -Dm755 "$ROOT/target/release/argvus-taskbar-calendar" "$BINDIR/argvus-taskbar-calendar"
install -Dm755 "$ROOT/resources/argvus-taskbar-calendar-waybar" \
    "$LIBEXECDIR/waybar-launcher"

mkdir -p "$THEMEDIR"
install -m644 -b "$ROOT/resources/config.toml" "$ETCDIR/config.toml"
install -m644 -b "$ROOT/resources/style.css" "$ETCDIR/style.css"
install -m644 -b "$ROOT/resources/theme.css" "$ETCDIR/theme.css"
install -m644 -b "$ROOT/resources/themes/"*.css "$THEMEDIR/"

install -Dm644 "$ROOT/docs/systemd/argvus-taskbar-calendar.service" \
    "$UNITDIR/argvus-taskbar-calendar.service"
install -Dm644 "$ROOT/LICENSE" "$LICDIR/LICENSE"

echo "argvus-taskbar-calendar installed."
echo "Restart the user service with: systemctl --user restart argvus-taskbar-calendar"
