# Shared look of the Sunshine tools (source it):  . /usr/local/lib/sunshine/ui.sh
# say / ok / bad / sec           coloured lines (warm wording when cozy=on)
# t KEY                          the text for KEY in the selected language
# sun_run "label" command...     runs a command behind an ASCII graph animation; on success a short Sunshine animation, on failure the output (no animation)
[ -n "${SUN_UI_LOADED:-}" ] && return 0; SUN_UI_LOADED=1
SUN_CONF_SYS=/etc/sunshine/tools.conf; SUN_CONF_USER=${XDG_CONFIG_HOME:-${SUDO_USER:+$(getent passwd "$SUDO_USER" | cut -d: -f6)/.config}}; SUN_CONF_USER=${SUN_CONF_USER:-$HOME/.config}/sunshine/tools.conf
sun_conf() { local v; for f in "$SUN_CONF_USER" "$SUN_CONF_SYS"; do [ -r "$f" ] && v=$(sed -n "s/^$1=//p" "$f" | tail -1) && [ -n "$v" ] && { printf '%s' "$v"; return; }; done; printf '%s' "$2"; }
SUN_COZY=$(sun_conf cozy on); SUN_ANIM=$(sun_conf animation on); SUN_LANG=$(sun_conf language auto)
if [ "$SUN_LANG" = auto ]; then
  case "${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}" in uk*) SUN_LANG=uk ;; *) SUN_LANG=en ;; esac
  grep -qi '^city=.*toulouse' /etc/sunshine/install-location 2>/dev/null && SUN_LANG=uk
fi
declare -A T
if [ "$SUN_LANG" = uk ] && [ -r ${SUNSHINE_I18N:-/usr/share/sunshine/i18n}/uk.tsv ]; then
  while IFS=$'\t' read -r _k _v; do [ -n "$_k" ] && T[$_k]=$_v; done < ${SUNSHINE_I18N:-/usr/share/sunshine/i18n}/uk.tsv
fi
# loc "English text": exact match, or a "prefix*" entry (the rest of the text, usually a value, is kept)
loc() { local s=$* k; [ "$SUN_LANG" = en ] && { printf '%s' "$s"; return; }
  if [ -n "${T[$s]+x}" ]; then printf '%s' "${T[$s]}"; return; fi
  for k in "${!T[@]}"; do [[ $k == *'*' ]] && [[ $s == "${k%\*}"* ]] && { printf '%s%s' "${T[$k]%\*}" "${s#"${k%\*}"}"; return; }; done
  printf '%s' "$s"; }
