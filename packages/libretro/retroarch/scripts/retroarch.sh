#!/bin/sh

/bin/mkdir -p /storage/emulators/retroarch/system
/bin/mkdir -p /storage/emulators/retroarch/screenshots

. /etc/profile

#oe_setup_addon emulator.tools.retroarch

systemd-run /usr/bin/retroarch.start "$@"
