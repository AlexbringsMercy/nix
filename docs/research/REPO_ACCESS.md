# REPO ACCESS — Read From Disk, Not GitHub

**CRITICAL: All reference repositories are cloned locally under `~/nix/repos/`.** Read code from these local paths. Do NOT web-fetch, git-clone, or search GitHub for repo content — the code is already on disk and directly readable via filesystem access. Web search is still appropriate for wiki pages, community discussions, and repos NOT in this list.

## Repo → Local Path Map

| Repo | Local path | Notes |
|------|-----------|-------|
| ilyamiro/nixos-configuration | `~/nix/repos/ilyamiro-nixos-configuration/` | The 15k LOC QML QuickShell build. 90.5% QML. |
| ilyamiro/shell-wallpapers | `~/nix/repos/ilyamiro-shell-wallpapers/` | Companion wallpaper collection |
| agridyne/dotfiles-dt | `~/nix/repos/agridyne-dotfiles-dt/rice-contents/` | **IMPORTANT: actual config was inside My Rice.zip, now unzipped to `rice-contents/`.** The README + zip are at the repo root; the real code is in the subdirectory. Previous sessions could never read this — you are the first to have access. |
| caelestia-dots/caelestia | `~/nix/repos/caelestia/` | The MAIN repo (not just /shell). Includes launcher, sidebar, Nexus settings, lock, etc. |
| snowarch/iNiR | `~/nix/repos/inir/` | 210k LOC QuickShell shell. Aurora/angel presets, dock, glass tuner, palette system. Niri-first — needs Hyprland compat. |
| cxOrz/dotfiles-hyprland | `~/nix/repos/cxorz-dotfiles-hyprland/` | QuickShell panel backends: WiFi, BT, volume, notifications, power, shelf. |
| mubin-thinks/minimal-wm-config | `~/nix/repos/mubin-minimal-wm-config/` | Theming/cohesion reference. Themes at `/themes/`, showcases at `/showcases/`. |
| nathanhoulamy/macos-dotfiles | `~/nix/repos/nathanhoulamy-macos-dotfiles/` | Theming reference with previews. |
| SherLock707/hyprland_dot_yadm | `~/nix/repos/sherlock707-hyprland-dot-yadm/` | Codeberg source. Wallpaper color-picking/theming. |
| liixini/skwd-wall | `~/nix/repos/liixini-skwd-wall/` | Wallpaper picker — DECIDED FINAL (§15). |
| saatvik333/hyprland-dotfiles | `~/nix/repos/saatvik333-hyprland-dotfiles/` | Terminal art, find-file, session restore, file explorer look. |
| snes19xx/surface-dots | `~/nix/repos/snes19xx-surface-dots/` | Widget structure/sizing, modern launcher, Rofi theme. |
| DankMaterialShell | `~/nix/repos/dankmaterialshell/` | QuickShell dock + display module. Check if clone succeeded — URL was discovered during clone session. |
| end-4/dots-hyprland | `~/nix/repos/end4-dots-hyprland/` | Hyprland 0.55 Lua patterns, animation curves, mouse binds, gestures. |
| Frost-Phoenix/nixos-config | `~/nix/repos/frost-phoenix-nixos-config/` | NixOS + Hyprland Home Manager glue. |
| LinuxBeginnings/Hyprland-Dots | `~/nix/repos/linuxbeginnings-hyprland-dots/` | ML4W-Glass-3d.css aurora gradient technique, laptop-glass Waybar. |
| newmanls/rofi-themes-collection | `~/nix/repos/newmanls-rofi-themes-collection/` | Rofi themes (launcher visual fallback only — click-away doesn't work in Rofi Wayland). |
| InioX/matugen | `~/nix/repos/iniox-matugen/` | Wallpaper palette generator. |
| InioX/matugen-themes | `~/nix/repos/iniox-matugen-themes/` | Matugen template collection. |
| abusoww/tuxmate | `~/nix/repos/abusoww-tuxmate/` | App installer UX reference. |
| Harshil-Anuwadia wintux GRUB | `~/nix/repos/harshil-wintux-grub-theme/` | Matrix dual-boot menu (DEFERRED). |
| Misterio77/nix-starter-configs | `~/nix/repos/misterio77-nix-starter-configs/` | Flake scaffolding template. |
| LGFae/awww | `~/nix/repos/lgfae-awww/` | Codeberg source. Wallpaper transition tool (maintained swww fork). |
| anufrievroman/waypaper | `~/nix/repos/anufrievroman-waypaper/` | Mouse wallpaper picker (superseded by skwd-wall decision). |
| elifouts | `~/nix/repos/elifouts-waybar/` | Waybar mechanics reference. Check if clone succeeded. |
| GlassesArch | `~/nix/repos/glassesarch/` | Waybar geometry reference. Check if clone succeeded. |
| Sharddots | `~/nix/repos/sharddots/` | Waybar blur params reference. Check if clone succeeded. |

## How to use this in your session

1. When a prompt says to read a repo, go to its local path above.
2. `ls` and `cat`/`view` files directly — they're regular files on disk.
3. For previews/screenshots: check for `previews/`, `screenshots/`, `assets/`, or image files in the repo root. View them with the `view` tool (it can display images).
4. For the agridyne build specifically: the real content is in `rice-contents/` — the repo root is just a zip + README.
5. If a repo in this list wasn't successfully cloned (empty dir or missing), note it in your output and fall back to web search for that specific repo only.
6. For repos/wikis/tools NOT in this list (e.g., Hyprlock source, t2linux wiki, tool documentation), web search is still the right approach.
