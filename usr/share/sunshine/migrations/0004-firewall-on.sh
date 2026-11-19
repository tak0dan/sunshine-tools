#!/usr/bin/env bash
# A desktop should not answer connections nobody asked for: turn the firewall on with "deny incoming, allow outgoing" and open only what the
# desktop itself uses (KDE Connect, network discovery). Not in the live session, not when ufw is missing, and never if the user has already
# configured it (rules exist, or /etc/sunshine/no-firewall exists).
[ -d /run/archiso ] && exit 0
command -v ufw >/dev/null || exit 0
[ -e /etc/sunshine/no-firewall ] && exit 0
if ufw status 2>/dev/null | grep -q '^Status: active'; then exit 0; fi
if [ -s /etc/ufw/user.rules ] && grep -q '^### tuple' /etc/ufw/user.rules 2>/dev/null; then exit 0; fi      # the user has rules of their own
ufw --force reset >/dev/null 2>&1
ufw default deny incoming >/dev/null; ufw default allow outgoing >/dev/null
ufw allow 1714:1764/tcp comment 'KDE Connect' >/dev/null; ufw allow 1714:1764/udp comment 'KDE Connect' >/dev/null
ufw allow 5353/udp comment 'mDNS discovery' >/dev/null
ufw --force enable >/dev/null && systemctl enable ufw.service >/dev/null 2>&1
echo "firewall on: incoming denied except KDE Connect and discovery (sudo ufw status; sudo ufw allow PORT)"
exit 0
