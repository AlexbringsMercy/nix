# XBOX CONTROLLER — BLUETOOTH DIAGNOSTIC RECORD

Controller `68:6C:E6:89:FF:EA` (Xbox Series X|S, `v045Ep0B13`) · adapter `14:7D:DA:4D:2A:01`
(Broadcom BCM4377) · BlueZ 5.86 · kernel `linux-t2-6.18.35`. Captured 2026-07-29.

Binary captures are deliberately **not tracked in Git**. They live under
`~/.local/state/aurora-build/xbox-known-good/` and are referenced by path and checksum below.

## Classification — authoritative

| Claim | Status |
|---|---|
| Current physical failure (flashing until power-off timeout) | **proven** (operator, repeated) |
| A correct immediate connection is achievable | **proven** — live instrumented, 917 ms |
| Reliable repeatability | **unproven** |
| Absolute incompatibility / "Linux can't do this" | **disproven** |
| gen 31 → 32 regression | **unproven — do not label it one** |
| Last generation in which it demonstrably worked | **unknown** — not connection-tested for several generations |
| Root cause | **unknown** |
| Five preserved pairing records | proven present; proves file preservation only, **not** connectivity |

**One successful attempt does not close the issue.**

## Recorded physical state at session termination

- The controller later connected **immediately through the ordinary graphical action**.
- The connection remained stable for **at least 13 minutes** (1148 s at last check).
- BlueZ reported **`ServicesResolved = true`**.
- Battery reported **90 %**.
- **No BlueZ or kernel errors** during that successful interval.
- **LED steadiness and input-device functionality were still awaiting Alex's confirmation.**

## No generation delta in the Bluetooth stack

Verified identical between gen 31 and gen 32 by `readlink -f` / `diff` on both system closures:
BlueZ store path (`m3hi0c84…-bluez-5.86`), kernel (`h38jyjhv…-linux-t2-6.18.35`),
`kernel-modules`, `initrd`, `/etc/bluetooth/main.conf`, `/etc/systemd/system/bluetooth.service`,
`/etc/udev/rules.d`, every `…blue*` store reference under `/etc`, and all D-Bus `system.conf`
policy/allow/deny rules. The only `/etc` deltas were `dbus-1`, `etc-profile` and
`set-environment`, and the `dbus-1` difference is confined to `<servicedir>`/`<includedir>`
paths that track the changed `system-path`.

## Known-good connection (comparator)

| Stage | Value |
|---|---|
| UI Connect request | `21:50:14.017019`, D-Bus `:1.38` = PID 1857 = caelestia-shell (the graphical button) |
| HCI | `LE Enhanced Connection Complete (0x0a)`, handle 64, +363 ms |
| Address type | `public` (matches the bond) |
| Encryption | `LE Start Encryption` → `Encryption Change: Enabled with AES-CCM (0x01)` |
| Bond | existing LTKs reused, `Authenticated=2`, `EncSize=16` — no re-pair |
| Profiles | batt / deviceinfo / gap / input-hog all `disconnected → connected (0)` |
| HOGP | `bt_hog_attach()` → `uhid_create()`; `bcdHID 0x0101`; report 0x01 input / 0x03 output |
| Kernel driver | `microsoft` bound **directly** on `0005:045E:0B13.000A` |
| Devices | `input15` → `/dev/input/event13`, `/dev/input/js0`, `/dev/hidraw8` |
| Connection params | `min 0x0006 max 0x0006 latency 0 timeout 0x012c` |
| ServicesResolved | `true` at `21:50:14.934` — **917 ms end to end** |
| Battery | 50 % → 90 %, live notifications |
| Errors / disconnects | **none** in btmon or journal |

Stored bond (`/var/lib/bluetooth/…/info`, keys redacted): `AddressType=public`,
`SupportedTechnologies=LE;`, `Trusted=true`, IRK + both LTKs present, `Authenticated=2`,
`EncSize=16`, `[ConnectionParameters] MinInterval=6 MaxInterval=6 Latency=0 Timeout=300`.
**The bond is intact — a bond/authentication failure is rejected as a cause.**

## Failed attempts — what exists, and what does not

Only the shell's own D-Bus error text exists. `bluetoothd` ran at default verbosity and `btmon`
was not armed, so **there is no HCI trace and no daemon trace for any failure.**