t() { local k=$1; [ -n "${T[$k]+x}" ] && printf '%s' "${T[$k]}" || printf '%s' "${2:-$1}"; }
B=$'\e[1m'; Y=$'\e[38;5;220m'; O=$'\e[38;5;208m'; G=$'\e[32m'; R=$'\e[31m'; D=$'\e[2m'; N=$'\e[0m'
_cozy() { [ "$SUN_COZY" = on ] && printf '%s' "$1" || printf '%s' "$2"; }
sec() { printf '\n%s%s %s%s\n' "$Y$B" "$(_cozy ☀ '*')" "$(loc "$*")" "$N"; }
say() { sec "$@"; }
ok()  { printf '%s%s %s%s\n' "$G" "$(_cozy '✔ ☕' '+')" "$(loc "$*")" "$N"; }
bad() { printf '%s%s %s%s\n' "$R" "$(_cozy '✘ 🫖' 'x')" "$(loc "$*")" "$N"; }
cozy_done() { [ "$SUN_COZY" = on ] && printf '%s\n' "$Y$(t cozy_done 'All done. Have a warm cup of tea and enjoy the sunshine ☀️🍵')$N"; }
_sun_art() { cat <<'S'
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠰⣦⣄⠀⠀⠘⣧⡀⠀⣿⣿⠀⢀⣼⠃⠀⠀⣠⣴⠆⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠙⢿⣷⣤⡀⢻⡷⠀⠿⠿⠀⢾⡟⢀⣤⣾⡿⠋⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣀⠀⠀⠻⣿⠛⠀⢀⣠⣤⣤⣄⡀⠀⠛⣿⠟⠀⠀⣀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠉⠻⢿⡶⠀⢀⣾⣿⣿⣿⣿⣿⣿⣷⡀⠀⢶⡿⠟⠉⠀⠀⠀⠀⠀
⠀⢀⣀⣠⣤⣤⣤⣤⡄⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⢠⣤⣤⣤⣤⣄⣀⡀⠀
⠀⠈⠉⠙⠛⠛⠛⠛⠃⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠘⠛⠛⠛⠛⠋⠉⠁⠀
⠀⠀⠀⠀⠀⣀⣴⣾⠷⠀⠈⢿⣿⣿⣿⣿⣿⣿⡿⠁⠀⠾⣷⣦⣀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠉⠀⠀⣴⣿⣤⠀⠈⠙⠛⠛⠋⠁⠀⣤⣿⣦⠀⠀⠉⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣠⣾⡿⠛⠁⣼⡷⠀⣶⣶⠀⢾⣧⠈⠛⢿⣷⣄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠰⠟⠋⠀⠀⢠⡟⠁⠀⣿⣿⠀⠈⢻⡄⠀⠀⠙⠻⠆⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
S
}
# the Sunshine animation: a braille-drawn sun that pulses from deep orange to gold (drawn in place, then it stays)
sun_success_anim() {
  [ "$SUN_ANIM" = on ] && [ -t 1 ] || return 0
  local lines=() l i f n pal=(166 202 208 214 220 226 220 214 208 202) rows
  while IFS= read -r l; do lines+=("$l"); done < <(_sun_art); rows=${#lines[@]}
  printf '\e[?25l'
  for f in $(seq 0 23); do
    [ "$f" -gt 0 ] && printf '\e[%sA' "$rows"
    for i in "${!lines[@]}"; do
      n=$(( ( (i > rows/2 ? i - rows/2 : rows/2 - i) + f ) % ${#pal[@]} ))      # rings of colour travelling outwards
      printf '\e[38;5;%sm%s\e[0m\e[K\n' "${pal[$n]}" "${lines[$i]}"
    done
    sleep 0.07
  done
  printf '\e[?25h'
}
sun_run() {            # sun_run "label" cmd args...
  local label=$1; shift; local log; log=$(mktemp)
  if [ "$SUN_ANIM" != on ] || ! [ -t 1 ]; then printf '%s ...\n' "$label"; "$@" >"$log" 2>&1; local rc=$?; [ $rc -eq 0 ] && ok "$label" || { bad "$label"; tail -n 20 "$log"; }; rm -f "$log"; return $rc; fi
  "$@" >"$log" 2>&1 & local pid=$! i=0 h=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █ ▇ ▆ ▅ ▄ ▃ ▂) g
  printf '\e[?25l'
  while kill -0 "$pid" 2>/dev/null; do
    g=""; local k; for k in 0 1 2 3 4 5 6 7 8 9 10 11; do g+=${h[$(( (i + k * 3 + (k % 4) * 2) % ${#h[@]} ))]}; done
    printf '\r%s%s%s  %s' "$O" "$g" "$N" "$label"; i=$((i + 1)); sleep 0.09
  done
  wait "$pid"; local rc=$?; printf '\r\e[K\e[?25h'
  if [ $rc -eq 0 ]; then ok "$label"; else bad "$label"; tail -n 20 "$log"; fi
  rm -f "$log"; return $rc
}

# ---- internet check: several independent methods, so one blocked protocol never means "no internet" (ping alone is dropped by many networks,
# virtual machines and firewalls). sun_online returns 0 when ANY method works and sets SUN_NET_METHOD to the one that did; on failure SUN_NET_WHY
# says where it stops (link, route, DNS, HTTP, captive portal) so the message can be specific. sun_online_quick uses only the first method.
sun_online_quick() { curl -fsI --max-time "${1:-6}" https://archlinux.org >/dev/null 2>&1; }
sun_online() {
  SUN_NET_METHOD=; SUN_NET_WHY=
  local code body u
  # 1. the main test: an HTTPS request to the package site (works through proxies and everything a browser can reach)
  if sun_online_quick 6; then SUN_NET_METHOD="HTTPS archlinux.org"; return 0; fi
  # 2. the Arch mirror network and a second host, plain HTTP and HTTPS (a different server, different port)
  for u in https://geo.mirror.pkgbuild.com/ http://geo.mirror.pkgbuild.com/ https://www.gnu.org/; do
    if curl -fsI --max-time 6 "$u" >/dev/null 2>&1; then SUN_NET_METHOD="HTTP(S) $u"; return 0; fi
  done
  # 3. the connectivity-check pages browsers use: HTTP 204 = free internet; a redirect (30x) means a captive portal (a login page)
  for u in http://connectivity-check.ubuntu.com/ https://www.gstatic.com/generate_204 http://nmcheck.gnome.org/check_network_status.txt; do
    code=$(curl -s -o /dev/null --max-time 6 -w '%{http_code}' "$u" 2>/dev/null)
    case "$code" in 204) SUN_NET_METHOD="connectivity check $u"; return 0;; 30*) SUN_NET_WHY=portal;; esac
  done
  [ "$SUN_NET_WHY" = portal ] && return 1
  # 4. NetworkManager's own verdict
  if command -v nmcli >/dev/null 2>&1 && [ "$(nmcli -t networking connectivity check 2>/dev/null)" = full ]; then SUN_NET_METHOD="NetworkManager says full"; return 0; fi
  # 5. a raw TCP connection to public addresses (no DNS, no HTTP): proves the route works even if names do not resolve
  for u in 1.1.1.1:443 8.8.8.8:53 9.9.9.9:443; do
    if timeout 4 bash -c "exec 3<>/dev/tcp/${u%:*}/${u#*:}" 2>/dev/null; then SUN_NET_METHOD="TCP $u"; SUN_NET_WHY=dns-or-http; return 0; fi
  done
  # 6. last resort: ping
  for u in 1.1.1.1 8.8.8.8; do if ping -c1 -W3 "$u" >/dev/null 2>&1; then SUN_NET_METHOD="ping $u"; return 0; fi; done
  # nothing worked: find out where it stops
  if ! ip -4 route 2>/dev/null | grep -q '^default'; then SUN_NET_WHY=route
  elif ! getent hosts archlinux.org >/dev/null 2>&1; then SUN_NET_WHY=dns
  else SUN_NET_WHY=blocked; fi
  return 1
}
sun_net_explain() {   # a sentence for the user after sun_online failed
  case "${SUN_NET_WHY:-}" in
    route) loc "This computer is not connected to a network (no route). Connect to Wi-Fi or a cable and try again.";;
    dns) loc "Connected, but names do not resolve (DNS). Try: sunshine-fix network";;
    portal) loc "A login page (captive portal) is blocking the internet: open a browser and sign in to the network first.";;
    blocked) loc "A network is there but web requests do not get through (firewall, proxy or VPN?).";;
    *) loc "No internet connection. Connect to Wi-Fi or a cable and try again.";;
  esac
}
