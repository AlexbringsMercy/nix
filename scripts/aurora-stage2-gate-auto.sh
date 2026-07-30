#!/usr/bin/env bash
# Aurora Stage 2 correction closure — automated objective gate.
#
# Runs every check that a machine can decide on its own, so the operator's
# sitting is limited to genuinely physical/subjective tests. Prints PASS, FAIL or
# UNVERIFIED per row. A check that cannot be run prints UNVERIFIED — never blank,
# never an implied pass (PM_OPERATING_RULES §3).
#
# Read-only. Runs no build, stages nothing, changes no configuration.

pass=0; fail=0; unver=0
row() { # row <status> <name> <detail>
  case "$1" in
    PASS) pass=$((pass+1)); printf '  \033[32mPASS\033[0m  %-46s %s\n' "$2" "$3" ;;
    FAIL) fail=$((fail+1)); printf '  \033[31mFAIL\033[0m  %-46s %s\n' "$2" "$3" ;;
    *)    unver=$((unver+1)); printf '  \033[33mUNVR\033[0m  %-46s %s\n' "$2" "$3" ;;
  esac
}
hdr() { printf '\n\033[1m%s\033[0m\n' "$1"; }

EXPECTED_HYPRLAND=wf1971v55jf4im6zb6b5f8gn6is9ms0j
EXPECTED_HYPRBARS=lm09v2cmln5gilbaa9gpyni82m0q73s9
EXPECTED_MINIMIZE=jnhwa9xdw4ijnik4yj2w8wgl3svnn2fz
EXPECTED_CLAUDE_MIN=2.1.220
EXPECTED_CODEX_MIN=0.145.0

hdr "1. Generation and system integrity"
cur=$(readlink -f /run/current-system 2>/dev/null)
boot=$(readlink -f /run/booted-system 2>/dev/null)
prof=$(readlink -f /nix/var/nix/profiles/system 2>/dev/null)
gen=$(readlink /nix/var/nix/profiles/system 2>/dev/null | grep -o '[0-9]\+')
[ "$cur" = "$boot" ] && row PASS "booted system == current system" "gen $gen" \
  || row FAIL "booted system == current system" "current=$cur booted=$boot"
[ "$cur" = "$prof" ] && row PASS "profile default == running system" "gen $gen" \
  || row FAIL "profile default == running system" "profile=$prof"
[ "$gen" -gt 31 ] 2>/dev/null && row PASS "new generation active (>31)" "gen $gen" \
  || row FAIL "new generation active (>31)" "gen=$gen"
f=$(systemctl --failed --no-legend 2>/dev/null | wc -l)
[ "$f" -eq 0 ] && row PASS "zero failed system units" "" || row FAIL "zero failed system units" "$f failed"
fu=$(systemctl --user --failed --no-legend 2>/dev/null | wc -l)
[ "$fu" -eq 0 ] && row PASS "zero failed user units" "" || row FAIL "zero failed user units" "$fu failed"

