# Daily guardrails research

Scope: configuration-class policy research only for the T2 MacBook Air described in [MASTER_REQUIREMENTS.md](../MASTER_REQUIREMENTS.md), especially §4.7, §7, §10, and §15; B2/B3/B4/B6/B11/C5/C14 in [GAP_REVIEW.md](GAP_REVIEW.md); and the two post-review daily-safety additions DG1/DG2. This is not an implementation plan, and no live-machine checks were performed.

## Battery lifecycle — B3; §10

### Mechanism and concrete policy

Use **UPower as the authoritative threshold and emergency-action owner**. Configure percentage policy with `UsePercentageForPolicy=true`, `PercentageLow=20`, `PercentageCritical=10`, and `PercentageAction=5`. Set `CriticalPowerAction=Suspend` and, on current UPower, explicitly permit that action with `AllowRiskyCriticalPowerAction=true`. Current UPower calls suspend “risky” because suspend still consumes battery; on this machine it is nevertheless the honest last-resort action. There is only zram, no persistent swap, so hibernate and hybrid sleep are not viable. UPower documents percentage policy as more reliable than time-left policy for taking action, and exposes Low, Critical, and Action warning levels over D-Bus. [UPower 1.90.9 reference configuration](https://sources.debian.org/src/upower/1.90.9-1/etc/UPower.conf/), [UPower device API](https://upower.freedesktop.org/docs/Device.html), [UPower daemon API](https://upower.freedesktop.org/docs/UPower/)

Use an **iNiR-derived QuickShell battery service as the warning/panel owner**, not as a second suspend owner. Its existing defaults already model 20% low, 10% critical, and 5% suspend. Adapt only its presentation/deduplication logic:

- At 20%, while discharging: one normal-urgency warning, “Battery low — 20%”.
- At 10%, while discharging: one critical, persistent warning, “Battery critical — connect power now”.
- At 5%: UPower suspends. QuickShell may show the final countdown/status but must not independently call suspend.
- Fire each warning once per discharge cycle; re-arm only after AC is attached or charge rises above that threshold. Do not warn while charging.

This combines iNiR’s honest 20/10/5 lifecycle with caelestia’s clearer warning-versus-error visual escalation. Do **not** copy caelestia’s final hibernate action: its local defaults are warnings at 20/10/5 and hibernate at 3, which contradict this machine’s storage model. Relevant fully read local sources: [iNiR Battery.qml](../repos/inir/services/Battery.qml), [iNiR BatteryPopup.qml](../repos/inir/modules/bar/BatteryPopup.qml), [caelestia BatteryMonitor.qml](../repos/caelestia/shell-main/shell-main/modules/BatteryMonitor.qml), and [caelestia battery popout](../repos/caelestia/shell-main/shell-main/modules/bar/popouts/Battery.qml).

The power panel should display UPower’s `TimeToEmpty` while discharging and `TimeToFull` while charging, alongside percentage and energy rate. Treat a value of zero as unknown/calculating, not “0 minutes”. These are estimates for display only; they do not drive the 5% action. [UPower device properties](https://upower.freedesktop.org/docs/Device.html)

Use **power-profiles-daemon (PPD) as the profile actuator**, with a small system service reacting to UPower’s `OnBattery` change:

- Battery: set `power-saver`.
- AC: restore the saved AC preference, defaulting to `balanced`.
- `performance` is an optional AC preference/temporary workload hold, not an automatic battery mode. If the hardware does not expose performance, fall back to balanced. For a dual-core i3 and the §10 thermal/RAM budget, balanced is the sane ordinary AC setting; `powerprofilesctl launch`/a profile hold is the appropriate scoped mechanism for a compile or other deliberate burst.
- Keep PPD battery awareness enabled. It permits supported drivers/actions to react to battery and AC changes, but it is not by itself a promise that `ActiveProfile` will switch from balanced to power-saver; the small UPower-triggered policy owns that explicit switch.

PPD defines balanced as the default, power-saver as the battery-saving profile, performance as potentially unavailable, and provides profile holds for scoped work. [PPD D-Bus API](https://upower.pages.freedesktop.org/power-profiles-daemon/gdbus-org.freedesktop.UPower.PowerProfiles.html), [PPD README and battery-aware behavior](https://sources.debian.org/src/power-profiles-daemon/0.30-2/README.md), [powerprofilesctl manual](https://manpages.debian.org/testing/power-profiles-daemon/powerprofilesctl.1.en.html)

### Tool ownership

- **UPower:** percentages, warning-state truth, time estimates, and the sole critical suspend action.
- **QuickShell/iNiR-derived battery service:** 20/10 notification UX and panel presentation only.
- **PPD plus the UPower-triggered system policy:** actual power-profile changes.
- **System-group control:** AC preference (balanced/performance when available) and current profile display; it must not override forced power-saver while on battery.

`poweralertd` was evaluated, not selected. It correctly watches UPower warning/state changes and emits desktop notifications, but its current implementation sends low, critical, and action warnings with critical urgency. Running it beside QuickShell would also duplicate alerts, so it cannot provide the requested normal→critical escalation without patching. [poweralertd README](https://sources.debian.org/src/poweralertd/0.3.0-1/README.md), [event handling](https://sources.debian.org/src/poweralertd/0.3.0-1/main.c), [notification implementation](https://sources.debian.org/src/poweralertd/0.3.0-1/notify.c)

### Execution-time acceptance checks

Confirm the actual battery object, that UPower reaches each warning level once, that 5% invokes suspend rather than a fallback action, and that attaching/removing AC changes PPD as above. Confirm the power panel changes from time-to-empty to time-to-full and handles unknown estimates. These are execution-time checks, not claims from this research pass.

## Night light — B2

### Mechanism and concrete policy

Choose **hyprsunset**, not wlsunset. It is a first-party Hyprland utility, supported since Hyprland 0.45, has time-based profiles, gamma/temperature control, and native `hyprctl hyprsunset` IPC. That aligns with the Hyprland 0.55-era target and lets the shell change warmth without restarting a generic gamma daemon. wlsunset remains a capable compositor-neutral fallback, but its interface is sunrise/sunset/location/manual times plus signal-driven mode cycling; it has no Hyprland-native IPC advantage here. [hyprsunset documentation](https://wiki.hypr.land/Hypr-Ecosystem/hyprsunset/), [wlsunset manual](https://man.archlinux.org/man/wlsunset.1.en)

Concrete default:

- Scheduled warm period: **19:00–06:30 local time**.
- Day identity: **6500 K**.
- Night default: **4500 K**—warm enough to be visible without turning the aurora-glass palette muddy.
- System-group toggle: **Night light** on/off with an attached **Warmth** slider. Use the iNiR interaction pattern: immediate enable, automatic schedule, on/off times, and live temperature adjustment. Keep the full supported slider available (approximately 6500 K down to 1200 K), but mark 4500 K as the default and visually emphasize a practical 3500–5500 K region.
- Manual off/on is a temporary override until the next schedule boundary; changing warmth persists as the next night value.

Run one hyprsunset instance under the user session. Let its profile schedule own automatic timing; the QuickShell control only changes enabled state and temperature over supported IPC. This avoids competing timers. The local iNiR implementation already supplies the service and control pattern: [Hyprsunset.qml](../repos/inir/services/Hyprsunset.qml), [NightLightDialog.qml](../repos/inir/modules/sidebarRight/nightLight/NightLightDialog.qml), [NightLightControl.qml](../repos/inir/modules/waffle/actionCenter/nightLight/NightLightControl.qml), and [NightLightToggle.qml](../repos/inir/modules/common/models/quickToggles/NightLightToggle.qml).

### Tool ownership

- **hyprsunset:** actual compositor color transform and scheduled profiles.
- **QuickShell System group, adapted from iNiR:** toggle, warmth slider, schedule editing, and state display.

### Visual verification

I visually inspected the local caelestia composites, the local iNiR desktop-widget preview, and all six full-resolution iNiR README previews. The published action-center previews show the compact night-light toggle in context with the glass surface and accent colors, but none shows the expanded warmth slider. The final warm-shift judgment cannot be made from a static screenshot because hyprsunset’s filter is intentionally absent from captures. At execution time, compare 6500 K and 4500 K on the real display: pale text must remain neutral/readable, teal and violet accents must remain distinguishable, and translucent dark glass must not become brown. That is the required quick visual acceptance check.

## Audio device lifecycle and per-device EQ — B4 + C5; §4.7

### Mechanism and concrete policy

Use the supported **PipeWire switch-on-connect module plus WirePlumber’s default-node policy**, rather than inventing a new audio router:

- Load `module-switch-on-connect` for physical devices. Keep virtual sinks ignored and HDMI blocked unless deliberately enabled; those are the module defaults. When an AirPods-class A2DP sink appears, it becomes the hardware default. [PipeWire switch-on-connect module](https://docs.pipewire.org/page_pulse_module_switch_on_connect.html)
- Keep WirePlumber’s `node.restore-default-targets`, `linking.allow-moving-streams`, `linking.follow-default-target`, `device.restore-profile`, and `device.restore-routes` enabled. They are already defaults, but making the policy explicit documents the intended contract. WirePlumber stores a history of previous defaults, follows runtime default changes, and selects the best available node/route after removal. [WirePlumber settings](https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/settings.html), [default-node hooks](https://pipewire.pages.freedesktop.org/wireplumber/scripting/existing_scripts/default_nodes.html), [linking policy](https://pipewire.pages.freedesktop.org/wireplumber/policies/linking.html)
- AirPods connect: promote their A2DP sink; existing default-following playback moves there.
- AirPods disconnect: their node disappears; WirePlumber restores the previous available hardware default, normally internal speakers, and streams follow it.
- 3.5 mm plug: on the T2 card this will normally be a route/port availability change rather than a new sound card. WirePlumber/ACP selects the highest-priority available route; unplugging restores speakers. Do not force this through the Bluetooth rule. PipeWire documents automatic selection of the highest-priority available port/route. [PipeWire properties](https://docs.pipewire.org/1.2/page_man_pipewire-props_7.html)
- Match physical outputs by stable device properties (Bluetooth address/device name and ALSA card/route), never by transient numeric node IDs. Scope the promotion rule to the AirPods-class device and the analog headphone route so an unrelated HDMI monitor or EasyEffects virtual sink cannot steal output.

The current iNiR audio service is useful for node enumeration and manual default selection, but it does not implement newly-connected-device promotion. Its EasyEffects helper correctly resolves the virtual effects sink back to a physical driver. Adapt those pieces rather than claiming they already provide the full lifecycle: [Audio.qml](../repos/inir/services/Audio.qml) and [EasyEffects.qml](../repos/inir/services/deferred/EasyEffects.qml).

For Bluetooth quality, keep **BlueZ as connection/transport owner but put A2DP codec policy in WirePlumber’s BlueZ monitor configuration**. `bluez5.codecs` belongs there, not in BlueZ’s generic daemon settings. For the AirPods-class device, enable `aac`, `sbc_xq`, and `sbc`, keep `device.profile=a2dp-sink` for ordinary playback, and prefer the AAC A2DP profile when the device advertises it. SBC remains the mandatory fallback; SBC-XQ is useful for compatible non-AAC devices. Do not force headset/HFP mode for music—the microphone profile trades playback fidelity for duplex voice. WirePlumber documents all three codecs, A2DP as the default profile, per-device rules, and `api.bluez5.codec` as the resulting node property. [WirePlumber Bluetooth configuration](https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/bluetooth.html)

For C5, use **EasyEffects’ built-in device autoload profiles**:

- Keep the physical hardware as PipeWire’s default; never make the EasyEffects virtual sink the system default. Set EasyEffects to use the default output and process output streams, so a hardware-default change carries the effects pipeline to the new device. [EasyEffects PipeWire page](https://wwmm.github.io/easyeffects/user_interface/pipewire.html), [upstream default-device guidance](https://github.com/wwmm/easyeffects)
- Internal speakers → the T2 speaker preset sourced by the separate hardware session.
- Each wired/Bluetooth headphone model → a local EasyEffects preset generated from that exact model in the public AutoEq database. AutoEq produces EQ settings rather than applying them; its web app explicitly recommends EasyEffects on Linux. Select the exact model/measurement, export for EasyEffects, import it as a local preset, retain the prescribed preamp to avoid clipping, and then bind it to the output device. [AutoEq project and database usage](https://github.com/jaakkopasanen/AutoEq), [AutoEq web app](https://autoeq.app/)
- Unknown output → neutral/pass-through preset, never the T2 speaker correction.
- Associate each local preset with its output in EasyEffects Autoload. Upstream states that a preset can be autoloaded when its device appears; community presets must first be imported locally to participate. [EasyEffects user presets](https://wwmm.github.io/easyeffects/user_interface/userpresets.html), [community preset rules](https://wwmm.github.io/easyeffects/community/COMMUNITY_PRESETS_GUIDELINES.html)

### Tool ownership

- **PipeWire switch-on-connect:** newly connected physical sink promotion.
- **WirePlumber:** default history, route availability, fallback, and moving default-following streams.
- **WirePlumber BlueZ monitor:** allowed/preferred A2DP profile and codecs; **BlueZ:** pairing and transport.
- **EasyEffects:** physical-default following, DSP, and device→preset autoload.
- **QuickShell:** display and manual override only; it is not the routing or EQ policy engine.

### Execution-time acceptance matrix

Verify every transition with already-playing audio: speakers→AirPods→speakers and speakers→3.5 mm→speakers. For each state, verify default hardware node, actual audible endpoint, EasyEffects active preset, channel/volume sanity, and Bluetooth `api.bluez5.codec=aac` when the AirPods advertise AAC. Also verify that using a Bluetooth microphone intentionally changes to the voice profile and that closing the microphone client returns to A2DP. These are per-device execution-time checks; this research did not inspect the live graph.

## Disk visibility, generation retention, and GC — B6; §15 and §10

### Mechanism and concrete policy

Make root-filesystem space permanently visible by adapting an existing shell service, not adding another monitor. The lighter iNiR service polls `df -B1 /` and already exposes total, used, and percentage; caelestia’s storage card provides a richer root-disk selector and used/total visualization. On this single 121 GB NixOS partition, use the iNiR root metric in the bar/System workspace and the caelestia-style circular used/total card in the expanded view. [iNiR ResourceUsage.qml](../repos/inir/services/ResourceUsage.qml), [caelestia StorageCard.qml](../repos/caelestia/shell-main/shell-main/modules/dashboard/performance/StorageCard.qml), [caelestia storage service](../repos/caelestia/shell-main/shell-main/plugin/src/Caelestia/Services/storage.cpp)

Threshold policy, based on **available bytes on `/`**, not percentage alone:

- Normal: at least 15 GiB free.
- Warning: below 15 GiB or above 85% used; one normal notification per threshold crossing, with the disk card turning amber.
- Critical: below 8 GiB or above 92% used; persistent critical notification, red card, and a “Review generations” action. Do not automatically launch a destructive clean from the notification.
- Re-arm notifications only after recovery above 18 GiB/82% so the edge does not chatter.

Adapt the threshold and notification state machine around iNiR’s existing root-space poll. QuickShell is the correct owner because it already has user-session notification access; a root system service generally does not.

For routine cleanup, enable **NixOS `nix.gc.automatic` weekly** with persistence. Immediately before it, run a **generation retention policy of “keep at least 5 system generations OR every generation from the last 30 days, whichever keeps more”**. The pre-GC trimmer establishes the retention window; `nix.gc.automatic` then collects only what the retained profiles and other GC roots no longer reach.

Do not also pass `--delete-older-than 30d` to `nix.gc.automatic`: that native age-only operation could delete members of the five-generation floor when rebuilds are infrequent. Nix exposes age-based deletion in `nix-collect-garbage` and count-based deletion in `nix-env`, but it does not combine count, age, and a protected label in one native switch. [Nix garbage collector](https://nix.dev/manual/nix/2.34/command-ref/nix-collect-garbage), [Nix generation deletion semantics](https://releases.nixos.org/nix/nix-2.34.8/manual/command-ref/nix-env/delete-generations.html), [NixOS GC option meanings](https://mynixos.com/nixpkgs/options/nix.gc)

The official NixOS Wiki’s community trimmer implements exactly the count-or-age shape and supports the system profile; adapt its selection logic into a noninteractive, declarative pre-GC service, retaining a dry-run/review command in the System workspace. [NixOS Generations Trimmer](https://wiki.nixos.org/wiki/NixOS_Generations_Trimmer), [fully read trimmer source](https://gist.github.com/MaxwellDupre/3077cd229490cf93ecab08ef2a79c852)

Create a separate, human-labelled **accepted-known-good GC root** pointing to the accepted system closure. A GC root prevents that closure and all dependencies from collection even after its numbered system generation is deleted. Store the accepted closure identity and date beside the System workspace’s “Known good” display, and provide a reviewable “Mark current as known-good” affordance; never move the pin automatically after each rebuild. [Nix GC roots](https://nix.dev/manual/nix/2.34/package-management/garbage-collector-roots)

This distinction matters because a pinned closure is not automatically a numbered boot-menu generation. The recovery affordance must retain the accepted closure’s `switch-to-configuration` path/instructions, and the accepted pin must be established before its generation link is pruned.

### §15 lifecycle handling

Treat the two clean-slate events as explicit lifecycle transitions, not as ordinary retention:

1. Generations 1–7 are deletable now, as §15 says. They are not the long-term fallback.
2. During current-era iteration, the 5-or-30-day policy supplies short rollback history.
3. When the first fully working build is accepted, pin **that exact closure** as the new known-good first.
4. Only then perform §15’s wipe of the current-era numbered generations. The accepted closure survives independently of generation numbering.
5. Subsequent weekly cleanup again keeps at least five/newer-than-30-day generations plus the accepted pin. A later accepted build replaces the pin only by an explicit acceptance action.

This tolerates both planned purges without stranding rollback. It also avoids pretending that `boot.loader.*.configurationLimit` prunes the store; that kind of option only limits boot-menu display.

### Tool ownership

- **QuickShell ResourceUsage/System workspace:** visible free space, low-space notifications, and review/known-good affordances.
- **Adapted community generation trimmer:** the 5-or-30-day retention window and pruning of the system profile.
- **NixOS `nix.gc.automatic`:** weekly collection after that retention decision; it does not make a second age-only generation-deletion pass.
- **Explicit accepted GC root:** long-lived known-good closure across §15 purges.

zram remains unchanged. No swap partition is introduced, and disk policy never assumes hibernation (§10).

### Execution-time acceptance checks

Before enabling automatic deletion, review the trimmer’s dry-run against system and user profiles, confirm the known-good root resolves to the accepted closure, confirm its recovery path, and verify low-space notification hysteresis. After the §15 transition, verify the accepted closure remains live even though old numbered generations are gone. Those are execution-time checks.

## Captive portals — B11; §4.7

### Mechanism and concrete policy

Use **NetworkManager as connectivity truth**. Enable its connectivity check with a valid plain-HTTP probe URI, a 300-second steady interval, a 10-second timeout, and the matching expected response. Plain HTTP is intentional: an HTTPS probe generally cannot be redirected cleanly by a captive portal. A concrete maintained endpoint choice is `http://connectivity-check.ubuntu.com/` with an empty expected response (HTTP 204/no body). Make the URI a single named setting so it can be replaced if that external service changes. NetworkManager exposes `UNKNOWN`, `NONE`, `PORTAL`, `LIMITED`, and `FULL`; `PORTAL` is distinct from merely limited Internet. [NetworkManager connectivity configuration](https://networkmanager.dev/docs/api/latest/NetworkManager.conf.html), [Ubuntu’s documented NetworkManager probe](https://documentation.ubuntu.com/core/explanation/system-snaps/network-manager/how-to-guides/configure-the-snap/connectivity-check/)

Add a **small NetworkManager dispatcher hook for `connectivity-change`**. Its only policy is:

- On `CONNECTIVITY_STATE=PORTAL`, trigger a user-session notification once per connection: “This network needs a sign-in”, with a **Sign in** action.
- The action opens the same plain-HTTP connectivity URI in the default browser, allowing the network to redirect it to the login page.
- On `FULL`, withdraw/resolve the portal notification. On `LIMITED`, show “Limited connectivity” in the network status but do not claim that a sign-in page exists. On `NONE`/`UNKNOWN`, do nothing beyond the normal network indicator.
- Deduplicate by active connection UUID and reset after disconnect or `FULL`.

NetworkManager officially dispatches `connectivity-change` and supplies `CONNECTIVITY_STATE` with those values. [NetworkManager dispatcher contract](https://networkmanager.dev/docs/api/latest/NetworkManager-dispatcher.html)

The dispatcher runs as root and does not naturally own the graphical session bus. Therefore it must **only trigger a user unit/QuickShell handler**; that user-side handler sends the actionable notification and launches the browser. Do not call `notify-send` directly from the root hook. `notify-send` supports named actions and returns the selected action to its caller, which is sufficient for the small user-session handler. [notify-send actions](https://man.archlinux.org/man/extra/libnotify/notify-send.1.en)

iNiR’s fully read Network service is a useful surface donor: it already queries `nmcli -t -f CONNECTIVITY g`, distinguishes `none`, `limited`, and `full`, and marks Wi-Fi limited. Adapt it to preserve the additional `portal` state and to open the configured probe URI rather than its hard-coded HTTPS GNOME URL. [iNiR Network.qml](../repos/inir/services/Network.qml)

### §4.7 mapping and tool ownership

- **NetworkManager:** portal/limited/full connectivity state and dispatcher event.
- **Root dispatcher hook:** transition bridge only.
- **User QuickShell/notification handler:** wording, deduplication, action, and browser launch.
- **Network surface:** show Portal/Limited/Full separately from §4.7’s actual Wi-Fi link Mbps. A fast link can still be captive; these are different truths.

### Execution-time acceptance checks

Test on a real captive network: ensure exactly one notification, verify the action reaches the portal, submit sign-in, and confirm state becomes `FULL` and the notice clears. Also test a genuinely limited/no-Internet network to ensure it does not open a bogus login page. Confirm the chosen probe endpoint still returns its expected unredirected response. These are execution-time checks.

## Lid-close suspend and T2 wake integrity — DG1; B3 + §10

### Mechanism and concrete policy

Use **systemd-logind as the physical lid-switch and suspend owner**, with **hypridle as the lock-before-sleep coordinator**. Hypridle is not itself a lid-event daemon: it reacts to idle time and logind's `PrepareForSleep` signal. Keeping the hardware event in logind means closing the lid still works if Hyprland or QuickShell has crashed.

Make the laptop policy explicit: `HandleLidSwitch=suspend`, `HandleLidSwitchExternalPower=suspend`, and `HandleLidSwitchDocked=suspend`. The build is specified as a single-display laptop and the requested behavior is close-lid-means-sleep, not closed-lid clamshell operation. Keep `LidSwitchIgnoreInhibited=yes` so a browser/media idle inhibitor cannot leave the closed laptop awake in a bag. logind documents suspend as the default lid action, docked ignore as a separate default, and the inhibitor behavior; the explicit values remove ambiguity. [systemd logind configuration](https://man7.org/linux/man-pages/man5/logind.conf.5.html), [NixOS logind configuration shape](https://wiki.nixos.org/wiki/Systemd/logind)

Use the community-proven **end-4 hypridle lock sequence**:

- `lock_cmd` invokes the final §15-selected session-lock implementation and avoids starting a duplicate instance.
- `before_sleep_cmd=loginctl lock-session` requests the lock for every sleep source: lid, idle listener, manual sleep, and UPower's 5% critical action.
- `inhibit_sleep=3` holds logind's sleep long enough for a Wayland session-lock client to report that the session is actually locked. This is stronger than merely launching a lock command and immediately suspending.
- `after_sleep_cmd` restores DPMS/lock focus so wake does not require a mystery extra keypress.

Hypridle documents mode 3 as waiting until the session is locked and explicitly supplies `before_sleep_cmd=loginctl lock-session` as its lock-before-suspend example. end-4 ships that exact pairing; its lid switch bind is deliberately commented as a fallback “if … it’s not the default behavior.” [hypridle reference](https://wiki.hypr.land/Hypr-Ecosystem/hypridle/), [end-4 hypridle config](../repos/end4-dots-hyprland/dots/.config/hypr/hypridle.conf), [end-4 keybinds](../repos/end4-dots-hyprland/dots/.config/hypr/hyprland/keybinds.lua)

**Hyprland switch binding is fallback, not a second owner.** If execution-time testing proves that logind does not receive/act on this machine's lid event, then set all logind lid actions to `ignore` and use one locked Hyprland bind matching `switch:on:<exact lid-switch name>` to call suspend. Do not use the proposed unqualified `switch:Lid Switch`: Hyprland documents that form as firing whenever the switch toggles, so it also fires on lid-open. Hyprland also warns that its switch binds conflict with logind lid handling. [Hyprland switch binds](https://wiki.hypr.land/Configuring/Binds/)

Frost-Phoenix was also checked: its close-edge bind launches only the lock screen and never requests suspend, so it is not sufficient for this gap. [Frost-Phoenix binds](../repos/frost-phoenix-nixos-config/modules/home/hyprland/binds.nix)

### T2-specific suspend policy

Treat suspend as **supported only behind a hardware acceptance gate**, not as generic-PC truth. The current t2linux state page calls T2 suspend partially working; the apple-bce upstream README says its master branch does not support suspend/resume. The t2linux baseline also calls for `pm_async=off` alongside its other T2 kernel parameters. Its current workaround unloads `apple-bce` before sleep and reloads it on wake; Broadcom `brcmfmac`/`brcmfmac_wcc` reloads are conditional only when Wi-Fi actually fails after resume. [t2linux state](https://wiki.t2linux.org/state/), [t2linux suspend workaround and kernel parameters](https://wiki.t2linux.org/guides/postinstall/), [apple-bce README](https://github.com/t2linux/apple-bce-drv)

Concrete adaptation policy:

- Preserve zram and use suspend only—never hibernate or hybrid sleep (§10/B3).
- Ensure the T2 kernel profile includes `pm_async=off`; do not duplicate parameters already supplied by the imported T2 hardware module.
- Start with no speculative Wi-Fi reload hook. If the acceptance cycles reproduce lost keyboard/trackpad/audio, adapt t2linux's pre/post `apple-bce` systemd unit declaratively. Add the two Broadcom module unload/reload steps only if Wi-Fi specifically fails after wake.
- Do not claim t2linux's Fedora/Arch workaround is already proven on NixOS. Its forced module unload also requires matching kernel support, so that path is an execution-stage compatibility gate.

### Tool ownership

- **systemd-logind:** sole normal lid-event and suspend requester.
- **hypridle:** sleep delay, lock request, and post-wake display/focus restoration—not lid detection.
- **Final session-lock service:** authentication and locked UI; this block does not pre-decide the open §15 lock-screen comparison.
- **Conditional T2 pre/post sleep unit:** apple-bce and, only if demonstrated necessary, Broadcom recovery.
- **Hyprland switch bind:** fallback owner only after logind is disabled for the lid event.

### Execution-time acceptance checks

Resolve the exact lid switch name/event at execution, then run repeated close/wake cycles on both AC and battery. Every close must produce exactly one suspend; wake must land on the lock screen before the desktop is visible. Verify keyboard, trackpad, internal audio, microphone, camera, Wi-Fi reconnect, Bluetooth reconnect, and DPMS after every cycle. Repeat once after a long sleep. Only a reproduced post-wake failure justifies adding the relevant module recovery step. None of those checks was run in this research pass.

## Sustained-load responsiveness — DG2; §7 + §10 + C14

### Mechanism and concrete policy

Keep **t2fanrd as thermal owner**, but do not mistake thermal control for responsiveness control. Its complete source reads the hottest available CPU/GPU temperature, smooths samples, and maps that temperature through the selected fan curve. It has no process scheduler, I/O-priority, memory-pressure, or compositor-priority mechanism. The hardware session's 55 °C→82 °C linear starting curve remains appropriate for keeping a long agent/build workload away from the thermal wall; a scheduler policy is a separate layer. [T2FanRD README](https://github.com/GnomedDev/T2FanRD), [temperature loop](https://github.com/GnomedDev/T2FanRD/blob/master/src/main.rs), [fan controller](https://github.com/GnomedDev/T2FanRD/blob/master/src/fan_controller.rs), [hardware session C14](hardware-drivers.md#4-fan-control--t2fanrd-c14--quiet-legible-thermals-for-sustained-agent-loads)

Use a **systemd cgroup-v2 `agent.slice` as the aggregate resource-policy owner** for both Claude Code and Codex sessions. Adapt iNiR's existing `systemd-run --user --scope` launcher pattern so the dev-workspace's one-click agent launchers enter that slice, and adapt its proven `nice -n 10` plus idle-I/O treatment rather than adding a process-scanning daemon. `systemd-run` scopes inherit the caller's terminal environment and keep the whole descendant process tree grouped. [iNiR ShellExec.qml](../repos/inir/modules/common/functions/ShellExec.qml), [iNiR bounded/low-priority apply runner](../repos/inir/scripts/colors/applycolor.sh), [systemd-run](https://man7.org/linux/man-pages/man1/systemd-run.1.html)

Concrete starting policy for the **combined agent slice**:

- `CPUWeight=20` against the normal default weight of 100. This is relative and work-conserving: the agents may still consume all otherwise-idle CPU, but interactive siblings win promptly when the user types, animates a workspace, plays audio, or opens a panel.
- `IOWeight=20`, plus `Nice=10` and idle I/O class on each launched scope. The cgroup weight covers the whole process tree; nice/idle-I/O reinforce the policy inside it. iNiR already uses `nice -n 10` and `ionice -c 3` for bursty parallel theme jobs.
- Aggregate `MemoryHigh=50%` (about 4 GiB on this 8 GiB machine) and `MemoryMax=70%` (about 5.6 GiB). `MemoryHigh` is the normal throttle/reclaim boundary; `MemoryMax` is the last defense that confines a runaway agent instead of letting RAM reclaim plus zram compression freeze the whole session. Leave `MemorySwapMax` unset so §10's zram remains available.
- Do not set a hard CPU quota initially. Weights preserve fast completion when the laptop is otherwise idle. If the execution-time dual-agent trial is still visibly laggy, add a **200% aggregate quota** to `agent.slice` as the second-stage guard (at most two CPUs of runtime), after confirming the Air exposes four logical CPUs. Do not guess topology from “dual-core.”

systemd defines CPU/I/O weights on a 1–10000 scale with 100 as the kernel/default value; CPU time and I/O bandwidth are divided relative to sibling weights. It identifies `MemoryHigh` as the main memory-control mechanism and `MemoryMax` as the last line of defense. [systemd resource control](https://man7.org/linux/man-pages/man5/systemd.resource-control.5.html), [nice](https://man7.org/linux/man-pages/man1/nice.1.html), [ionice](https://man7.org/linux/man-pages/man1/ionice.1.html)

Handle **Nix builds separately**. A CLI can ask `nix-daemon` to build, but the actual builders are daemon descendants and therefore escape the user `agent.slice`. Set Nix to `max-jobs=1` and `cores=2` so it requests only one derivation at a time with two build cores, then apply the same low CPU/I/O weight and nice/idle-I/O policy to `nix-daemon.service`. Nix's manual warns that `max-jobs × cores` oversubscription degrades the machine through context switching, and also notes that builders must cooperate with the requested core count; the daemon's lower scheduling weight is the contention backstop, not a hard core-count limit. [Nix cores and jobs](https://nix.dev/manual/nix/2.32/advanced-topics/cores-vs-jobs)

### Why not the alternatives

- **No Hyprland “render priority” setting solves this.** The current render section has a `new_render_scheduling` frame-pacing/triple-buffer option for underpowered devices, not a Linux CPU scheduler priority control. It may deserve a separate visual latency A/B, but it cannot contain agent processes. Do not give Hyprland realtime scheduling or a large negative nice value; that can starve audio/input and turns one starvation problem into another. [Hyprland render variables](https://wiki.hypr.land/Configuring/Basics/Variables/)
- **nice/ionice alone are useful but incomplete.** They do not give an aggregate two-agent memory boundary, and process-name rules are fragile when agents spawn shells, language servers, builds, and helpers.
- **Ananicy-class process scanners are not selected.** They add a resident rule/matching layer and can conflict with other priority owners. Explicit launch scopes are deterministic, inherited by descendants, and already present in iNiR's community launcher pattern.
- **CPU affinity is not selected.** Pinning agents to a core throws away useful idle capacity and may collide with IRQ/audio placement. Relative weights solve the actual contention problem without hard partitioning.

### Tool ownership

- **`agent.slice` plus transient systemd scopes:** aggregate CPU, I/O, and memory policy for agent sessions and their descendants.
- **Dev-workspace agent launchers:** put every Claude/Codex start into that slice; no free-running bypass launcher.
- **`nix-daemon.service` plus Nix `max-jobs`/`cores`:** separately contain daemon-owned builds.
- **t2fanrd:** fan curve and thermal response only.
- **PPD:** frequency/energy profile from the battery block; it does not replace cgroup scheduling.
- **QuickShell System/process workspace:** display agent-slice CPU/RAM state and provide a deliberate temporary “full speed” override, not automatic priority mutation.

### Execution-time acceptance checks

At execution, confirm that each one-click agent session and every child remains under `agent.slice`, while daemon builds appear under the separately constrained Nix service. Under two simultaneous CPU-heavy agent workloads, check typing, cursor motion, workspace animation, panel opening, audio continuity, and wall-clock agent slowdown. Exercise a memory-heavy workload to confirm the slice—not the desktop session—hits the soft/hard boundary. Tune weight 20 upward only if agents are unnecessarily slow, downward or add the 200% quota only if interaction still stalls. These are staged live acceptance checks, not results claimed here.

## Bonus finds

- **Battery:** current UPower requires an explicit opt-in before `Suspend` is accepted as a critical action. Omitting it may silently select a fallback that this no-swap machine cannot use correctly.
- **Audio:** WirePlumber already stores a history of past hardware defaults, so disconnect fallback is a supplied policy rather than custom “remember previous sink” state.
- **Audio/EQ:** EasyEffects explicitly expects the hardware—not its virtual sink—to remain the default. Its “use default output + process output streams” mode is the clean fit for automatic device switching.
- **Night light:** hyprsunset’s transform is not captured in screenshots/recordings. The palette check must be done by eye on the physical display; a screenshot cannot prove it.
- **Disk:** a GC root protects the closure but does not preserve a numbered boot-menu entry. The known-good affordance must retain an activation/recovery path, not just a label.
- **Portal:** `PORTAL` and `LIMITED` are separate NetworkManager states. Collapsing both into “limited” loses the one state on which a sign-in prompt is justified.
- **Lid/sleep:** one hypridle lock-before-sleep path protects every suspend source, including UPower's 5% action; the physical lid does not need a second bespoke lock command.
- **T2 sleep:** the Broadcom reload is not a universal T2 requirement. The current t2linux workaround leaves it commented unless Wi-Fi actually breaks after resume, which prevents unnecessary device churn on every wake.
- **Load control:** CPU weight is work-conserving. The laptop does not sacrifice idle build speed merely to preserve interactivity under contention.
- **t2fanrd correction:** its current NixOS module declaratively generates `/etc/t2fand.conf`; the hardware-session suggestion to let it generate and then hand-edit that file should not carry into the plan.

## What I actually read vs what I didn’t

### Read in full

- [SESSION_PREAMBLE.md](../SESSION_PREAMBLE.md), [MASTER_REQUIREMENTS.md](../MASTER_REQUIREMENTS.md), and [GAP_REVIEW.md](GAP_REVIEW.md).
- Local iNiR README and the relevant complete services/controls: Battery, BatteryPopup, PowerProfilePersistence, Hyprsunset, both night-light panels plus toggle, Network, Audio, deferred EasyEffects, and ResourceUsage.
- Local caelestia root/shell READMEs and the relevant complete battery monitor, battery popout/tank, storage card, DiskInfo, and Storage service sources.
- The local caelestia composite images, local iNiR desktop-widget image, and all six full-resolution published iNiR README previews were visually inspected. The night-light quick toggle is visible; no expanded slider preview was present.
- The upstream/manual pages linked above for UPower configuration/API, poweralertd README/event/notification source, PPD API/README, hyprsunset, wlsunset, WirePlumber linking/settings/default-node/Bluetooth policy, PipeWire switch-on-connect/properties, EasyEffects routing/presets/local server, AutoEq usage, Nix generation deletion/GC roots/GC, the NixOS trimmer page and full script, NetworkManager configuration/dispatcher/D-Bus behavior, and actionable notifications.
- New-gap local sources read completely: end-4's 26-line `hypridle.conf` and 359-line Hyprland `keybinds.lua`; Frost-Phoenix's complete 146-line binds module; iNiR's complete 84-line bounded apply runner and 111-line `ShellExec.qml` scope launcher.
- New-gap upstream material: the current Hyprland switch-bind and hypridle pages; logind lid/inhibitor documentation; systemd resource-control and transient-scope sections; current nice/ionice manuals; the full Nix cores/jobs page; t2linux State and complete post-install suspend section; apple-bce's complete README.
- T2FanRD's complete repository structure and all four complete Rust source files, README, Cargo manifest, and full NixOS flake/module were read.

### Not read or not verified

- I did not read every source file in the whole iNiR, caelestia, WirePlumber, PipeWire, EasyEffects, UPower, or NetworkManager repositories; I read their complete relevant files/manual pages, not unrelated code.
- I did not inspect the separate T2 speaker-profile source; B4/C5 deliberately treats that preset as an input from the hardware research session.
- I did not select an AutoEq headphone result because the exact headphone model was not supplied. The policy is exact-model-only, with neutral fallback.
- I did not inspect the live UPower objects, PPD profile availability, PipeWire graph, codec negotiation, ALSA/UCM jack routes, filesystem space, Nix generations, NetworkManager state, or a real captive portal. All such checks are explicitly marked execution-time above.
- I did not apply configuration, start/stop services, change profiles, delete generations, run GC, alter audio routing, or render the shell on the machine.
- I did not inspect the live lid event/name, current logind inhibitors, current kernel parameters/config, cgroup hierarchy, logical-CPU count, agent child trees, or suspend/resume behavior. I did not close the lid, suspend, reload a module, stress the CPU, or change any scheduler/resource property.
- I did not read the generated T2FanRD `Cargo.lock` dependency lockfile or every line of systemd/Hyprland implementation source; I read the complete daemon source and the complete relevant upstream manuals/pages. The T2FanRD README's curve graph did not render through the available web viewer; its three curve behaviors were instead verified in the complete `fan_controller.rs`. No UI slider/toggle was introduced by these two gaps, so there was no new shell preview to judge.

### Final ownership summary

UPower owns battery thresholds and critical suspend; systemd-logind owns the physical lid and normal suspend request; hypridle owns lock-before-sleep coordination; PPD owns power profiles; hyprsunset owns the color transform; PipeWire/WirePlumber own device routing and Bluetooth audio policy; EasyEffects owns per-device DSP; Nix plus the trimmer and accepted GC root own retention; NetworkManager owns connectivity state; systemd agent/Nix cgroups own load containment; t2fanrd owns only fan response. QuickShell owns presentation, explicit overrides, and actionable notifications—never the safety-critical mechanism itself.
