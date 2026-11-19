#!/usr/bin/env bash
# The top bar no longer has the window title/buttons widget and is built from three panels. For every user whose saved layout still has the
# old widget: remove the widget files and rebuild the bar once at the next login (a self-deleting autostart entry).
rm -rf /usr/share/plasma/plasmoids/com.sunshineos.windowbar
for h in /home/*; do
  u=$(basename "$h"); rc=$h/.config/plasma-org.kde.plasma.desktop-appletsrc
  [ -f "$rc" ] && grep -q 'com.sunshineos.windowbar' "$rc" || continue
  mkdir -p "$h/.config/autostart"
  cat > "$h/.config/autostart/sunshine-topbar-fix.desktop" <<'EOT'
[Desktop Entry]
Type=Application
Name=Sunshine top bar update
Exec=sh -c 'sleep 8; /usr/local/bin/sunshine-topbar --force; rm -f "$HOME/.config/autostart/sunshine-topbar-fix.desktop"'
X-KDE-autostart-phase=2
EOT
  chown "$u:$u" "$h/.config/autostart" "$h/.config/autostart/sunshine-topbar-fix.desktop" 2>/dev/null
  echo "top bar of $u will be rebuilt at the next login"
done
exit 0
