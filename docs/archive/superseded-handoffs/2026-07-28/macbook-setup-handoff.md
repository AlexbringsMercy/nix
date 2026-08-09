# MacBook NixOS Setup — Handoff Brief

## What This Document Is
This is a handoff brief for Claude. The user (Alex) and Claude spent the majority of a long chat getting NixOS installed on a MacBook Air. The granular installation steps, debugging, and troubleshooting consumed significant context window space. This document summarizes everything that was done so a new chat can pick up where we left off without re-reading the entire installation history.

**Fork point:** This document replaces everything after the message where Alex said "Alright I'm gonna start with just this single one..." (the ilyamiro video analysis message). Everything before that — the Linux vs Windows vs macOS discussion, the distro comparison, the Hyprland exploration, the widget framework analysis, the ilyamiro video breakdown, and the build spec creation — is the actual design conversation that should stay in context.

---

## The Machine

**2020 MacBook Air Retina 13-inch**
- Intel Core i3 1.1GHz dual-core (Ice Lake)
- Intel Iris Plus Graphics (1536MB)
- 8GB LPDDR4X 3733MHz (soldered, not upgradeable)
- 250GB SSD (now partitioned: 120GB macOS Sequoia, 121.7GB NixOS)
- 13.3" Retina display, 2560x1600 native resolution
- Apple T2 security chip
- Two Thunderbolt 3 / USB-C ports
- Broadcom WiFi/BT chip (requires proprietary Apple firmware)
- Apple keyboard (Command key = Super in Linux)

**Why we converted it:** The MacBook was running macOS Sequoia 15.7.5 and had slowed to a crawl — struggling with a single Chrome tab, auto-suspending second tabs. macOS was consuming most of the 8GB RAM at idle. Linux gives back ~2-3GB of that. Alex decided to install NixOS here first as a test run before doing the Alienware 14 (the primary machine, still on Windows 10).

**Peripherals available:** CalDigit TS3+ Thunderbolt dock (has USB-A ports, Ethernet, etc. but has known re-enumeration issues causing periodic device disconnects), SanDisk Ultra USB 3.0 32GB flash drive.

---

## What Was Done — Installation Summary

### Pre-Installation on macOS
1. Backed up Sara's files from her user profile to the SanDisk USB, then transferred to the Alienware
2. Cleaned Alex's user profile data (~22GB freed), deleted unused apps (GarageBand, iMovie, Keynote, etc.), cleared Application Support (11GB Claude app data, 6.7GB Chrome data)
3. Ran First Aid on the APFS filesystem — passed clean despite some APFS read errors from the Linux APFS driver earlier
4. Disabled Secure Boot and enabled External Boot via macOS Recovery (Cmd+R → Startup Security Utility → No Security + Allow External Media)
5. Shrunk the macOS APFS container from 250.7GB down to 120GB using `sudo diskutil apfs resizeContainer disk0s2 120g` — freed 130GB for NixOS
6. Time Machine snapshots couldn't be deleted due to SIP, but the resize succeeded anyway

### USB Preparation
- Downloaded `nixos-t2-iso-minimal.iso` from https://github.com/t2linux/nixos-t2-iso/releases/tag/v6.18.35 (latest: kernel 6.18.35, NixOS 26.05)
- Flashed to SanDisk USB using `dd` from macOS Terminal: `sudo dd if=~/Downloads/nixos-t2-iso-minimal.iso of=/dev/rdisk2 bs=1m`
- The minimal ISO was a single file (not split), ~1.4GB

### Booting the Live Environment
- Boot with Option (⌥) key held → select "EFI Boot" (left one if two appear)
- Lands at `[nixos@nixos:~]$` terminal prompt — no GUI in minimal ISO

### WiFi Firmware Extraction (Critical T2 Step)
The Broadcom WiFi chip requires Apple-proprietary firmware that must be extracted while macOS still exists on disk.

```bash
sudo mkdir -p /lib/firmware/brcm
sudo get-apple-firmware
# Selected option 2: "Retrieve the firmware directly from macOS"
```

This mounted the macOS partition, extracted firmware files, and copied them to `/lib/firmware/brcm/`. The APFS driver showed "bad node" and "unable to read catalog root node" warnings but completed successfully. These errors were from the Linux APFS driver, not actual filesystem corruption (First Aid passed clean).

