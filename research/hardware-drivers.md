# Hardware / Driver Research — MacBookAir9,1 (T2) on NixOS 26.11

**Session type:** L1 targeted hardware-truth research. Sources the community's known-good hardware/driver approaches; writes findings only. **No commands were run on the live machine** — every step that requires the physical machine is flagged as an **execution-time live-test**.

**Machine:** 2020 MacBook Air — MacBookAir9,1 — Intel i3 Ice Lake dual-core, Intel Iris Plus (Gen11 / i915), 8 GB LPDDR4X, Apple T2, Broadcom WiFi/BT (BCM4377-class), Apple internal keyboard/camera/speakers. Single 2560×1600 display @ 1.5× fractional scale. NixOS 26.11, Hyprland 0.55, QuickShell.

**Requirement mapping:** §4.4 boot · §4.6 gaming · §4.9 sounds · §10 HW invariants · §13 apps · A7 recorder · B4 audio lifecycle/in-use dots · B5 webcam · C4 speaker profile · C13 kbd-backlight intelligence · C14 t2fanrd · B17 kbd-backlight persistence/boot.

**Governing infrastructure fact (read this first — it frames items 1–3 and 8):** The whole T2 audio + camera + keyboard stack rides on **`nixos-hardware`'s `apple-t2` module**, which is the community-standard base for this exact machine. Verbatim options it exposes (from `apple/t2/default.nix`):

```nix
# flake input
inputs.nixos-hardware.url = "github:nixos/nixos-hardware";
# imported module
imports = [ nixos-hardware.nixosModules.apple-t2 ];

# options the module defines:
hardware.apple-t2.enableIGPU        = false;              # only for AMD-dGPU Macs; N/A here (Iris Plus only)
hardware.apple-t2.kernelChannel     = "stable";           # "stable" | "latest"  (T2-patched kernel)
hardware.apple-t2.firmware.enable   = true;               # declarative WiFi/BT firmware from a macOS recovery image
hardware.apple-t2.firmware.version  = "sonoma";           # "monterey" | "ventura" | "sonoma"
```

What the module does under the hood (all relevant to this session):
- Puts **`apple-bce`** in `boot.initrd.kernelModules` — the T2 bridge driver that brings up the **VHCI USB bus** (internal keyboard, trackpad, **camera**) and **BCE audio**.
- Builds and pins the **T2-patched kernel** (`linux-t2-patches`) via `kernelChannel`.
- **Overrides `services.pipewire.package` / `services.wireplumber.package` / `services.pulseaudio.package`** with T2-patched audio builds and installs **T2 audio udev rules** — this is the layer that makes the speakers/mic *exist* at all.
- Sets kernel params `intel_iommu=on iommu=pt pm_async=off`.
- Touch Bar handled via `hardware.apple.touchBar` (N/A — the Air has no Touch Bar).

> **Invariant interaction (§10):** The build already preserves `/etc/nixos/firmware/brcm` (163 files) via a **local non-Git adapter**. That is the *manual* equivalent of `hardware.apple-t2.firmware.enable`. **Do not enable both** — keep the working manual brcm adapter and leave `firmware.enable = false`, OR migrate to the declarative option, but not both. This is an execution-time decision; flag it. Everything below assumes `apple-bce` + the T2-patched PipeWire from this module are present, because they are the substrate for camera, speakers, and mic.

---

## 1. WEBCAM (B5) — internal T2 FaceTime camera · **GENUINE RISK ITEM**