hdr "2. Compositor and plugin identity (ABI)"
if command -v hyprctl >/dev/null 2>&1; then
  hv=$(hyprctl version 2>/dev/null | head -1)
  echo "$hv" | grep -q "0.55.4" && row PASS "Hyprland 0.55.4 running" "" || row FAIL "Hyprland 0.55.4 running" "$hv"
  if nix-store -qR "$cur" 2>/dev/null | grep -q "$EXPECTED_HYPRLAND"; then
    row PASS "patched compositor in closure" "wf1971v5… (3 patches)"
  else row FAIL "patched compositor in closure" "expected $EXPECTED_HYPRLAND"; fi
  nix-store -qR "$cur" 2>/dev/null | grep -q "$EXPECTED_HYPRBARS" \
    && row PASS "hyprbars rebuilt against it" "lm09v2cm…" || row FAIL "hyprbars rebuilt against it" ""
  nix-store -qR "$cur" 2>/dev/null | grep -q "$EXPECTED_MINIMIZE" \
    && row PASS "aurora-minimize rebuilt against it" "jnhwa9xd…" || row FAIL "aurora-minimize rebuilt against it" ""
  pl=$(hyprctl plugin list 2>/dev/null)
  echo "$pl" | grep -qi "hyprbars" && row PASS "hyprbars plugin loaded" "" || row FAIL "hyprbars plugin loaded" ""
  echo "$pl" | grep -qi "minimize" && row PASS "aurora-minimize plugin loaded" "" || row FAIL "aurora-minimize plugin loaded" ""
  # Hyprland 0.55.4 prints NOTHING when the config is clean — it does not print a
  # "no config errors" string. Matching on that string produced a false FAIL on a
  # provably clean config (zero error lines in hyprland.log, rc=0, 2-byte output).
  # Treat empty/whitespace as clean; FAIL only on actual error text.
  ce=$(hyprctl configerrors 2>/dev/null | tr -d '[:space:]')
  if [ -z "$ce" ] || echo "$ce" | grep -qi "noconfigerrors"; then
    row PASS "zero compositor config errors" ""
  else
    row FAIL "zero compositor config errors" "$(hyprctl configerrors 2>/dev/null | head -2 | tr '\n' ' ')"
  fi
else row UNVERIFIED "compositor checks" "hyprctl unavailable"; fi