```
gen 31  20:45:13.067  "Did not receive a reply … the reply timeout expired"
        20:45:18.263 / :20.832 / :22.927   "In Progress"   (operator re-clicking)
        20:45:29.615  kernel HID bind — BlueZ bound the device 16.5 s AFTER the UI reported failure
gen 32  21:25:23.515  "Did not receive a reply …"
        21:28:39.954  kernel HID bind — ~3 min after the UI reported failure
        21:37:57.518 / 21:45:10.514 / 21:45:53.513   "Did not receive a reply …"
        21:45:16.230 / :17.596 / :18.210             "In Progress"
```

No `org.bluez` error name appears in any of the five timeouts — they are **client-side
expiries**. `InProgress` on the re-clicks shows BlueZ still had the original `Connect()` in
flight, i.e. the daemon had not failed.

**Important qualification:** the `20:45:29` and `21:28:39` kernel bind lines are **historical
journal finds, not instrumented attempts**. They carry no BlueZ state, no encryption result, no
ServicesResolved, no duration and no LED state, and therefore do **not** establish a working
connection. A driver-bind line followed by an immediate disconnect would still be a failure.

## First observed divergence — cause vs consequence not established

| | late-success (20:45:29, 21:28:39) | known-good (21:50:14) |
|---|---|---|
| uhid device id | `…0B13.0009` | `…0B13.000A` |
| first driver bind | `hid-generic` | `microsoft` (direct) |
| second bind | `microsoft` +13…25 ms | none |
| input devices created | two (`input13`, `input14`) | one (`input15`) |
| preceded by a UI timeout | yes | no |

## Evidence gap the next PM must close

The HCI status of a failing attempt is unknown; whether a failing attempt reached
`LE Create Connection` or was still pending is unknown; whether the peripheral was advertising
at click time is unknown. Alex must **not** be asked to reproduce failures repeatedly — arm
passive instrumentation and wait for the next natural occurrence.

## Preserved evidence

`~/.local/state/aurora-build/xbox-known-good/`

| File | Size | SHA-256 |
|---|---|---|
| `known-good-connect.btsnoop` | 283 297 | `14a97bb98d3aa51b4aca0ebb90efb2fff04ddcdd38b8ac3fc1b2db87091e90f2` |
| `session-full.btsnoop` | 7 483 020 | `0262d9bac015bd88f18feeb55cf90358b2d3b5a6953783873e1ab333dea15d49` |
| `known-good-bluetoothd.log` | 31 799 | `eda9173ce8e243ddae43001274784bf3dffb90ca93504456d540d81fd70c6f92` |
| `known-good-kernel.log` | 1 236 | `2ebb682cc84e44de40e2e68ff1d4a3313f16970e5e9c9937b0a0371ba33ff33c` |
| `known-good-215309.txt` | 1 886 | `642c144993767f81415da3f164766aacea4a0e0fca98c68ba12c68ebfc533b14` |
| `DIAGNOSIS.md` | 5 159 | `36454348e65a522ca8eed5cdfe11bf21490faf0c9970b3f158e99f98cf2b3109` |

Plus `CHECKSUMS.txt` and `codex-attempts-INCOMPLETE/`.

## Diagnostic state left running

`btmon` was **stopped and flushed**. `bluetoothd` **remains in runtime debug mode**, enabled by
`kill -USR2 1050`. This was **not** a configuration or override change — `/etc/bluetooth/main.conf`
is untouched, and a normal service start comes up at default verbosity. It was left enabled so a
natural failure still yields daemon-level evidence.

- Restore normal logging live, no restart: `sudo kill -USR1 1050`
- Re-arm HCI capture: `sudo btmon -w <path>`

Bluetooth was **not** restarted. The controller was **not** disconnected, forgotten or re-paired.
The LE 7/9 interval tuning was **not** altered. The other four pairings (a Tuya device, two Hue
devices, a WHOOP band) were untouched.

## Acceptance gate (not yet met)

Five consecutive power-off/power-on reconnect cycles · three explicit UI disconnect/connect
cycles · one reconnect after suspend/resume · one reconnect after the next cold boot · ten
minutes of stable connected use · buttons, sticks and triggers functional each time · unrelated
pairings intact · no authentication, HCI, service-resolution or driver errors. Record connection
latency for every attempt. Any flashing-until-timeout failure keeps the gate open.
