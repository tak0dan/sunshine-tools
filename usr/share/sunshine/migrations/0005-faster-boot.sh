#!/usr/bin/env bash
# The live image's systemd-networkd and the "wait until the network is online" units make an installed desktop wait up to two minutes at every
# boot (NetworkManager does the networking, and a desktop does not need to wait for it). Switch them off when NetworkManager is the network service.
[ -d /run/archiso ] && exit 0
systemctl is-enabled --quiet NetworkManager 2>/dev/null || exit 0
changed=
for u in systemd-networkd-wait-online.service NetworkManager-wait-online.service systemd-networkd.service systemd-networkd.socket; do
  if systemctl is-enabled --quiet "$u" 2>/dev/null; then systemctl disable "$u" >/dev/null 2>&1; changed="$changed $u"; fi
done
systemctl mask systemd-networkd-wait-online.service >/dev/null 2>&1
[ -n "$changed" ] && echo "boot no longer waits for the network; switched off:$changed"
exit 0