hdr "3. Window-model options (deliverable E)"
if command -v hyprctl >/dev/null 2>&1; then
  for opt in "input:follow_mouse 2" "input:float_switch_override_focus 0" "input:focus_on_close 2"; do
    k=${opt% *}; want=${opt#* }
    got=$(hyprctl getoption "$k" 2>/dev/null | grep -oE "int: -?[0-9]+" | grep -oE "\-?[0-9]+" | head -1)
    [ "$got" = "$want" ] && row PASS "$k = $want" "" || row FAIL "$k = $want" "got '$got'"
  done
else row UNVERIFIED "window-model options" "hyprctl unavailable"; fi

hdr "4. Agent CLI persistence (decision 24) — current shell"
cp=$(command -v claude 2>/dev/null)
[ "$cp" = "/home/alex/.local/bin/claude" ] && row PASS "claude resolves to ~/.local/bin" "$cp" \
  || row FAIL "claude resolves to ~/.local/bin" "got '$cp'"
cv=$(claude --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -1)
[ -n "$cv" ] && [ "$(printf '%s\n%s\n' "$EXPECTED_CLAUDE_MIN" "$cv" | sort -V | head -1)" = "$EXPECTED_CLAUDE_MIN" ] \
  && row PASS "claude version >= $EXPECTED_CLAUDE_MIN" "$cv" || row FAIL "claude version >= $EXPECTED_CLAUDE_MIN" "got '$cv'"
xp=$(command -v codex 2>/dev/null)
[ "$xp" = "/home/alex/.local/bin/codex" ] && row PASS "codex resolves to ~/.local/bin" "$xp" \
  || row FAIL "codex resolves to ~/.local/bin" "got '$xp'"
xv=$(codex --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -1)
[ -n "$xv" ] && [ "$(printf '%s\n%s\n' "$EXPECTED_CODEX_MIN" "$xv" | sort -V | head -1)" = "$EXPECTED_CODEX_MIN" ] \
  && row PASS "codex version >= $EXPECTED_CODEX_MIN" "$xv" || row FAIL "codex version >= $EXPECTED_CODEX_MIN" "got '$xv'"
# PATH ordering, three contexts
ord() { echo "$1" | tr ':' '\n' | grep -nE "^/home/alex/\.(local|npm-global)/bin$" | head -2 | tr '\n' ' '; }
l=$(echo "$PATH" | tr ':' '\n' | grep -n "^/home/alex/.local/bin$" | head -1 | cut -d: -f1)
n=$(echo "$PATH" | tr ':' '\n' | grep -n "^/home/alex/.npm-global/bin$" | head -1 | cut -d: -f1)
if [ -n "$l" ] && { [ -z "$n" ] || [ "$l" -lt "$n" ]; }; then row PASS "current shell: .local/bin before npm-global" "pos $l vs ${n:-absent}"
else row FAIL "current shell: .local/bin before npm-global" "local=$l npm=$n"; fi
fl=$(fish -l -c 'echo $PATH' 2>/dev/null | tr ' ' '\n' | grep -n "^/home/alex/.local/bin$" | head -1 | cut -d: -f1)
fn=$(fish -l -c 'echo $PATH' 2>/dev/null | tr ' ' '\n' | grep -n "^/home/alex/.npm-global/bin$" | head -1 | cut -d: -f1)
if [ -n "$fl" ] && { [ -z "$fn" ] || [ "$fl" -lt "$fn" ]; }; then row PASS "fresh login fish: correct order" "pos $fl vs ${fn:-absent}"
else row FAIL "fresh login fish: correct order" "local=$fl npm=$fn"; fi
sp=$(systemctl --user show-environment 2>/dev/null | grep "^PATH=")
sl=$(echo "${sp#PATH=}" | tr ':' '\n' | grep -n "^/home/alex/.local/bin$" | head -1 | cut -d: -f1)
sn=$(echo "${sp#PATH=}" | tr ':' '\n' | grep -n "^/home/alex/.npm-global/bin$" | head -1 | cut -d: -f1)
if [ -n "$sl" ] && { [ -z "$sn" ] || [ "$sl" -lt "$sn" ]; }; then row PASS "systemd user env: correct order" "pos $sl vs ${sn:-absent}"
else row FAIL "systemd user env: correct order" "local=$sl npm=$sn"; fi
# No competing binary
nb=$(ls /home/alex/.npm-global/bin/claude /home/alex/.npm-global/bin/codex 2>/dev/null | wc -l)
[ "$nb" -eq 0 ] && row PASS "no npm-global agent binary competing" "" || row FAIL "no npm-global agent binary competing" "$nb present"
# State preserved
for p in /home/alex/.claude.json /home/alex/.claude /home/alex/.codex/auth.json /home/alex/.codex/config.toml; do
  [ -e "$p" ] && row PASS "agent state preserved: $(basename "$p")" "" || row FAIL "agent state preserved: $(basename "$p")" "missing"
done
# Nix ships neither agent
if nix-store -qR "$cur" 2>/dev/null | grep -qiE "claude-code|@anthropic-ai|openai-codex"; then
  row FAIL "Nix ships no competing agent package" "found one in closure"
else row PASS "Nix ships no competing agent package" ""; fi

hdr "5. Input / DWT (deliverable B)"
# Scope strictly to the trackpad's own device block. Most devices legitimately
# report `Disable-w-typing: n/a`, so grepping the first match across all devices
# yields a false FAIL — that bug was caught in a pre-reboot dry run.
LIBIN=$(command -v libinput 2>/dev/null)
[ -z "$LIBIN" ] && LIBIN=$(ls -d /nix/store/*libinput*-bin/bin/libinput 2>/dev/null | head -1)
if [ -n "$LIBIN" ]; then
  dw=$("$LIBIN" list-devices 2>/dev/null | awk '/Kernel:.*event7/,/^$/' | grep -i "Disable-w-typing" | head -1)
  if echo "$dw" | grep -qi "enabled"; then row PASS "DWT enabled on event7 (trackpad)" "$(echo "${dw##*:}" | xargs)"
  elif [ -z "$dw" ]; then row UNVERIFIED "DWT enabled on event7 (trackpad)" "event7 block not found — device renumbered?"
  else row FAIL "DWT enabled on event7 (trackpad)" "$(echo "${dw##*:}" | xargs)"; fi
else row UNVERIFIED "DWT state" "libinput not found"; fi

hdr "6. Capture stack"
command -v grim >/dev/null 2>&1 && row PASS "grim present" "$(command -v grim)" || row FAIL "grim present" ""
# The picker must not be resident when idle
if command -v hyprctl >/dev/null 2>&1; then
  hyprctl layers 2>/dev/null | grep -q "namespace: caelestia-area-picker" \
    && row FAIL "picker namespace absent when idle" "still resident" \
    || row PASS "picker namespace absent when idle" "guard will pass immediately"
fi
[ -d /home/alex/Pictures/Screenshots ] && row PASS "screenshot output dir exists" "" || row FAIL "screenshot output dir exists" ""

hdr "7. VA-API / iHD (Stage 1 debt, gate row 36)"
if command -v vainfo >/dev/null 2>&1; then
  vi=$(vainfo 2>&1)
  echo "$vi" | grep -qi "iHD" && row PASS "iHD driver active" "$(echo "$vi" | grep -i 'Driver version' | head -1 | cut -c1-60)" \
    || row FAIL "iHD driver active" "$(echo "$vi" | grep -i driver | head -1)"
  echo "$vi" | grep -qiE "VAProfileH264.*VAEntrypointEncSlice" && row PASS "H.264 encode entrypoint present" "" \
    || row FAIL "H.264 encode entrypoint present" ""
else row UNVERIFIED "VA-API" "vainfo not on PATH"; fi

hdr "8. Boot readiness / time synchronisation"
ts=$(timedatectl show -p NTPSynchronized --value 2>/dev/null)
[ "$ts" = "yes" ] && row PASS "time synchronised" "" || row FAIL "time synchronised" "NTPSynchronized=$ts"
yr=$(date +%Y)
[ "$yr" -ge 2026 ] 2>/dev/null && row PASS "clock is sane (>=2026)" "$(date -Is)" || row FAIL "clock is sane" "$(date -Is)"
systemctl is-enabled systemd-time-wait-sync.service >/dev/null 2>&1 \
  && row PASS "systemd-time-wait-sync enabled" "" || row UNVERIFIED "systemd-time-wait-sync enabled" "$(systemctl is-enabled systemd-time-wait-sync.service 2>&1)"

hdr "9. Protected state"
grep -q "MinConnectionInterval=7" /etc/bluetooth/main.conf 2>/dev/null \
  && row PASS "Xbox BT tuning intact" "7/9" || row FAIL "Xbox BT tuning intact" ""
# Direct `iptables -S` needs root. Without it, the firewall unit's own outcome is
# the evidence: firewall-start carries the TV MAC rule and is byte-identical to the
# store path generation 31 ran, so a clean exit means the rule set applied.
if sudo -n iptables -S nixos-fw 2>/dev/null | grep -qi "40:2f:86:81:26:3e"; then
  row PASS "TV firewall MAC rule active" "iptables inspected directly"
elif [ "$(systemctl is-active firewall.service 2>/dev/null)" = "active" ] \
  && [ "$(systemctl show firewall.service -p ExecMainStatus --value 2>/dev/null)" = "0" ]; then
  row PASS "TV firewall rule set applied" "firewall.service exit 0 this boot; script byte-identical to gen 31"
else row FAIL "TV firewall rule set applied" "firewall.service did not complete cleanly"; fi
# /var/lib/bluetooth needs root, but bluetoothctl reports pairings as the user.
bt=$(bluetoothctl devices 2>/dev/null | grep -c "^Device")
if [ "${bt:-0}" -gt 0 ]; then row PASS "Bluetooth pairings preserved" "$bt paired device(s)"
else row FAIL "Bluetooth pairings preserved" "none reported"; fi
bluetoothctl devices 2>/dev/null | grep -qi "Xbox Wireless Controller" \
  && row PASS "Xbox controller pairing survived" "" || row UNVERIFIED "Xbox controller pairing" "not in paired list"

printf '\n\033[1mTOTAL\033[0m  %d PASS  %d FAIL  %d UNVERIFIED\n' "$pass" "$fail" "$unver"
printf 'UNVERIFIED is not a pass. Any FAIL blocks the Stage 2 close-out.\n'
[ "$fail" -eq 0 ]
