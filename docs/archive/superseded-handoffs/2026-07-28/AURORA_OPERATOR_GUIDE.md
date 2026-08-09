# Aurora Desktop Operator Guide

This is the day-to-day handbook and first-reboot acceptance guide for Alex's
2020 T2 MacBook Air. It describes the desktop installed as **NixOS Generation
9**. It is an operator guide, not an implementation log.

The expected running system after reboot is:

```text
/nix/store/qb1wjwmh9pi0llyazp5hvaad4cz55cd5-nixos-system-macbook-26.11.20260616.567a49d
```

An interactive version of this guide is installed as **Aurora Guide & Test
Checklist**. After reboot, click **Apps**, type `Aurora Guide`, and single-click
it. Its checkboxes and notes are saved locally in Chrome.

Quick index:

- [First reboot and healthy login](#3-what-a-healthy-first-login-looks-like)
- [Waybar desktop map](#4-desktop-map)
- [Touchpad, windows, and Apps](#6-touchpad-and-pointer)
- [QuickShell control panels](#9-wi-fi-panel)
- [Kitty and shortcuts](#18-kitty-terminal)
- [Guided acceptance checklist](#21-first-reboot-acceptance-checklist)
- [Recovery and evidence](#23-recovery-and-evidence)

## 1. Before the first reboot

- Keep the charger connected for the first boot and acceptance pass.
- Generation 9 is the default systemd-boot entry.
- The systemd-boot menu remains visible for five seconds. If the new desktop is
  unusable, select **NixOS Generation 7** with the arrow keys and Enter.
- Generation 8 is retained, but Generation 7 is the deliberate pre-cutover
  rollback target.
- Holding **Option** at power-on opens Apple's macOS/NixOS picker. That is
  separate from the NixOS generation menu.
- Restart and Power off are not part of the initial exploratory test. Test them
  only when work is saved and a restart is actually wanted.

## 2. Mac keyboard legend

The physical key labels and Linux names differ:

| MacBook key | Linux/config name | Use |
|---|---|---|
| Command `⌘` | Super | Desktop and window shortcuts |
| Option | Alt | Alternate/application shortcuts |
| Physical Control | Ctrl | Copy, paste, terminal controls |
| Return | Enter | Confirm or submit |
| Delete | Usually Backspace | Forward Delete may require Fn+Delete |

Important consequences:

- Use physical **Control+C / Control+V** inside Chrome, Thunar, Kitty, and other
  applications. Command is not the application copy/paste key on this Linux
  desktop.
- Tapping and releasing either Command key by itself toggles Apps.
- `Ctrl+Alt+Delete` may require **Control+Option+Fn+Delete** on the Mac keyboard.
  Clicking the battery icon is the reliable pointer route to power controls.
- There is no built-in Print Screen key. Use **Battery → Capture → Full screen**.
- Function-row behavior depends on the Apple/T2 Fn mode. Try the labeled media
  key alone first, then with Fn if it produces an ordinary F-key instead.

## 3. What a healthy first login looks like

The Mac auto-logs `alex` into Hyprland. After the wallpaper appears, allow
roughly **10–20 seconds** for the first Home Manager activation and graphical
services to settle.

Expected order:

1. The Violet Nokstella wallpaper appears without the Hyprland logo.
2. Three glass Waybar groups appear across the top.
3. Network, Bluetooth, audio, battery, clock, and tray data populate.
4. The bar's status buttons begin opening independent QuickShell panels.

A panel briefly saying that data is unavailable during startup is acceptable.
A bar that never appears, panels that never open, or components repeatedly
disappearing and restarting is not.

The display is fixed to 2560×1600 at 60 Hz with 1.5× scaling, producing about
1707×1067 logical pixels. Only workspaces 1 and 2 exist.

## 4. Desktop map

Waybar is the permanent top taskbar. Hover an unfamiliar item for its tooltip.

### Left group — start menu, pinned apps, running tasks

| Item | Primary click | Middle click | Notes |
|---|---|---|---|
| Apps | Toggle Rofi application search | — | Search-as-you-type; single-click launches |
| Chrome icon | Launch a new Chrome window | — | Separate running-task icon raises an existing one |
| Terminal icon | Launch Kitty | — | Separate running-task icon raises an existing one |
| Files icon | Launch Thunar | — | Separate running-task icon raises an existing one |
| Running task | Focus it; click focused task again to minimize | Close immediately | Active task has a teal underline; minimized task fades |

On the touchpad, a three-finger tap is a middle click. Therefore a three-finger
tap on a running task closes that window immediately.

### Center group — workspaces and active-window controls

| Item | Primary click | Secondary click | Notes |
|---|---|---|---|
| Workspace 1 / 2 | Switch workspace | — | Scrolling here is intentionally disabled |
| Window title | No action | — | Shows the focused title, shortened to 24 characters |
| Float/tile | Toggle active window floating/tiled | Pin/unpin floating window | Float before pinning |
| Maximize | Maximize/restore | — | Fills usable area while retaining the bar |
| Fullscreen | True fullscreen/restore | — | Covers the compositor output |
| Close X | Close active window immediately | — | No confirmation |

Use these visible controls on a disposable window during testing so the guide or
an important browser tab is not accidentally closed.

### Right group — status, media, controls, tray

| Item | Primary click | Middle click | Secondary click | Scroll |
|---|---|---|---|---|
| CPU | Open Mission Center | — | — | — |
| RAM | Open Mission Center | — | — | — |
| Music note | Open Music/EQ | — | — | — |
| Previous / Play / Next | Media action | — | — | — |
| Track title | Open Music/EQ | — | Play/pause | — |
| Volume | Open Sound panel | Mute/unmute | Advanced mixer | ±3% per step |
| Wi-Fi | Open Wi-Fi panel | — | Network editor | — |
| Bluetooth | Open Bluetooth panel | — | Blueman manager | — |
| Battery | Open System & power | — | Wlogout power overlay | — |
| Clock | Open Calendar/weather | — | — | — |
| Bell | Open notification history | — | Toggle DND silently | — |
| Tray icon | Application-defined | Application-defined | Application-defined | Application-defined |

Status appearance:

- Wi-Fi shows signal percentage or a disconnected icon.
- Bluetooth shows off/on or the connected-device count.
- Battery is teal while charging, warns at 25%, and becomes critical at 12%.
- Volume says `mute` while muted.
- The clock tooltip contains a compact calendar.
- Passive tray icons are dim; attention-needed tray items turn red.
- The bell is currently a static icon. It does not show an unread badge or an
  obvious DND state; open the panel to confirm DND.

## 5. How panels behave

Only one QuickShell dropdown is shown at a time. Opening another closes the
current panel. Panels overlay the desktop and do not resize tiled windows.

Close any panel by:

- Clicking the same Waybar item again.
- Clicking outside the panel.
- Pressing Escape.
- Clicking the panel's X header button, when present.

Music and Calendar intentionally have no visible X; use the first three methods.

Expected behavior is a smooth animated reveal below the bar. Every panel fits
inside the single Retina display and its lists scroll with two fingers or a
mouse wheel.

## 6. Touchpad and pointer

Configured behavior:

- One-finger tap/click: primary click.
- Two-finger tap/click: secondary/right click.
- Three-finger tap/click: middle click.
- Two-finger scroll: natural direction at a slightly moderated speed.
- Tap-and-drag: enabled. Lifting the finger ends the drag.
- Disable while typing: enabled for palm/cursor-jump prevention.
- Pointer acceleration: adaptive with slightly positive sensitivity.
- Three-finger horizontal swipe: move between workspaces 1 and 2.
- Swiping past an edge cannot create a third workspace.
- Moving the pointer into another window focuses it without requiring a click.
- Global middle-click paste is disabled.

Window border grab zones extend about 12 logical pixels beyond the visible
2-pixel border. Drag a tiled border to change the split; drag a floating edge or
corner to resize that window.

Apps with their own titlebar can be moved by dragging it. For a client without a
usable titlebar, hold Command and left-drag anywhere in the window. Hold Command
and right-drag anywhere for universal resize.

## 7. Window management and workspaces

Normal new windows tile automatically. Chrome is explicitly kept tiled.

Automatic exceptions:

- Open/save/upload dialogs float centered.
- Network editor, Blueman, EasyEffects, and advanced audio mixers float centered.
- Picture-in-picture floats near the lower-right, preserves aspect ratio, and is
  pinned across both workspaces.
- Floating windows snap to nearby monitor/window edges while retaining gaps.

There is intentionally **no Alt+Tab binding**. Use one of these visible paths:

- Click a running task icon in Waybar.
- Open Apps and choose the **Windows** mode.
- Move the pointer into a visible window.
- Use the optional Command+arrow focus shortcuts.

## 8. Application launcher

Open Apps by clicking the gradient **Apps** button, tapping/releasing Command,
or pressing Command+D.

- It opens in Applications mode with names and icons.
- Search is fuzzy and case-insensitive and filters while typing.
- Hover selects an item; one primary click launches it.
- The list scrolls.
- Escape, outside click, Apps again, or Command again closes it.
- Available modes are Applications, Command, and Windows.
- Windows mode is the pointer-friendly task switcher.

Pinned icons always launch a new window. Running-task icons are what raise or
minimize an existing window.

## 9. Wi-Fi panel

Open by clicking the Waybar Wi-Fi indicator. Opening starts a scan and refreshes
the current IPv4 address; closing stops scanning.

The panel shows adapter state, current SSID, signal percentage, IPv4 address,
Wi-Fi on/off, scanning state, available networks, and an error banner when a
connection fails.

Network actions:

- Connected network: click **Disconnect**. Clicking the row body does nothing.
- Saved network: click the row or **Connect**.
- New open network: click once to connect.
- New personal secured network: click to reveal the password field, type at
  least eight characters, then click Connect or press Return.
- Enterprise network: the mature NetworkManager editor opens.
- **Advanced network settings** opens the full editor for saved profiles and
  less common configuration.

The password stays in the panel/NetworkManager API and is not placed in a shell
process argument.

Safe first test: inspect current SSID, IP, signal, and Scan/Stop. Do not disable
Wi-Fi or disconnect unless temporary loss of internet is acceptable.

## 10. Bluetooth panel

Opening begins a scan if Bluetooth is on. Scanning stops when the panel closes
and also times out after about 15 seconds.

Devices are ordered connected first, paired second, then alphabetically. A row
can show the device-reported battery percentage.

Actions:

- Unpaired device: click the row or Pair.
- Paired device: click the row or Connect.
- Connected device: click the row or Disconnect.
- Pairing device: Cancel stops pairing.
- Paired and disconnected device: X forgets it.
- Advanced Bluetooth settings opens Blueman.

PIN/passkey and uncommon pairing flows may hand off to the Blueman agent. An
empty list is valid when nothing is nearby; **Bluetooth unavailable** is not the
expected state on this MacBook.

## 11. Sound, volume OSD, and advanced mixer

The compact Sound panel shows the current PipeWire output, a 0–100% slider,
Mute/Unmute, and Open mixer. Raising the slider above zero unmutes automatically.
The compact panel controls output only; the advanced mixer handles microphones,
applications, and device routing.

Direct Waybar controls:

- Scroll over Volume: change by 3%, capped at 100%.
- Middle-click/three-finger tap: mute/unmute.
- Primary click: compact panel.
- Secondary click: advanced PipeWire mixer.

A bottom-center QuickShell OSD appears for output-volume changes for about 1.5
seconds. Display brightness and microphone mute use a separate SwayOSD. Seeing
two volume overlays for one change is a failure; seeing one is expected.

## 12. Music, playback, visualizer, and equalizer

Start an MPRIS-capable source such as Chrome media playback. The Waybar track
block appears when the player supplies metadata.

The large Music panel contains:

- Circular album-art vinyl and player identity.
- Playing/paused/idle state, title, artist, album.
- Seek bar and elapsed/total time when the player supports seeking.
- Previous/restart, play/pause, and next.
- 28-band real-time Cava visualizer.
- Ten EQ bands: 32, 64, 125, 250, 500 Hz, 1, 2, 4, 8, and 16 kHz.
- Flat, Bass, Treble, Vocal, Pop, Rock, Jazz, and Classic presets.

Behavior:

- Vinyl rotates once every 12 seconds while playing and pauses with playback.
- Cava only runs while the Music panel is open and audio is playing.
- Previous restarts a seekable track when past eight seconds; otherwise it asks
  for the previous track.
- EQ bands range from −12 to +12 dB in 0.5 dB steps.
- A band change applies when the slider is released and labels the state Custom.
- Presets and custom EQ state persist through EasyEffects and affect real system
  output.
- The actively playing media source wins automatic selection. There is no manual
  player picker yet.
- Album art, next/previous, and seeking depend on what the player exposes.

Test at moderate volume. Select **Flat** after experimenting unless another
preset is intentionally desired.

## 13. System, battery, brightness, capture, and power

Click Battery to open **System & power**. It shows:

- Battery percentage and gauge.
- Charging/time-to-full or estimated time remaining.
- Battery health when the hardware reports it.
- Current power profile and Saver/Balanced/Performance choices.
- Display brightness from 2–100%.
- Wallpaper and color picker.
- Region and full-screen capture.
- Lock, Sleep, Restart, and Power off.

Battery health may be absent, and Performance may be disabled if the hardware
does not expose that profile. Neither is automatically a failure. Balanced is
the normal baseline.

Lock and Sleep act immediately. Restart and Power off require holding the button
for about 1.1 seconds; releasing early cancels. Secondary-clicking Battery opens
a separate Wlogout power overlay; Escape safely closes it.

## 14. Notifications and Do Not Disturb

QuickShell owns notifications normally. Ordinary toasts appear at top-right for
about seven seconds unless the sending app requests something else. Up to four
are visible at once. Critical or persistent notifications may remain.

Toasts can contain an app icon, title, body, time, explicit action buttons, and
an X. Click an explicit action to act; clicking the body alone is not a default
action. X removes the popup but retains its history entry.

The Bell panel:

- Marks entries read when opened.
- Keeps up to 80 recent non-transient notifications for the current QuickShell
  session.
- Supports individual X dismissal, Clear all, live actions, and inline reply
  when an app provides it.
- Has a visible DND switch.

DND suppresses popups but still records history. DND state persists across
logout/reboot; notification history does not. Secondary-clicking the Bell
toggles DND without visible feedback, so open the panel to confirm and leave DND
off after testing.

If QuickShell itself fails, Dunst provides notification-only fallback. In that
degraded state toasts remain available but the QuickShell panels do not.

## 15. Calendar and weather

Click the clock for:

- Large live clock with seconds and full date.
- Monday-first six-week month calendar.
- Previous/next month, selectable dates, and Today reset.
- Chicago current temperature and condition.
- Feels-like, humidity, wind, and rain.
- Five-day high/low outlook.
- Eight upcoming hourly conditions and precipitation bars.
- Manual weather refresh.

Weather uses a 15-minute cache and is requested when the panel opens. If the
network fails, valid cached data is used when possible and the calendar remains
usable. The current location is **Chicago, America/Chicago**, using Fahrenheit,
mph, and inches.

Date selection is visual only; this version does not edit events or schedules.
The selected month/date resets when the panel is unloaded and opened again.

## 16. Wallpaper and adaptive color operation

Open **Battery → Wallpapers & colors**. Waypaper shows the local collection in
three columns. Choosing a thumbnail:

1. Extracts a dark Material palette with Matugen.
2. Validates and atomically installs all theme fragments.
3. Transitions the wallpaper with a roughly one-second animated grow.
4. Recolors QuickShell, Waybar, Hyprland borders, Rofi, Hyprlock, GTK, the
   notification fallback, and the screenshot selector.
5. Stores the selection so it returns on the next login.

The dark glass foundation remains dark even when the source image is light;
wallpapers change semantic accents rather than turning the desktop into a bright
theme.

Immediate versus next-open behavior:

- QuickShell, Waybar, and Hyprland update during the change.
- Rofi and Hyprlock use the new theme the next time they open.
- Newly opened GTK applications and Kitty windows use the new theme.
- Existing Kitty windows intentionally retain their current palette and are
  never signaled or closed.

The initial image is `violet-nokstella-stars.jpeg`. Useful contrast tests are:

- `red-mountain-moon-lake.webp`
- `green-aurora-lake.jpg`
- `cyan-raya-lucaria.jpeg`
- `neutral-somerville-horizon.jpg`
- `light-colossus-hawk.jpg`

Wait a few seconds for one wallpaper/theme change to settle before selecting
the next.

## 17. Screenshots

Pointer route: **Battery → Capture**.

### Select area

1. Click Select area. The power panel closes and waits 300 ms.
2. Drag a rectangle.
3. Press Escape to cancel safely.

### Full screen

Click Full screen. It captures only the internal `eDP-1` display after the power
panel has closed.

Every successful capture:

- Saves `~/Pictures/Screenshots/Screenshot_YYYY-MM-DD_HH-MM-SS.png`.
- Copies PNG image data to the clipboard.
- Sends a Screenshot captured notification.

The region selector uses the current wallpaper-derived accent colors.

## 18. Kitty terminal

Kitty has 10,000 lines of scrollback, transparent glass styling, a clickable tab
bar at the top, and no close confirmation.

Mouse selection does **not** copy automatically.

| Action | Result |
|---|---|
| Click-drag | Select text |
| Ctrl+C with selection | Copy selection |
| Ctrl+C without selection | Interrupt the running command |
| Ctrl+V | Paste clipboard |
| Ctrl+Shift+C | Explicit copy |
| Ctrl+Shift+V | Explicit paste |
| Shift+Insert | Paste primary-selection buffer |
| Ctrl+Shift+T | New tab in current directory |
| Ctrl+Shift+W | Close active tab |
| Ctrl+Tab | Next tab |
| Ctrl+Shift+Tab | Previous tab |

If text remains selected, Ctrl+C copies rather than interrupts. Clear the
selection before using Ctrl+C to stop a command. Closing the whole Kitty window
does not ask for confirmation, even with several tabs.

Fish starts without a greeting; `nano` is the configured terminal editor.

## 19. Lock, idle, lid, and suspend

Manual lock:

- Battery → Lock.
- Command+L.

The lock screen hides the cursor and shows the current blurred wallpaper, clock,
date, avatar, `alex`, Wi-Fi SSID, and battery state. Start typing the normal
Linux account password and press Enter. This is the `alex` account password, not
a separate PIN.

Automatic idle sequence:

- Five minutes: brightness changes to 20%.
- Activity restores the previous brightness.
- Ten minutes: session locks.
- Eleven minutes: display powers off.
- Pointer movement or a key wakes the display, but the session stays locked.

Idle does not suspend the Mac; background processes continue. Video/browser
idle inhibitors may legitimately postpone these timers.

Suspend routes:

- Battery → Sleep: immediate suspend.
- Close the lid: suspend on battery or charger.
- Physical power key: suspend, not shutdown.

The session locks before sleep. On resume, unlock normally and verify Wi-Fi,
Waybar, panels, audio, and brightness controls recover.

## 20. Complete optional shortcut reference

Everything essential has a pointer route except universal movement of an
undecorated floating client.

| Shortcut | Action |
|---|---|
| Tap/release Command | Toggle Apps |
| Command+D | Toggle Apps |
| Command+Return | Open Kitty |
| Command+E | Open Thunar |
| Command+B | Open Chrome |
| Command+Q | Close active window |
| Option+F4 | Close active window |
| Command+F | Maximize/restore |
| Command+Shift+F | Fullscreen/restore |
| Command+Space | Float/tile |
| Command+J | Toggle the next dwindle split direction |
| Command+arrow | Focus adjacent window |
| Command+Shift+arrow | Move active window in that direction |
| Command+1 / Command+2 | Switch workspace |
| Command+Shift+1 / 2 | Move active window there and follow |
| Command+L | Lock |
| Control+Alt+Delete | Toggle power panel |
| Command+Shift+S | Region screenshot |
| Print | Full screenshot, normally external keyboard only |
| Command+left-drag | Move window from anywhere |
| Command+right-drag | Resize window from anywhere |

Function/media keys remain active on the lock screen:

- Speaker volume up/down: repeatable 5% steps, capped at 100%.
- Speaker mute: toggle.
- Microphone mute: toggle.
- Display brightness up/down: repeatable with 2% floor.
- Keyboard backlight up/down: repeatable 10% steps; no dedicated OSD.
- Play/Pause, Previous, Next, Stop: current MPRIS player when supported.

## 21. First-reboot acceptance checklist

Run the tests in this order. It keeps network and power disruptions until late
and uses disposable windows for destructive window controls.

### Stage A — boot and identity

- [ ] Charger connected; Generation 9 selected/default.
- [ ] Auto-login reaches Hyprland.
- [ ] Violet wallpaper, three glass bar groups, and workspaces 1/2 appear within
      10–20 seconds.
- [ ] Click Apps, search `Aurora Guide`, and open the interactive guide.
- [ ] Open Kitty and run `readlink -f /run/current-system`; it exactly matches
      the closure printed at the top of this guide.
- [ ] Run `codex --version` and `claude --version`; both launch successfully.

Optional technical health check in Kitty:

```sh
systemctl --user --failed --no-pager
systemctl --user is-active aurora-wallpaper aurora-shell waybar hypridle swayosd easyeffects
systemctl --user show aurora-wallpaper-init.service -p Result -p ExecMainStatus
hyprctl configerrors
```

Expected: no failed units; six `active` lines; wallpaper init `Result=success`
and `ExecMainStatus=0`; no Hyprland config errors. The completed wallpaper-init
one-shot may itself be inactive. The Dunst fallback should normally be inactive.

### Stage B — pointer, touchpad, launcher

- [ ] One-finger primary click works.
- [ ] Two-finger right click works.
- [ ] Natural two-finger scrolling feels correct.
- [ ] Three-finger swipe changes only between workspaces 1 and 2.
- [ ] While typing continuously in Kitty, touching/resting a palm on the pad does
      not move the pointer unexpectedly.
- [ ] Apps filters while typing and launches with one click.
- [ ] Bare Command toggles Apps.
- [ ] Chrome, Terminal, and Files pinned buttons launch.
- [ ] Running-task click focuses/minimizes; middle-click closes a disposable task.

### Stage C — windows and workspaces

- [ ] Two or more normal windows tile automatically.
- [ ] Dragging their shared border resizes the split.
- [ ] On a disposable Kitty: float/tile works.
- [ ] Maximize/restore works.
- [ ] Fullscreen/restore works.
- [ ] A titlebar or Command+left-drag moves a floating window.
- [ ] Command+right-drag resizes it.
- [ ] Center-bar X closes only the intended disposable window.
- [ ] Workspace clicks and swipe both work.
- [ ] Pinning a floating disposable window makes it visible on both workspaces;
      unpin afterward.

### Stage D — panel framework

- [ ] Music, Volume, Wi-Fi, Bluetooth, Battery, Clock, and Bell each open.
- [ ] Opening a second panel closes the first.
- [ ] Same icon, outside click, and Escape all dismiss panels.
- [ ] Panels animate smoothly and stay within the display.
- [ ] Panel lists scroll.

### Stage E — network and Bluetooth

- [ ] Wi-Fi panel shows current SSID, signal, and IPv4 address.
- [ ] Current network appears first; Scan/Stop responds.
- [ ] Chrome opens a website.
- [ ] Advanced network settings opens and can be closed.
- [ ] Bluetooth adapter is present; scan starts and stops after about 15 seconds.
- [ ] Nearby/paired devices populate when available.
- [ ] Advanced Bluetooth settings opens and can be closed.
- [ ] Optional: deliberately pair/connect one accessory.

Do not disable Wi-Fi or disconnect from the current network during the safe pass.

### Stage F — audio, media, EQ

- [ ] Function-row volume up/down changes actual sound and shows one OSD.
- [ ] Speaker mute key works.
- [ ] Waybar volume scroll and middle-click stay synchronized with Sound.
- [ ] Sound slider works and Open mixer launches.
- [ ] Start Chrome media at moderate volume.
- [ ] Waybar metadata and supported transport buttons respond.
- [ ] Music panel shows state, metadata, timeline, vinyl, and visualizer.
- [ ] One EQ preset and one band are audibly applied.
- [ ] Select Flat after the test unless keeping another preset intentionally.

### Stage G — battery, brightness, power profile

- [ ] Battery panel and Waybar percentage agree.
- [ ] Charging/remaining status updates.
- [ ] Saver and Balanced can be selected; return to Balanced.
- [ ] Performance disabled is accepted if unsupported.
- [ ] Brightness function keys work with one SwayOSD.
- [ ] Brightness slider works and never reaches black; return to comfort level.
- [ ] Optional: unplug/reconnect charger and observe charging state.
- [ ] Restart/Power off hold progress begins, then release early to cancel.

### Stage H — notifications and DND

- [ ] Capture a small region to generate a styled screenshot toast.
- [ ] Bell history contains the screenshot notification.
- [ ] Individual X and Clear all work.
- [ ] Turn DND on in the panel.
- [ ] Capture another small region: no toast appears, but history records it.
- [ ] Turn DND off again.

Optional explicit test from Kitty:

```sh
notify-send -a "Aurora Test" "Notification test" "Toast and history are working."
```

### Stage I — calendar and weather

- [ ] Clock opens the large live clock/calendar.
- [ ] Previous month, next month, date selection, and Today work.
- [ ] Chicago current, hourly, and five-day weather appear.
- [ ] Manual refresh responds.
- [ ] Escape closes the panel.

### Stage J — wallpaper and colors

- [ ] Power → Wallpapers & colors opens the three-column picker.
- [ ] Select a red wallpaper and wait for transition/recoloring.
- [ ] Select green, cyan, or neutral light and wait again.
- [ ] Waybar, panels, borders, and selection accents visibly change.
- [ ] Reopen Apps: Rofi uses the new palette.
- [ ] Open a new Kitty: it uses the new palette while the old Kitty remains
      unchanged.
- [ ] Lock later: the lock screen uses the current wallpaper/palette.
- [ ] Keep the favorite selection or restore Violet Nokstella.

### Stage K — screenshots and clipboard

- [ ] Select area closes the panel, waits briefly, and captures a dragged region.
- [ ] Escape cancels a second selection without making a file.
- [ ] Full screen does not contain the closing power panel.
- [ ] Both timestamped PNGs appear under Pictures/Screenshots.
- [ ] The Screenshot captured toast appears when DND is off.
- [ ] `wl-paste --list-types` includes `image/png` after capture.

### Stage L — Kitty behavior

- [ ] Select text, Ctrl+C copies, and Ctrl+V pastes.
- [ ] With no selection, run `sleep 30`; Ctrl+C interrupts it.
- [ ] New tab, close tab, next tab, and previous tab shortcuts work.
- [ ] Scrollback and mouse tab selection work.

### Stage M — lock and suspend, last

- [ ] Power → Lock shows blurred current wallpaper, clock/date/avatar, SSID, and
      battery.
- [ ] Normal `alex` account password unlocks.
- [ ] Command+L repeats the same behavior.
- [ ] Save all work, then Power → Sleep suspends.
- [ ] Resume lands on lock, then Wi-Fi, Waybar, panels, audio, and brightness
      recover after unlock.
- [ ] Optional: close/reopen lid for a second suspend test.

The 5/10/11-minute idle sequence can be tested later; manual lock and suspend are
sufficient for the initial pass.

## 22. Acceptance report template

Mark `PASS`, `FAIL`, or `SKIP` and send this section back to Codex:

```text
Aurora first-boot acceptance
Date/time:
Overall: PASS / PASS WITH ISSUES / ROLLBACK

B01  Generation 9 and automatic login:
B02  Wallpaper, Waybar, and startup timing:
B03  User services and Hyprland config errors:
I01  Pointer, touchpad, palm rejection:
I02  Workspaces and three-finger gesture:
I03  Launcher, pinned apps, task buttons:
W01  Tiling, resize, float, maximize, fullscreen, close:
P01  Panel open/close/exclusion behavior:
N01  Wi-Fi status, scan, and internet:
N02  Bluetooth adapter, scan, optional pairing:
A01  Audio slider, mute, function keys, one OSD:
M01  Media controls, metadata, visualizer:
M02  Equalizer and restored final preset:
P02  Battery, charging state, power modes:
P03  Brightness slider and function keys:
T01  Notification toast and history:
T02  Notification action and DND left OFF:
C01  Calendar and Chicago weather:
V01  Wallpaper transition and live recoloring:
V02  Rofi/new Kitty/lock-screen recoloring:
S01  Region screenshot file and clipboard:
S02  Full-screen screenshot file and clipboard:
L01  Manual lock and password unlock:
R01  Suspend, locked resume, Wi-Fi recovery:
D01  codex --version:
D02  claude --version:

Notes / exact symptoms / screenshot filenames:
```

## 23. Recovery and evidence

If only Waybar or panels fail, open Kitty and run:

```sh
systemctl --user restart aurora-shell.service
systemctl --user restart waybar.service
```

If the wallpaper is missing:

```sh
systemctl --user restart aurora-wallpaper.service
systemctl --user restart aurora-wallpaper-init.service
```

Collect evidence without changing configuration:

```sh
hyprctl configerrors
systemctl --user --failed --no-pager
journalctl --user -b \
  -u aurora-shell.service \
  -u waybar.service \
  -u aurora-wallpaper-init.service \
  --no-pager -n 150
```

If the graphical desktop is unusable:

1. Try Control+Alt+F2; the Mac may require Fn for the F2 key.
2. If needed, reboot.
3. At the five-second systemd-boot menu, choose **NixOS Generation 7**.
4. Stop there and report what happened. Do not overwrite Home Manager symlinks
   manually.

Detailed symlink-safe restoration instructions remain at:

```text
/home/alex/nix/docs/recovery.md
```

Holding Option at power-on opens the Apple OS picker if macOS is needed.

## 24. Intentional current limitations

These are not first-boot regressions:

- No Alt+Tab binding; use task icons or Apps → Windows.
- Only workspaces 1 and 2.
- Only one QuickShell dropdown visible at once.
- Bell has no unread badge and no visible Waybar DND state.
- Music and Calendar have no in-panel X.
- Calendar date selection does not manage events.
- Compact Sound panel controls output only.
- Enterprise Wi-Fi and uncommon Bluetooth authentication use external editors.
- Notification history resets with QuickShell/logout/reboot; DND persists.
- Existing Kitty windows keep the palette they started with after wallpaper
  changes; new Kitty windows use the new palette.
- Album art, media seeking, and track controls depend on the player exposing
  those MPRIS capabilities.
