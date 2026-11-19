#!/usr/bin/env bash
# Three wrong passwords lock the account for 10 minutes by default; ten wrong passwords and five minutes is still safe and far less annoying.
f=/etc/security/faillock.conf
[ -f "$f" ] || exit 0
grep -qE '^\s*deny\s*=' "$f" && exit 0                 # the user chose a value: leave it
printf '\n# Sunshine OS: less strict than the default of 3\ndeny = 10\nunlock_time = 300\n' >> "$f"
echo "faillock: 10 attempts, 5 minutes"
exit 0
