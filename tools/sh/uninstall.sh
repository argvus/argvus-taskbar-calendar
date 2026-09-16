#!/usr/bin/env sh
#
# Removes argvus-taskbar-calendar installed by tools/sh/install.sh.
# Disables and stops the user service first.
#
# Requires root. Run as: sudo tools/sh/uninstall.sh

set -eu

BINDIR=/usr/bin
LIBEXECDIR=/usr/lib/argvus-taskbar-calendar
ETCDIR=/etc/argvus/taskbar/calendar
UNITDIR=/usr/lib/systemd/user
LICDIR=/usr/share/licenses/argvus-taskbar-calendar

if [ "$(id -u)" -ne 0 ]; then
    echo "error: run as root (sudo tools/sh/uninstall.sh)" >&2
    exit 1
fi

systemctl --user disable --now argvus-taskbar-calendar 2>/dev/null || true
systemctl --user daemon-reload 2>/dev/null || true

rm -f "$BINDIR/argvus-taskbar-calendar"
rm -f "$LIBEXECDIR/waybar-launcher"
rmdir "$LIBEXECDIR" 2>/dev/null || true
rm -f "$UNITDIR/argvus-taskbar-calendar.service"
rm -rf "$ETCDIR"
rm -rf "$LICDIR"

echo "argvus-taskbar-calendar uninstalled."
