#!/usr/bin/env bash
# [community] (merged into [extra] in 2024) and the testing/staging repositories break every database sync: take them out (a backup is kept).
changed=0
for r in community community-testing testing core-testing extra-testing multilib-testing staging; do
  grep -q "^\[$r\]" /etc/pacman.conf || continue
  cp -n /etc/pacman.conf /etc/pacman.conf.sunshine-backup
  sed -i "/^\[$r\]/,/^\[/{/^\[$r\]/d;/^\[/!d}" /etc/pacman.conf; changed=1
done
[ $changed = 1 ] && echo "obsolete repositories removed from pacman.conf"
exit 0
