# Stage 2B — keymap (launcher!), SwayOSD retire, input feel, shell.json

You are a Codex execution session for the Aurora build (NixOS + Hyprland 0.55.4, MacBook Air T2), working in `/home/alex/nix`. Your PM launches and reviews you; your final message is a report to them. **File work only — the PM builds, verifies, and deploys.** The window model (Stage 2A) is done; this session wires the keymap onto the running caelestia shell, retires SwayOSD, tunes input, and stops caelestia's config-write error.

## Mandatory reading, in order

1. `/home/alex/nix/SESSION_PREAMBLE.md` — in full; its rules bind you.
2. `/home/alex/nix/GRAND_PLAN.md` §6.2 (window/input spec, lines ~431–441) and §6.4 (the keymap table, lines ~447–467).
3. Current config: `modules/home/hyprland/hyprland/{keybinds,input,rules}.lua`, `modules/home/hyprland/default.nix`, `modules/home/packages.nix`, `home/alex/default.nix`, and the caelestia shell's `modules/home/aurora-shell/modules/Shortcuts.qml` (its `CustomShortcut` global names) and `nix/hm-module.nix` (how `shell.json` is written).

## Hard rules

- NO network, nix, git commit/push, systemctl, hyprctl, or live activation. Native Hyprland 0.55 Lua only — runtime actions are `hl.dsp.*` Lua forms; the legacy `hyprctl dispatch <word>` string form is REJECTED at runtime (2A learned this the hard way — every action you write must use a verified `hl.dsp.*` form or a plain shell command). `git` is read-only in your sandbox; leave edits for the PM to stage.
- `repos/` read-only. Minimal diffs, every changed line marked `-- Aurora:`/`# Aurora:`. Report honestly.

## Tasks

### 1. Keymap — put the caelestia surfaces on keys (§6.4)

caelestia registers Hyprland global shortcuts via `CustomShortcut` (app id `caelestia`), so bind them with `hl.dsp.global("caelestia:<name>")` (the same form `services/Hypr.qml` already uses for `caelestia:refreshDevices`). **Investigate `Shortcuts.qml` and report the exact `CustomShortcut` names** before binding. Then in `keybinds.lua`:
- **`SUPER + Space` → the launcher** (`hl.dsp.global("caelestia:launcher")`). This is the headline fix — today Super+Space is float-toggle. Move/remove the float-toggle bind (float toggle can go to a free chord like `SUPER + T`, or drop it — report your choice).
- Bind the other surfaces to their caelestia globals where a name exists: notifications/sidebar (`SUPER + N`), dashboard, session, utilities, nexus. Use the real names from Shortcuts.qml; if a surface has no CustomShortcut, use the drawers IPC (`caelestia shell ipc call drawers toggle <name>`) via `hl.dsp.exec_cmd` and say so.
- **Fix the broken power bind:** `CTRL + ALT + Delete` currently runs `qs -c aurora-shell ipc call panels toggle power` — that old-quickshell path no longer exists. Rebind to the caelestia session/power surface (`caelestia:session` global or the drawers IPC).
- Keep the existing Apps launcher entry (`SUPER`/`SUPER+D` currently → `rofi-toggle`) pointed at the caelestia launcher too, OR leave rofi as-is and report — but Super+Space MUST open the caelestia launcher.

### 2. Retire SwayOSD + rebind its keys onto the shell OSD (kills the double brightness OSD)

The shell owns volume/brightness/mic OSDs; SwayOSD draws a SECOND overlay. Remove it:
- `modules/home/hyprland/default.nix`: delete the `services.swayosd` block; remove the `swayosd.css` reference (and the file if now unused).
- `modules/home/packages.nix`: remove `swayosd`.
- `keybinds.lua`: rebind every `swayosd-client` key so the shell's own services observe the change and show the single OSD:
  - brightness up/down → `brightnessctl -d intel_backlight set 5%+` / `5%-` (the shell's Brightness service watches `intel_backlight`).
  - mic mute → `wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle`.
  - media play/pause/next/prev/stop → `playerctl play-pause` / `next` / `previous` / `stop` (the shell's MPRIS observes).
  - Volume keys already use `wpctl` — leave them.
- Grep the whole repo to confirm nothing else references swayosd after removal.

### 3. Input tuning (`input.lua`)

- `repeat_delay = 350`, `repeat_rate = 22` (currently 300/35 — too fast).
- `scroll_factor = 0.3` (touchpad block; currently 0.78 — too sensitive).
- Leave `follow_mouse = 0` (set in 2A) and `disable_while_typing = true` as-is. **Do NOT attempt the DWT libinput quirk** — that needs live device matching and is a PM follow-up; just leave the existing `disable_while_typing = true`.

### 4. Gestures (`input.lua`)

Keep the 3-finger horizontal workspace swipe. Add: **3-finger vertical → live volume** and **pinch → `cursor_zoom`** (native 0.55). Do NOT add 4-finger-up (hyprexpo, Stage 5) or 4-finger-down (sysmon, Stage 8). Verify the native-Lua gesture syntax against the existing `hl.gesture({...})` call.

### 5. `rules.lua` dead-namespace cleanup

The layer-blur rules still target retired namespaces (`waybar`, `rofi`, `swayosd`, `osd`, `notifications`, `quickshell:.*`). The live shell uses `caelestia-*` namespaces (caelestia manages its own blur for `caelestia-drawers` via `Colours.qml`). Remove the dead namespace rules; keep only what a live surface actually uses. Report what you removed and why it's dead.

### 6. Stop caelestia's "failed to save config" error

caelestia logs `Failed to write ~/.config/caelestia/shell.json: Read-only file system` because `programs.aurora-shell.settings` makes `shell.json` a read-only HM symlink, and caelestia tries to write it. Make it a **mutable** file the shell can write while still seeding our idle config: set `programs.aurora-shell.settings = { }` (so the HM module stops creating the read-only symlink) and add a `home.activation` step (after `writeBoundary`, like the `scheme.json` seed already in `hm-module.nix`) that writes `~/.config/caelestia/shell.json` **write-if-absent** with the current idle config (`general.idle.timeouts` lock@1200/dpms@1500). Report the exact activation snippet. Confirm the idle-lock config is preserved.

## Final report (raw data)

- The `CustomShortcut` global names you found and the exact keybind for each surface (especially Super+Space→launcher).
- Every edited/created file with quoted `Aurora:`-marked diffs.
- SwayOSD removal proof (no remaining references) and the rebind commands.
- The shell.json activation snippet + confirmation the idle config is kept.
- The rules.lua namespaces you removed.
- Anything you interpreted, deviated on, or left for the PM (incl. the DWT quirk).