**WiFi instability in live environment:** The Broadcom driver was extremely flaky — constantly spamming timeout errors, dropping and reconnecting. Required multiple `sudo modprobe -r brcmfmac; sudo modprobe brcmfmac` reload cycles. The driver would load, scan would work briefly, then fail. Eventually got WiFi connected by immediately running `nmcli device wifi connect "Soltech" password "PASSWORD"` right after a modprobe reload before the driver could drop again. `sudo dmesg -n 1` suppresses the kernel log spam.

### Partitioning
The macOS resize left free space at the end of the drive. Created one Linux partition:

```bash
sudo fdisk /dev/nvme0n1
# n → partition 3 → defaults for start/end → w
# Created 121.7GB Linux filesystem partition (nvme0n1p3)

sudo mkfs.ext4 /dev/nvme0n1p3
sudo mount /dev/nvme0n1p3 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot  # Shared macOS EFI partition
```

**Drive layout after partitioning:**
- `/dev/nvme0n1p1` — 300MB EFI System Partition (shared with macOS, FAT32)
- `/dev/nvme0n1p2` — 111.8GB macOS APFS container
- `/dev/nvme0n1p3` — 121.7GB NixOS ext4 root

### NixOS Configuration
Generated initial config with `sudo nixos-generate-config --root /mnt`, then replaced it by pulling from GitHub.

**Key approach:** Alex created a public GitHub repo at `https://github.com/AlexbringsMercy/nix` to host the configuration.nix. Claude writes the config file, Alex uploads it to GitHub from the Alienware, then on the MacBook:
```bash
sudo curl -o /etc/nixos/configuration.nix "https://raw.githubusercontent.com/AlexbringsMercy/nix/main/configuration.nix"
sudo nixos-rebuild switch
```

This avoids typing long Nix configs on the MacBook keyboard.

### Firmware Handling Issue
The WiFi firmware files were copied to `/mnt/etc/nixos/firmware/brcm/` but ended up nested: the actual files were at `/etc/nixos/firmware/brcm/brcm/*` instead of `/etc/nixos/firmware/brcm/*`. This was caused by `cp -r` copying the directory structure inside itself. Fixed by flattening:
```bash
sudo cp /etc/nixos/firmware/brcm/brcm/* /etc/nixos/firmware/brcm/
sudo rm -rf /etc/nixos/firmware/brcm/brcm
```

The configuration.nix firmware derivation references these files to install them into the system:
```nix
hardware.firmware = [
  (pkgs.stdenvNoCC.mkDerivation {
    name = "brcm-firmware";
    buildCommand = ''
      dir="$out/lib/firmware"
      mkdir -p "$dir"
      cp -r ${/etc/nixos/firmware/brcm} "$dir/brcm"
    '';
  })
];
```

### Installation
```bash
sudo nixos-install
# Set root password when prompted
sudo nixos-enter --command "passwd alex"
# Set alex user password
sudo reboot
```

### Post-Install Issues and Fixes

**WiFi on installed system:** Initially failed with "Firmware has halted or crashed" because `/lib/firmware/brcm/` was empty — firmware didn't make it through the Nix derivation. Fixed by manually copying firmware files and reloading the driver. After fixing the nested directory issue and rebuilding, firmware loads correctly from boot. The driver still needed the initial modprobe reload on first boot but subsequent boots work.

**Claude Code installation:** `sudo npm install -g` fails on NixOS because the Nix store is read-only. Fixed with:
```bash
mkdir -p ~/.npm-global
npm install -g @anthropic-ai/claude-code --prefix ~/.npm-global
export PATH="$HOME/.npm-global/bin:$PATH"
```
Same approach for Codex: `npm install -g @openai/codex --prefix ~/.npm-global`

**Dynamic linker issue:** Claude Code failed with "Could not start dynamically linked executable: claude / NixOS cannot run dynamically linked executables intended for generic linux environments out of the box." Fixed by adding `programs.nix-ld.enable = true;` to configuration.nix and rebuilding.

**Package name changes in NixOS 26.11:** Several packages have been renamed since older guides:
- `rofi-wayland` → `rofi` (merged)
- `noto-fonts-emoji` → `noto-fonts-color-emoji`
- `fira-code-nerdfont` → `nerd-fonts.fira-code`

**Hyprland non-legacy parser:** Hyprland 0.55 defaults to a Lua config parser. Commands like `hyprctl keyword input:touchpad:disable_while_typing true` fail with "keyword can't work with non-legacy parsers. Use eval." Need to use `hyprctl keyword` with the eval dispatch or use the Lua config format. Codex created both `hyprland.conf` and `hyprland.lua` to handle this.