### Community approach (known-good)
- **This is a T2 Mac, so the pre-T2 `facetimehd` path does NOT apply.** Do not follow the widely-linked "MacBook Air webcam on Linux" guides (e.g. Lorenzo Bettini's Nov-2025 post) — those are for the **Broadcom 1570 PCIe `[14e4:1570]`** camera in *pre-2018* Airs (2013–2017), driven by `facetimehd-dkms`. MacBookAir9,1 (2020) has **no `[14e4:1570]`**; its camera hangs off the T2.
- **Canonical status (the one authoritative T2-specific source):** the t2linux **State** page lists **Camera = "🟢 Working"**, upstream = "🔴 No", attributed to **`apple-bce`**, with **no separate firmware requirement**. On the community's own hardware matrix, the internal camera on 2018+ T2 Macs (incl. MacBookAir9,1) is a *solved* item, and the fix is "have `apple-bce` loaded" — which the base module already does.
- **BUT the precise driver mechanism is NOT documented, and I could not independently confirm it — flagging this honestly.** The plausible community mechanism is that the camera rides the `apple-bce` **VHCI USB bus as a standard UVC `/dev/video0` device** (driven by in-tree `uvcvideo`, no extra driver) — which would explain why there is **no dedicated camera repo or camera guide** in t2linux. **However:** the `apple-bce` README does **not** mention the camera at all (only keyboard/trackpad/audio); the apple-bce architecture docs list VHCI devices as "keyboard, touchpad, *other integrated USB devices*" **without naming the camera**; and the t2linux issue tracker surfaced **no** camera issues to corroborate real-world use. So "rides VHCI as UVC" is an **inference, not a verified fact.**
- **General web guidance does NOT apply here and actively misleads:** most "MacBook Air camera on Linux" material (and even several search summaries) describes the **pre-T2 Broadcom 1570 `[14e4:1570]` PCIe** camera + `facetimehd`/`facetimehd-dkms`. That is a *different machine*. Some of those sources flatly say "the camera doesn't work without reverse-engineered drivers" — true for the 1570 part, **not** evidence about MacBookAir9,1's T2 camera. Do not let that noise lower confidence in either direction; it's simply about other hardware.
- **Net:** the canonical matrix says *works*; the mechanism is under-documented and I found **no matching first-hand "MacBookAir9,1 camera live in Chrome/Meet" trip report**. Treat as **PROBABLE per the State page, UNCONFIRMED on this unit** — the live-test below is the real gate, not this paragraph.

### NixOS config shape
No camera-specific config beyond the base module. To make it testable and browser-usable:
```nix
# apple-bce is already in initrd via nixos-hardware apple-t2; nothing else required for the device node.
environment.systemPackages = with pkgs; [ mpv v4l-utils ];   # v4l2-ctl to inspect, mpv to view
# Chrome/Chromium on Wayland already present; camera reaches it through the normal V4L2 path.
```
There is **no VA-API/portal dependency for camera capture** — Chrome opens `/dev/video0` via V4L2 directly. (Contrast with mic-in-use detection in item 8, which *is* PipeWire-based.)

### Honest caveats (this is the trust-critical item — do not soft-pedal)
1. **State-page "🟢 Working" vs. driver silence.** `apple-bce`'s own README enumerates **keyboard/trackpad (VHCI) + audio output** and **does not name the camera at all**; the audio subsystem README says "currently only audio output is supported." The "working" claim rests on the camera riding VHCI as a UVC device, which is coherent but is **not independently reconfirmed in the driver docs**. Treat "works" as *probable, not proven*, until the live-test.
2. **Historically flaky.** The T2 camera was non-functional on Linux for years and is reverse-engineered support; community reports over time include **washed-out/overexposed image, wrong colors, or the node not enumerating until a reboot**.
3. **App-specific V4L2 quirks are real.** Even where the node works, some apps mis-handle the pixel format. Chrome/Chromium is the **most reliable** consumer (confirmed pattern across T2 + facetimehd reports); Firefox has historically been flakier at detection; native Qt/KDE camera apps can choke. **For Meet/Zoom-web, Chrome is the right target** and matches §11 (Chrome-on-Wayland is a keep).
4. **Suspend/resume can drop the bridge.** `apple-bce` master "does not currently support system suspend and resume"; a suspend cycle can leave the camera (and audio) needing a module reload. Relevant because a closed-lid laptop meeting is exactly the failure moment.

### Execution-time live-test (the real gate — run these on the machine)
```bash
# 1. Does the device enumerate?
ls -l /dev/video*            # expect /dev/video0 (+ maybe /dev/video1 metadata node)
v4l2-ctl --list-devices      # should name an Apple/FaceTime/UVC camera on the bridge
v4l2-ctl -d /dev/video0 --list-formats-ext   # confirm a usable format (YUYV/MJPG) + resolutions

# 2. Does it actually produce a correct image (color/exposure)?
mpv av://v4l2:/dev/video0    # or:  mpv /dev/video0
#   -> look for washed-out / green / upside-down frames = the historical caveat

# 3. Does Chrome (Wayland) see it for web calls?  Open chrome://settings/content/camera,
#    then https://webcamtests.com  or a Meet test call. Confirm selectable + live preview.

# 4. Suspend regression check: suspend, resume, re-run steps 1–3. If dead, test:
sudo modprobe -r apple-bce && sudo modprobe apple-bce   # does a reload restore it?
```
**Ship a "Test camera" affordance in the System group regardless of outcome** (per B5): a one-click action running `mpv av://v4l2:/dev/video0` (or a QuickShell camera-preview popup) so the user *verifies before a meeting*, never discovers breakage during one. If step 2/3 fails, the honest outcome is "camera is a known-risk item; use an external USB webcam as the reliable path" — say that plainly rather than declaring it fixed.

---

## 2. RECORDER BACKEND (A7) — choosing the encode engine under the chosen UI (§4.10)

### The decision is already half-made by the chosen UI
The capture UX is fixed: **ilyamiro region-select overlay + caelestia record lifecycle**. Reading the source settles the backend question:
- **caelestia `services/Recorder.qml` drives `gpu-screen-recorder`** verbatim: it polls `["pidof", "gpu-screen-recorder"]` and starts/stops/pauses via the `caelestia record` CLI (`Quickshell.execDetached(["caelestia", "record", ...])`). So the caelestia lifecycle **already expects gpu-screen-recorder** — picking it means **zero backend glue**.
- **iNiR uses `wf-recorder`** everywhere (`scripts/videos/record.sh`, `RegionSelection.qml`, `RecordingOsd.qml`) and its own settings UI warns: *"No GPU encoder detected. wf-recorder will use software encoding."* That warning is the whole story on a dual-core i3.

### Pick: **`gpu-screen-recorder` with VA-API** (H.264, `/dev/dri/renderD128`)
Rationale on Iris Plus (Gen11 / i915):
- **gpu-screen-recorder is the lowest-overhead recorder on Linux** ("Shadowplay-like," built for minimal CPU hit) and has **first-class Intel VA-API hardware encode** (Intel support added 2023). It offloads H.264/HEVC to the **Gen11 media engine**, keeping the two i3 cores free — decisive given the 8 GB / dual-core budget.
- **wf-recorder defaults to software x264**, which pegs both cores on a dual-core i3 (iNiR literally flags this). It *can* hardware-encode but only if explicitly told: `wf-recorder -c h264_vaapi -d /dev/dri/renderD128`.
- **OBS-class** is overkill here — the trigger is a clickable System-group button, not a streaming studio. Keep OBS available as an installable app (§13) for deliberate sessions, but it is **not** the quick-capture backend.

### NixOS config shape
```nix
environment.systemPackages = with pkgs; [ gpu-screen-recorder ];   # CLI backend the caelestia lifecycle calls

# VA-API stack for Iris Plus (also the accepted Chrome VA-API win, §9) — ensures the encode path exists:
hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [ intel-media-driver ];   # iHD driver — Gen11 uses intel-media-driver, NOT the old i965
};
environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
```
The caelestia `record` wrapper handles region/full/audio; point it at VA-API (its config selects encoder/`video_codec`; ensure `h264`/`hevc` with the VA-API path, not software). No new UI.

### Caveats
- **Wayland + Intel/AMD = monitor capture, not arbitrary window capture** in gpu-screen-recorder. Full-screen and **region** (crop of the monitor) are fine; per-*window* capture is limited. For the region UX this is acceptable (record monitor, crop to slurp geometry). **If native region proves fiddly on i915, the documented fallback is `wf-recorder -c h264_vaapi -d /dev/dri/renderD128 -g "$(slurp)"`** — hardware-encoded, region-native, at the cost of leaving the caelestia lifecycle (iNiR's path). Primary stays gpu-screen-recorder.
- **Gen11 encoder quality** is good for screen content at H.264; HEVC is available and smaller but heavier — default to H.264 for compatibility (Discord/web).
- Confirm `intel-media-driver` (iHD), **not** `intel-vaapi-driver` (i965) — Ice Lake/Gen11 needs iHD.

### Execution-time live-test
```bash
vainfo                                 # expect iHD driver + VAEntrypointEncSlice for H264/HEVC = hardware encode present
# quick encode sanity (10s), watch CPU in a second pane (btop):
gpu-screen-recorder -w screen -f 60 -c h264 -o /tmp/test.mp4     # Ctrl-C after ~10s; CPU should stay low
mpv /tmp/test.mp4                       # verify smooth 60fps, no tearing/artifacts
# Then drive it through the real UI (caelestia record) for region + audio, and confirm CPU stays off the ceiling.
```

---

## 3. T2 SPEAKER PROFILE (C4) — EasyEffects voicing to undo the flat/tinny Linux default (§4.9)

### Two distinct layers — don't conflate them
1. **Make speakers *work* / not blow them** = the **T2 audio config** layer, already provided by `nixos-hardware apple-t2`'s patched PipeWire + udev rules (and, on other distros, `kekrby/t2-better-audio`, which the wiki's audio guide installs). This layer also matters for **speaker safety** — the t2linux audio guide warns the per-model DSP configs must not be cross-applied: *"each model needs specific settings. Do not use it with other models as it could damage the speakers."*
2. **Make speakers *sound like macOS*** = an **EasyEffects output preset** on top. EasyEffects is already the invisible EQ backend (§6, §9). This is what C4 asks to ship as the default output preset.

### Honest truth about a MacBookAir9,1-specific profile
- **There is no t2linux-maintained speaker DSP tuned specifically for MacBookAir9,1.** Apple's real speaker tuning lives in macOS; the only *model-specific* DSP the wiki ships is for the **MacBook Pro 16" 2019 (6-speaker)** — explicitly **not** to be used on other models (damage risk). So the C4 premise ("the t2linux-maintained EasyEffects profile *for MacBookAir9,1*") **overstates what exists** — I'm flagging that rather than inventing one.
- **What the community actually uses on T2 laptops** is a **general-purpose T2 speaker EasyEffects preset** that restores warmth/body via a plugin chain, which is model-agnostic (EQ/dynamics, not a speaker-array DSP, so it carries no cross-model damage risk).

### Pick: **`angelobdev/t2-easyeffects-preset`** as the shipped default output preset
- Chain: **High-pass → Bass Enhancer → Multiband Compressor → Stereo Tools → Limiter → Equalizer** (LSP + CALF plugins). This is exactly the "add the low-end/body that the flat Linux default strips" correction.
- Tested on MacBook Pro 15,1 (Fedora 39 / Arch); author states it should work on **any PipeWire distro**. **Air is not explicitly listed** — so ship it as the *default* but treat it as a starting voicing to be trimmed by ear, not a measured Air calibration.
- Source file: **`mbp.json`** → install to the **XDG data dir**, not the deprecated config dir (§9 / §5 "EasyEffects presets moved from the deprecated config dir to the XDG data dir").

### NixOS config shape (ship the preset declaratively, autoloaded, invisible)
```nix
# EasyEffects runs as the backend service (already decided); ship the preset as a read-only default.
# Preferred XDG data path for presets on current EasyEffects:
#   ~/.local/share/easyeffects/output/macbook-t2.json
# Via Home Manager (example):
xdg.dataFile."easyeffects/output/macbook-t2.json".source = ./presets/angelobdev-mbp.json;
# Autoload it against the built-in speakers so it applies without the GUI:
#   ~/.config/easyeffects/autoload/output/<sink-name>:<preset>.json  (bind preset -> the T2 speaker sink)
services.easyeffects.enable = true;    # Home Manager option; keeps it headless (no visible window, §5)
```
(EasyEffects is Qt6/Kirigami per §9 — its window is suppressed/hidden as backend-only; only the preset ships.)

### Caveats
- **Voicing is subjective and model-approximate.** Present it as "macOS-like default, tweak in Settings › Audio › EQ," not "the correct Air curve."
- **Limiter is the safety net** — keep it in the chain; it prevents the bass-enhanced low end from over-driving the small Air speakers.
- **Ordering vs. the patched PipeWire:** the preset sits on the *output sink* the T2 module creates; verify it binds to the real built-in-speaker node name (which can differ from generic `alsa_output...`).

### Execution-time live-test
```bash
# confirm the T2 speaker sink exists and is the default:
wpctl status | grep -A3 Sinks
# load the preset in EasyEffects (headless autoload), then A/B by ear:
#   toggle the preset off/on while playing reference music + a voice/podcast track.
# Confirm no clipping at 100% (limiter engaged), and mic still works after (T2 audio instability caveat).
```

---

## 4. FAN CONTROL — **t2fanrd** (C14) — quiet, legible thermals for sustained agent loads

### Community approach
- The t2linux fan guide's recommended daemon is **`T2FanRD`** (GnomedDev) — a Rust rewrite of the original Python `t2fand`. It has a **first-class NixOS module**.
- Caveat the guide itself raises: **on some Macs the fan already ramps acceptably out-of-the-box**; the daemon is needed when you want a *custom curve* or the default policy runs hot/loud. For a dual-core i3 pinned for minutes by agents, a **custom curve is worth it** (quieter idle, firmer ramp under sustained load).

### NixOS config shape
```nix
# flake input
inputs.t2fanrd.url = "github:GnomedDev/T2FanRD";
# import its module + enable
imports = [ t2fanrd.nixosModule.t2fanrd ];   # (module name per the repo)
services.t2fanrd.enable = true;
```
Config lives at **`/etc/t2fand.conf`**, generated automatically on first run, one `[Fan1]` section per fan. Fields (verbatim from the README):
- `low_temp`  — temp that triggers ramp-up
- `high_temp` — temp that triggers max speed
- `speed_curve` — `linear` | `exponential` | `logarithmic`
- `always_full_speed` — `true` forces max regardless of temp

### Suggested curve for sustained dual-core agent workloads (starting point, tune on-machine)
The Ice Lake i3 in the Air throttles thermally under long all-core load; the goal is **quiet until it matters, then ramp firmly before throttle**:
```ini
[Fan1]
low_temp = 55          # near-silent below this (idle/editing)
high_temp = 82         # full tilt before the CPU starts thermal-throttling (~90–100°C package)
speed_curve = linear   # predictable; 'exponential' keeps it quieter longer but ramps late
always_full_speed = false
```
Rationale: 55 °C floor keeps the fan inaudible during light work; 82 °C ceiling gives headroom below the throttle point so long `nixos-rebuild`/agent runs stay off the thermal wall; `linear` is the most predictable and easiest to reason about. Move `high_temp` down (e.g. 78) if builds still throttle; up if the fan is annoyingly eager.

### Temperature readout for the system workspace (§6 process workspace, C14, B13)
- Temps come from **`lm_sensors`** hwmon: `sensors` exposes `coretemp-*` (Package/Core) and the fan RPM (`applesmc-*`). The guide's own detection command: `nix-shell -p lm_sensors --run "sensors | grep fan"`.
- For the QuickShell system workspace: read **`/sys/class/hwmon/*/temp*_input`** (coretemp) and **`fan*_input`** (applesmc) directly, or shell out to `sensors -j` (JSON) on a timer. This is the same readout that feeds a "thermal throttling" event into the B13 health stream (bonus).
```nix
environment.systemPackages = with pkgs; [ lm_sensors ];
```

### Caveats
- `/etc/t2fand.conf` is auto-generated; if you template it declaratively, make sure the daemon doesn't fight a read-only Nix-managed file — simplest is to let it generate, then hand-edit the curve (execution-time).
- Confirm the fan is actually `applesmc`-controlled (it is on T2 via SMC) — if the fan already behaves, `always_full_speed=false` + a gentle curve is all that's needed.

### Execution-time live-test
```bash
sensors                                   # confirm coretemp + applesmc fan RPM readable
systemctl status t2fanrd                   # daemon up
# stress both cores and watch the ramp + throttle behavior:
nix-shell -p stress-ng --run "stress-ng --cpu 2 --timeout 180s" &
watch -n1 'sensors | grep -E "fan|Package"'   # RPM should climb before Package hits throttle; note throttle temp
```

---

## 5. KEYBOARD BACKLIGHT (B17 / C13) — persistence + slider + idle-dim/restore-on-keypress

### Community approach (three separate needs)
The LED is **`apple::kbd_backlight`** exposed by **`applesmc`** at `/sys/class/leds/` (per B17; live-test must confirm the exact node — it may enumerate as `:white:kbd_backlight`). `brightnessctl` auto-detects it.

1. **Slider / direct control** — `brightnessctl -d 'apple::kbd_backlight' set N%` (and `get`/`max`). This is the control path the QuickShell **power/System panel slider** calls (mirror of the display-brightness slider, ilyamiro `Brightness.qml`-style but pointed at the kbd LED).
2. **Idle-dim + restore-on-keypress** (the macOS behavior) — a small **evdev-listening daemon**, because under Hyprland no DE does this:
   - **`VorpalBlade/keyboard-backlightd`** (Rust) — dims the kbd backlight after an inactivity timeout and **restores it on the next keypress**, reading evdev directly (Wayland-agnostic — ideal, since it doesn't depend on the compositor). **Leading pick.**
   - **`ruben2020/kbd_backlight_ctrl`** (systemd service) — turns backlight on on keypress, off on timeout, refreshes the countdown while typing. Simpler C alternative.
3. **Persistence across boots** — remember the last level:
   - **`systemd-backlight`** handles LEDs: `systemd-backlight@leds:apple::kbd_backlight.service` saves/restores on shutdown/boot (note the `ID_BACKLIGHT_CLAMP` udev property clamps restore to ≥1 or 5% unless set false).
   - Or let the idle daemon own the "restore last level" behavior. Simplest robust combo: **systemd-backlight for boot persistence + keyboard-backlightd for idle/keypress.**

### NixOS config shape
```nix
environment.systemPackages = with pkgs; [ brightnessctl ];

# udev: let 'video'/'input' group write the LED so the panel slider + daemon don't need root
services.udev.extraRules = ''
  ACTION=="add", SUBSYSTEM=="leds", KERNEL=="apple::kbd_backlight", \
    RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/leds/%k/brightness", \
    RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"
'';

# idle-dim + restore-on-keypress daemon (package/build keyboard-backlightd; run as a user/system service)
systemd.services.keyboard-backlightd = {
  description = "Idle-dim MacBook keyboard backlight, restore on keypress";
  wantedBy = [ "multi-user.target" ];
  serviceConfig.ExecStart = "${pkgs.keyboard-backlightd}/bin/keyboard-backlightd --dim 15 --off 60 /dev/input/by-path/...-kbd";
  # flags illustrative; real device path + timeouts set at execution
};

# boot persistence: systemd-backlight covers leds automatically once the led node exists.
```
(`keyboard-backlightd` may need packaging — it's small Rust; that's within "small glue," not from-scratch.)

### Caveats
- **Exact LED node name must be confirmed live** — `apple::kbd_backlight` vs `:white:kbd_backlight` differs by kernel/model; `brightnessctl --list | grep -i kbd` reveals it. All config keys off that string.
- **On T2, the keyboard is on the `apple-bce` VHCI bus but the backlight LED is an SMC function via `applesmc`** — the input events the idle daemon listens to and the LED it writes are technically different devices; the daemon must watch the *actual* Apple keyboard evdev node (find via `libinput list-devices`).
- **Suspend/resume** can reset the LED — pair with a resume hook that re-applies the saved level if systemd-backlight doesn't.

### Execution-time live-test
```bash
brightnessctl --list | grep -i kbd           # confirm the exact device string
brightnessctl -d 'apple::kbd_backlight' set 50%   # does the backlight change?
# reboot -> did the level restore? (systemd-backlight)
# start the daemon, stop typing for the timeout -> dims; press a key -> restores instantly.
# suspend/resume -> level correct?
```

---

## 6. GAMING LATENCY STACK (§4.6) — controller + frame + audio, end-to-end

The Xbox controller had **button + video/frame + audio** latency on NixOS that macOS didn't — pure config debt. Address all three legs plus the fractional-scale blur, and note a **T2-specific Bluetooth gotcha** that is a prime suspect for the *button* latency.

### Leg A — Controller driver (button latency): **xpadneo** (Bluetooth) or **xone** (dongle/USB)
- **`xpadneo`** — the driver for **Bluetooth** Xbox One/Series controllers. Adds correct mapping, rumble/trigger FF, battery, and processes input **~3.3× faster than the stock HID driver** = the direct fix for button lag. `hardware.xpadneo.enable = true;`
- **`xone`** — for the **Microsoft Xbox Wireless USB dongle** (and wired), adds headset audio. `hardware.xone.enable = true;`
- **Decision = how the controller connects:** Bluetooth → **xpadneo**; official dongle or USB cable → **xone**. Evaluate both because of the T2 BT caveat below — **wired/dongle via xone sidesteps the flaky T2 Bluetooth entirely** and is the lowest-latency, most reliable path on this specific machine.

> **T2-specific Bluetooth gotcha (likely root cause of the button latency):** the T2's **BCM4377-class Bluetooth glitches when the WiFi is on a 2.4 GHz connection** (documented on the t2linux State page for BT). A Bluetooth controller + 2.4 GHz WiFi = exactly the coexistence interference that adds/spikes input latency — and macOS tunes this coexistence, Linux does not. **Two honest fixes:** (1) put WiFi on **5 GHz**, or (2) connect the controller **wired/dongle (xone)** to remove BT from the path. This is the single most valuable gaming find and belongs in the live-test.

```nix
hardware.xpadneo.enable = true;   # if Bluetooth
hardware.xone.enable    = true;   # if dongle/wired  (safe to enable both; they cover different transports)
```

### Leg B — Frame/video latency (compositor): tearing + immediate presentation
```nix
# Hyprland (native Lua) equivalents:
general { allow_tearing = true }                 # master switch
windowrulev2 = immediate, class:^(steam_app_.*)$ # tear only the game window (fullscreen-only effect)
```
- Reduces frame latency/jitter; **only active when the game is fullscreen and alone on the monitor** (`hyprctl monitors` shows `activelyTearing: true`).
- **`env = WLR_DRM_NO_ATOMIC,1` is only needed on kernels < 6.8** — the T2-patched kernel here is newer, so **do not add it** (it disables the atomic API and can hurt more than help on modern kernels). Confirm kernel ≥ 6.8 at execution.
- **VRR: leave OFF.** The Air's internal panel is fixed-refresh (≈60 Hz, non-VRR); VRR gains nothing and the "bounce to lowest refresh above max" bug makes it worse. Tearing is the relevant lever here, not VRR.

### Leg C — Audio latency: PipeWire quantum
```nix
services.pipewire.extraConfig.pipewire."92-low-latency" = {
  "context.properties" = {
    "default.clock.rate"        = 48000;
    "default.clock.quantum"     = 256;   # ~5.3 ms — SAFE starting point for a dual-core i3
    "default.clock.min-quantum" = 128;
    "default.clock.max-quantum" = 512;
  };
};
```
- **Do NOT copy the common `quantum = 32` (0.67 ms) low-latency snippets** — on a **dual-core i3** that guarantees xruns/crackle. Start at **256**, only drop toward 128 if stable. This trades a couple ms of latency for not destroying audio under CPU load (which is *also* a latency source when it xruns).
- **Interaction with the T2 patched PipeWire:** this is drop-in `extraConfig`, composes with the `nixos-hardware` audio override — but **re-test that speakers/mic still work after applying** (T2 audio is the "partially working / unstable on switch" item).

### Leg D — XWayland fractional-scale blur (Steam at 1.5×)
- At 1.5× fractional scale, XWayland apps (Steam client, many games) render at 1× then get upscaled = **blurry**. Fix:
```nix
# Hyprland:
xwayland { force_zero_scaling = true }   # XWayland apps render at native pixel density (crisp)
```
  Then Steam's UI may look small; counter with `GDK_SCALE`/Steam's `-forcedesktopscaling 1.5`, or just run games **fullscreen at native res** (crisp, and pairs with the tearing rule). Games rendering their own fullscreen resolution are unaffected by the desktop scale.

### Execution-time live-test (verify each leg independently)
```bash
# Kernel check for Leg B env decision:
uname -r                                   # expect >= 6.8 -> no WLR_DRM_NO_ATOMIC

# Leg A (button): jstest-gtk or evtest on /dev/input/js0 — press-to-event delay feel;
#   then A/B: BT on 2.4GHz WiFi  vs  BT on 5GHz WiFi  vs  wired/dongle (xone). Note which is snappy.
# Leg B (frame): launch a game fullscreen; `hyprctl monitors | grep Tearing` -> activelyTearing: true.
# Leg C (audio): pw-top (watch for xruns/ERR) during gameplay; raise quantum if xruns appear.
#   measure round-trip if possible; confirm no crackle.
# Leg D (blur): open Steam; text crisp with force_zero_scaling? game fullscreen native = sharp?
```
End-to-end: the same controller session that was laggy should now feel like macOS — **most likely win is Leg A's BT-coexistence fix (5 GHz or wired) + Leg B tearing.**

---

## 7. T2 BOOT-DEFAULT (§4.4) — kill the per-boot "hold Option" · **HANDLE DELIBERATELY**

### Community approach (the safe, known-good method — no NVRAM hacking)
The t2linux **Startup Manager** guide's method sets the default startup disk **through Apple's own firmware startup manager**, not by poking NVRAM by hand:

> **Hold Option at boot → release at the startup manager → hold Control → boot the Linux (NixOS) disk while holding Control.** This sets the Control-selected disk as the **persistent default startup disk.** No more Option-hold on subsequent boots.

For a **separate Linux EFI partition**, the guide also gives the macOS-side `bless` route:
```bash
# run from macOS:
IDENTIFIER=$(diskutil info <PARTITION> | grep "Device Identifier" | cut -d: -f2 | xargs)
sudo diskutil mount $IDENTIFIER
sudo bless --folder /Volumes/<PARTITION>/EFI/BOOT --label "NixOS"
```

### Caveats / risks (flag every one — this touches the only invariant §10 says not to break)
1. **macOS updates reset the default back to macOS.** The guide states it explicitly: after any macOS upgrade you must **redo** the Option+Control (or `bless`) step. This is the #1 recurring annoyance, not a one-time fix. **Document it as a known post-update chore.**
2. **Startup Security is already handled — do NOT touch it.** To boot NixOS at all, the machine's **Startup Security Utility** (macOS Recovery: ⌘R) must already be at **"No Security" + "Allow booting from external/other media."** Changing it back to Full Security **removes the ability to boot Linux**. There is **no reason to open Startup Security Utility for this task** — leave it exactly as-is. Re-enabling it is the real "lose Linux boot" risk (recoverable, but only from macOS Recovery).
3. **This is not bricking.** The always-available recovery is: **hold Option at power-on → the picker returns** → pick any disk. So the worst case of any default-setting mistake is "hold Option once and try again," never a dead machine. The dual-boot + recovery generations invariant is preserved because none of this alters the systemd-boot install or the partition layout — it only changes which EFI the firmware auto-selects.
4. **`bless` targets the EFI folder, not systemd-boot's config** — it makes the firmware pick your ESP automatically; systemd-boot then runs as normal. Make sure `--folder` points at the actual ESP path containing the systemd-boot `BOOTX64.EFI`.

### The config-work half (mentioned per the brief — NOT the research core)
Once the firmware auto-selects the NixOS ESP, the *NixOS-side* seamless boot is config/theming:
```nix
boot.loader.systemd-boot.enable = true;
boot.loader.timeout = 0;                       # hide the menu; hold a key at boot to reveal it for recovery/macOS
boot.plymouth.enable = true;                    # branded splash themed to the aurora palette (§4.4)
boot.kernelParams = [ "quiet" "splash" "loglevel=3" "rd.udev.log_level=3" ];  # kill the ugly terminal scroll
boot.consoleLogLevel = 0; boot.initrd.verbose = false;
```
- `timeout = 0` + **hold Space/any key at power-on** reveals the systemd-boot menu when you *do* need macOS or an older generation — satisfies "hidden menu, recoverable" without a visible boot-manager feel. (Plymouth theme sourcing itself is a separate theming task; the palette work rides §3.)

### Execution-time live-test
```bash
# after Option+Control (or bless) from macOS: full power-off, then power-on WITHOUT holding Option.
#   -> should boot straight to NixOS Plymouth -> lock screen, no picker.
# recovery check: power-on holding Space (or Option) -> menu/picker still reachable for macOS + old generations.
# after a (hypothetical) macOS update: confirm it reverted, redo Option+Control. Document the chore.
```
> **Risk verdict:** *moderate, fully recoverable.* No NVRAM surgery, no Startup Security change, no partition change. The honest framing to the user: "seamless default is easy and safe; the only tax is redoing it after macOS updates, and Option-at-boot is always your undo."

---

## 8. MIC / CAMERA IN-USE INDICATORS (B4 / B5) — the macOS orange/green dot + bar mic-mute

### Community approach — reuse the audio services already tracking streams
- **Mic-in-use (orange dot): clean via PipeWire node state.** caelestia `services/Audio.qml` already enumerates **`Pipewire.nodes.values`**, filters **`node.isStream`**, and maintains a live **`streams`** list (with a `PwObjectTracker` binding them ready). **Mic-in-use = any stream node that is an input/capture linked to the default source.** So the indicator is a derived property over the *existing* `streams` list — no new backend, just a filter: "is there ≥1 active input stream?" → show the dot. This is the cited, already-present pattern (also mirrored in iNiR's `services/Audio.qml`).
- **Bar-level mic-mute toggle:** iNiR `MicToggle.qml` is the exact mouse-first pattern — `toggled: !Audio.micMuted`, icon `mic`/`mic_off`, `mainAction: Audio.toggleMicMute()`, right-click → volume mixer/device selector. Drop the same toggle into the QuickShell bar's right cluster (the mute state comes from `source.audio.muted` in caelestia's Audio service; `setSourceVolume`/mute functions already exist).

```qml
// derived indicator over caelestia's existing streams list (illustrative):
readonly property bool micInUse: Audio.streams.some(n => n?.isStream && n?.audio && /* is an input/capture node */)
// bar mic-mute: bind to Audio.source.audio.muted; click -> toggle (pattern = iNiR MicToggle.qml)
```

### The camera dot is harder — be honest
- **PipeWire does NOT reliably see the camera.** Chrome/Meet/Zoom-web on Wayland open **`/dev/video0` directly via V4L2**, not through the PipeWire camera portal — so there is **no PipeWire node** to watch for camera-in-use (unlike mic). The clean node-state trick works for mic but **not** for camera.
- **Reliable camera-in-use signal = watch who has `/dev/video*` open.** Options (all small glue):
  - Poll **`fuser /dev/video0`** / `lsof /dev/video0` on a short timer from a QuickShell `Process` → non-empty = camera live → green dot.
  - A **systemd path/udev watch** or inotify on the device's open count.
  - If the app *does* use the xdg-desktop-portal camera path, the portal exposes a "camera active" signal — but don't rely on it for Chrome's direct V4L2 access.
- **Honest scope:** ship the **mic dot + bar mute now** (free, PipeWire-native); ship the **camera dot as a `/dev/video0`-open watcher** (small glue), and pair it with the item-1 "Test camera" action so the dot's correctness is verifiable.

### NixOS / integration shape
No system config beyond `v4l-utils` (for `fuser`/`lsof` use `psmisc`/`lsof`):
```nix
environment.systemPackages = with pkgs; [ psmisc lsof v4l-utils ];   # fuser/lsof for the camera-open watcher
```
Everything else is QuickShell glue over services that already exist (caelestia/iNiR Audio + a tiny camera watcher).

### Caveats
- Mic dot false-negatives if an app grabs ALSA directly bypassing PipeWire (rare with the T2 patched PipeWire in place).
- Camera watcher polling interval is a latency/CPU trade — 1 s is plenty and cheap.
- Both dots should follow the §3 motion language (fade in/out, not pop) and the C17 "micro-status" vocabulary.

### Execution-time live-test
```bash
# mic: start a call / arecord -d 5 test.wav  -> mic dot appears; stop -> clears. Toggle bar mute -> source muted in wpctl.
# camera: open Meet/webcamtests -> `fuser /dev/video0` shows the browser PID -> green dot; close -> clears.
```

---

## Bonus finds (flagged — fit the design philosophy / hardware)

- **[HW] VA-API driver correctness gate (ties §9 + item 2 + Chrome win).** Ice Lake/Gen11 needs **`intel-media-driver` (iHD)**, *not* the legacy `intel-vaapi-driver` (i965). The accepted "install VA-API for Chrome" finding (§9) and the recorder both depend on this exact package + `LIBVA_DRIVER_NAME=iHD`. Getting the driver wrong = silent software fallback = the dual-core battery/perf loss the finding was meant to cure. One shared config line serves Chrome decode **and** gpu-screen-recorder encode.
- **[HW] Suspend/resume is the T2 fragility axis for camera + audio.** `apple-bce` master "does not support suspend/resume"; a suspend cycle can drop camera/audio until module reload. Worth a **resume hook** (`systemd` `post-resume`) that reloads/rebinds if the live-test shows breakage — protects the exact meeting/call moment item 1 & 8 care about. (Note: §10 zram-only/no-hibernate already means suspend, not hibernate, is the sleep path — consistent with B3.)
- **[HW] Bluetooth↔2.4 GHz WiFi coexistence** (from item 6) affects **AirPods/BT audio (B4) and any BT peripheral**, not just controllers — a system-wide "prefer 5 GHz WiFi" default improves every Bluetooth experience on this chassis. Cheap, high daily payoff.
- **[Quality] `pw-top`/`sensors` in the process workspace.** The same hwmon temps (item 4) + PipeWire xrun counts (item 6) are exactly the "legible system" signals for the dedicated process workspace (§6) and the B13 health stream — one readout serves fan awareness, thermal-throttle events, and audio-glitch visibility.
- **[Quality] Ship an external-webcam fallback affordance.** Given item 1's residual risk, the "Test camera" action should let the user pick **any** `/dev/video*` (internal *or* a plugged USB cam) — turns a possible hardware disappointment into a one-click switch, no meeting-time scramble.

---

## What I actually read / viewed vs. what I did NOT

### Read in full (local)
- `~/nix/MASTER_REQUIREMENTS.md` (all §0–§15) and `~/nix/research/GAP_REVIEW.md` (all Categories A–F + post-review additions).
- `~/nix/SESSION_PREAMBLE.md` (mandatory).
- **caelestia shell (local):** `services/Recorder.qml` (full), `services/Audio.qml` (full head incl. the `Pipewire.nodes.values`/`isStream`/`streams`/`PwObjectTracker` block), directory listing of `services/`.
- **iNiR (local):** `modules/common/models/quickToggles/MicToggle.qml` (full); grepped `services/Audio.qml`, `RecorderStatus.qml`, `scripts/videos/record.sh`, `RegionSelection.qml`, `RecordingOsd.qml`, `settings.qml`, `flake.nix`, `docs/LIMITATIONS.md`, `docs/PACKAGES.md` for the wf-recorder backend chain.
- **ilyamiro (local):** grepped the config tree for recorder/capture (found screenshot overlay + watchers; **no** gpu/wf recorder backend in ilyamiro — its overlay is capture-UX, the record *lifecycle* is caelestia's).

### Read / fetched (web — quoted where possible)
- t2linux wiki: **NixOS installation**, **State**, **audio-config**, **fan**, **startup-manager** pages; wiki index (guide list). (**FAQ page 404'd** — not reachable.)
- Source: `nixos-hardware apple/t2/default.nix` (options + what it patches); `GnomedDev/T2FanRD` README (config fields + NixOS module); `t2linux/apple-bce-drv` README (VHCI+audio, camera unmentioned, no suspend); `angelobdev/t2-easyeffects-preset` README (chain, mbp.json, models).
- Confirming searches: gpu-screen-recorder Intel VA-API reality; xpadneo vs xone + latency; Hyprland tearing/immediate/VRR; PipeWire low-latency quantum (NixOS shape); keyboard-backlight daemons (keyboard-backlightd, kbd_backlight_ctrl) + systemd-backlight persistence; Lorenzo Bettini MacBook Air webcam post (**identified as pre-T2 facetimehd — excluded as not-applicable**).

### Did NOT read / open gaps (honest)
- **No live-machine anything** — by design. Every item's real confirmation is its flagged live-test. In particular the **camera** "works" claim is *canonical-status-page-backed but not independently re-confirmed in driver docs* and not verified on this unit — **treat as probable-not-proven until the item-1 live-test.**
- Did **not** find a clean first-hand "MacBookAir9,1 camera working in Chrome/Meet" write-up (search returned generic/negative narrative) — so the camera risk rating stands on the State page + mechanism reasoning, not a matching trip report.
- Did **not** read the full `kekrby/t2-better-audio` or `lemmyg/t2-apple-audio-dsp` trees (the wiki summarizes them; the `nixos-hardware` module already supplies the equivalent patched PipeWire, so I treated them as reference not adoption). Did not open the T2FanRD Nix module *source* (README + wiki were sufficient for the config shape; exact option name `services.t2fanrd.*` to be confirmed against the flake at execution).
- Did **not** verify the exact **`/sys/class/leds/` node string** (`apple::kbd_backlight` vs `:white:kbd_backlight`), the **installed kernel version** (for the Leg-B env decision), or whether **`keyboard-backlightd` is already in nixpkgs** vs needs packaging — all three are execution-time confirmations, flagged inline.

### Risk ratings (blunt)
- **GENUINE RISK — verify before trusting:** **Webcam (item 1)** — trust-destroying if broken in a meeting; canonical says works, mechanism is sound, but unconfirmed on this unit → hard live-test + external-cam fallback. **Boot-default (item 7)** — recoverable but touches the boot invariant; the real tax is macOS-update reset, and the only true danger is *changing Startup Security* (so don't).
- **LOW RISK / high-confidence:** **Recorder (2)** — backend already implied by caelestia's own code; gpu-screen-recorder + iHD VA-API is the clean pick. **Fan (4)** — well-supported daemon, sane curve, tune live. **Mic dot + bar mute (8, mic half)** — free over existing services.
- **MEDIUM / needs on-machine tuning:** **Speaker profile (3)** — no Air-specific DSP exists; general T2 preset is a good default, trim by ear. **Kbd backlight (5)** — standard Linux tooling, but exact LED node + daemon packaging are live unknowns. **Gaming (6)** — strong hypotheses (BT-coexistence, tearing, quantum), each needs its own live A/B. **Camera dot (8, camera half)** — not PipeWire-visible; needs a small `/dev/video0`-open watcher.
