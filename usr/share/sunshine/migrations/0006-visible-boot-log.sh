#!/usr/bin/env bash
[ -d /run/archiso ] && exit 0
# Boot messages stay visible (loglevel 6, no quiet/splash): the path from GRUB to the desktop shows what the system is doing,
# and a boot that stops somewhere says where. Only the Sunshine default is changed; a command line the user edited is left alone.
[ -f /etc/default/grub ] || exit 0
line=$(grep -E '^GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub) || exit 0
case "$line" in *quiet*|*loglevel=3*|*splash*) ;; *) exit 0;; esac
cp -a /etc/default/grub /etc/default/grub.sunshine-bak
sed -i -E '/^GRUB_CMDLINE_LINUX_DEFAULT=/ { s/(^|[" ])quiet( |")/\1\2/; s/ splash( |")/\1/; s/loglevel=[0-9]/loglevel=6/; /loglevel=/! s/="/="loglevel=6 /; s/  +/ /g; s/=" +/="/; s/ +"$/"/ }' /etc/default/grub
command -v grub-mkconfig >/dev/null && [ -d /boot/grub ] && grub-mkconfig -o /boot/grub/grub.cfg >/dev/null 2>&1
echo "boot log made visible"