**Chrome dying when parent terminal closes:** Launch Chrome detached: `google-chrome-stable &disown`. Or create a launcher script/desktop entry so it's independent.

**Mac keyboard mapping:** Command (⌘) = Super, physical Control key = Ctrl. Users coming from Mac need to adjust — Ctrl+C in terminal is the physical control key, not command.

**Copy/paste in Kitty:** Default is Ctrl+Shift+C/V. User strongly prefers Ctrl+C/V. Fix in kitty.conf: `map ctrl+c copy_or_interrupt` (copies if text selected, sends interrupt if not) and `map ctrl+v paste_from_clipboard`.

---

## Current State of the System

### What's Installed and Working
- NixOS 26.11 booting from internal SSD
- Dual-boot with macOS (hold Option at boot to choose)
- Hyprland compositor running with auto-login via greetd
- Google Chrome (with allowUnfree)
- Kitty terminal
- Fish shell (default for alex)
- Waybar (running but needs configuration work)
- Rofi app launcher
- PipeWire audio
- WiFi (Broadcom, working from boot)
- Node.js 22 with Claude Code and Codex installed via npm --prefix ~/.npm-global
- programs.nix-ld.enable = true (for dynamically linked executables)
- Thunar file manager
- Screenshot tools (grim + slurp)
- brightnessctl
- Adwaita cursor theme
- FiraCode Nerd Font, Noto fonts

### What's NOT Working or Not Set Up Yet
- Hyprland config is a mess — keybinds not intuitive, window management awkward
- Waybar is janky — needs proper taskbar layout with clickable launchers
- No proper touchpad disable-while-typing (hyprctl keyword fails with non-legacy parser)
- Copy/paste not configured properly in Kitty
- No notification daemon configured
- No lock screen configured
- No wallpaper set (just default Hyprland crystals)
- No Matugen/color theming
- No QuickShell widgets
- No glassmorphic effects
- Desktop is functional but rough — user can open Chrome and terminals but struggles with basic window management
- Fractional scaling set to 1.5x but some elements may still be small

### Key Files
- `/etc/nixos/configuration.nix` — main NixOS system config (T2 imports, packages, services)
- `/etc/nixos/hardware-configuration.nix` — auto-generated hardware detection
- `/etc/nixos/firmware/brcm/` — Broadcom WiFi/BT firmware files
- `~/.config/hypr/hyprland.conf` — Hyprland config (Codex created this)
- `~/.config/hypr/hyprland.lua` — Hyprland Lua config (Codex created for 0.55 compat)
- `~/.config/waybar/config` and `style.css` — Waybar config (Codex created)
- `~/.config/kitty/kitty.conf` — Kitty terminal config (Codex created)
- `~/.config/rofi/config.rasi` — Rofi config (Codex created)
- `~/.config/fish/config.fish` — Fish shell config
- `~/.bashrc` — Bash config (PATH for npm global)
- GitHub repo: https://github.com/AlexbringsMercy/nix

### Important NixOS Commands
- `sudo nixos-rebuild switch` — rebuild system from configuration.nix (no reboot needed for most changes)
- `sudo nano /etc/nixos/configuration.nix` — edit system config
- `hyprctl reload` — reload Hyprland config without restarting
- `nmcli device wifi connect "SSID" password "PASS"` — connect to WiFi
- `nmcli device wifi list` — scan for networks

---

## What Needs to Happen Next

The user wants Codex to do a FULL setup by pulling from proven community NixOS + Hyprland builds — not writing configs from scratch (that approach produced broken results). The strategy:

1. Codex searches for polished NixOS + Hyprland community dotfiles/flakes
2. Pulls from multiple sources to build a complete stack
3. Adapts everything for T2 MacBook hardware constraints
4. Preserves existing T2-specific configuration.nix elements
5. Delivers a fully functional desktop where EVERYTHING works via mouse clicks

The user has a separate file (`macbook-build-spec.md`) with the full design intent, visual direction, interaction philosophy, and component choices. Codex should read that file for requirements.

The user's priority order:
1. **Phase 1 (NOW):** Fully functional desktop — proper window management, clickable taskbar, working touchpad, copy/paste, function keys, screenshots, app launching
2. **Phase 2 (next session):** Visual polish — glassmorphism, animations, Matugen theming, wallpapers, lock screen
3. **Phase 3 (future):** Custom QuickShell widgets — music player, weather, system dashboards, dev workflow launcher
4. **Phase 4 (future):** Port the whole setup to the Alienware 14
