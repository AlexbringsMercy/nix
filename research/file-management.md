# File management: one settled position

## Operator decision override — current and authoritative

**Dolphin is decided. No further file-manager comparison is required.**

Alex clarified that the earlier “Thunar vs Nemo vs Nautilus” candidate boundary was introduced by a CLI agent in the research pipeline and was not an operator-approved constraint. The actual scope was simply to find the file manager that best suits the design intent. Dolphin is therefore the final selection; any conflicting pick later in this document is retained only as historical research.

Why Dolphin fits the actual scope:

- It is the file manager shown in the Agridyne explorer reference, so the strongest visual reference was already direct Dolphin evidence rather than an analogy.
- It supplies the most complete daily workflow here: tabs, split view, file-operation undo, batch rename, filtering/search, previews, Trash, mount/eject controls, a built-in terminal panel, configurable toolbars, and rich native service menus.
- Baloo is optional. Keep filesystem indexing disabled; Dolphin can be used without running a persistent indexer. Do not enable a Plasma session merely to support the file manager.
- The larger Qt/KDE Frameworks store closure is not equivalent to persistent CPU or memory usage. KIO workers and helpers should remain demand-driven.
- Agridyne and iNiR already provide the relevant Qt/Kvantum/KDE color-propagation patterns, so Dolphin is compatible with the universal wallpaper-adaptive theming requirement rather than outside it.

Current integration decision:

- **File manager:** Dolphin, associated with `inode/directory`.
- **Search:** Baloo disabled. Use Dolphin's on-demand filename/filter workflow; add a separate on-demand search tool only if execution testing reveals a real gap.
- **Thumbnails:** install the appropriate KIO thumbnail providers, including image/PDF and video thumbnailers, and limit remote preview work conservatively.
- **Trash and devices:** KIO Trash plus UDisks2/Solid device discovery. Use one headless `udiskie` instance for reliable hotplug automount in bare Hyprland; do not run a second automounter. Dolphin owns the visible mount/unmount/eject affordances.
- **Archives:** Ark is the archive opener. Its Dolphin service-menu integration supplies Extract Here/To and Compress/Create Archive; archive MIME families resolve to Ark for double-click browsing.
- **Theming:** drive Qt6/KF6, KDE color roles, icons, and Kvantum where applicable from the already-sourced fixed-dark/adaptive-accent token mapping. Preserve GTK3/GTK4 theming for non-Qt applications.
- **File picker:** prefer the KDE portal only for `org.freedesktop.impl.portal.FileChooser`, while XDPH remains first for Hyprland-specific interfaces and GTK remains fallback:

  ```ini
  [preferred]
  default=hyprland;gtk
  org.freedesktop.impl.portal.FileChooser=kde
  ```

  Chrome still supplies `current_folder`; verify KDE-picker dark theming, Recent Files, last-directory behavior, upload, Save As, modal parenting, and both drag paths at execution time.
- **File-manager right-click:** keep Dolphin's context menu native. Use Ark service menus and only packaged service-menu additions that solve a named need; do not reproduce it in QuickShell.
- **Desktop right-click:** retain the sourced iNiR QuickShell wallpaper-root pattern for New Terminal, Change Wallpaper, and Display Settings. It shares shell tokens and menu semantics with the rest of QuickShell, not the native Qt menu implementation.

Current requirement closure: §4.1 → Dolphin/Ark associations; §4.12 → KIO Trash plus UDisks2/Solid/one `udiskie`; §4.13 → native Dolphin menu plus adapted iNiR desktop menu; §4.17 → sourced Qt/KDE/Kvantum propagation while retaining GTK coverage; §6/A6 → Dolphin; B9 → KDE FileChooser portal per interface; B10 → Ark.

## Historical research record — superseded where it conflicts with the operator override

**Historical corrected decision (superseded):** use **Nautilus / GNOME Files without LocalSearch** as the only default file manager. The filesystem indexer is a separately enabled NixOS service, not an unavoidable Nautilus runtime service. Use `gvfs`, `udisks2`, and a single `udiskie` automounter in the bare Hyprland session; use Nautilus's built-in contextual archive actions plus File Roller for double-click archive browsing. Use `xdg-desktop-portal-gtk` specifically for `FileChooser` while leaving Hyprland-specific portal interfaces to `xdg-desktop-portal-hyprland`.

This closes **A6**, **B9**, and **B10** and maps directly to `MASTER_REQUIREMENTS.md` **§4.1** (directory/archive associations), **§4.12** (trash and removable media), **§4.13** (native file-manager menu plus desktop menu), **§4.17** (GTK theme propagation), and **§6 File manager**.

## File-manager comparison and pick (A6 / §6)

### Visual comparison first

I viewed dark-theme previews of all three candidates before ranking them, plus the two named explorer references.

- **Nautilus / GNOME Files is the visual winner.** The Saatvik333 Colloid preview (`repos/saatvik333-quick-shell/Assets/colloid.png`, with a closer view in `tweaks.png`) shows Files as a compact, coherent dark surface: restrained header bar, rounded controls, little visual clutter, and strong sidebar/content hierarchy. Current dark GNOME Files previews show the same basic structure. It is the closest stock application to “modern dark-glass-adjacent.” It is still a fixed dark material, not genuine wallpaper glass.
- **Themed Thunar is second visually.** The current Thunar 4.20 dark preview still exposes its conventional GTK3 file-manager skeleton. Caelestia’s complete `thunar.css` substantially improves that skeleton: a rounded 15 px content frame, separated sidebar, transparent view base, pill-like path buttons, animated tabs, softened status bar, and intentional hover/selected states. With the already-sourced 19 GTK3 named colors, it can match the shell rather than merely use a generic dark theme. It will look denser and slightly more traditional than Nautilus, but modern enough for the target.
- **Nemo is third visually.** The dark Nemo previews are clean and readable, with useful sidebar/device density, but the menu/toolbar/status-bar stack reads as the most traditional of the three. Generic GTK3 theming can recolor and round it, but the Caelestia work is specifically designed around Thunar’s widget tree and does more than the available Nemo theming.
- **The explorer references set a material target, not an application choice.** Agridyne’s viewed screenshots are Dolphin/KDE and mostly near-opaque dark surfaces; Saatvik333’s are GNOME Files with Colloid. Neither proves real content translucency. Do not promise compositor blur through a normal file-manager view: use dark near-black surfaces, rounded framing, low-contrast borders, and accent hover/selection to produce the adjacent look without sacrificing filename readability.

Visual-only order: **Nautilus > themed Thunar > Nemo**.

### Functional and daily-use comparison

| Criterion | Thunar | Nautilus | Nemo |
|---|---|---|---|
| Thumbnails | `tumbler` service with configurable thumbnail modes/size limits and plug-in thumbnailers | Native GNOME thumbnailing | Native thumbnailing through the GIO/GNOME stack |
| Trash | GVfs/GIO Trash; restore and empty-trash UI | GIO Trash with immediate Undo | GIO Trash with restore/empty actions |
| UDisks devices | GVfs/GIO exposes volumes; native `thunar-volman` handles insertion; sidebar has mount/unmount/eject affordances | GVfs/GIO exposes volumes and supplies mount/unmount/eject; use one `udiskie` process for hotplug automount in bare Hyprland | GVfs/GIO exposes devices; Cinnamon supplies the most integrated session behavior |
| Undo of file operations | Native Undo/Redo history for up to ten operations | Strong immediate undo and operation feedback | Native undo action and operation history |
| Tabs | Native tabs; can restore tabs on startup | Native tabs | Native tabs, plus split view |
| Bulk rename | Best of the three: dedicated multi-renamer with multiple renaming modes | Built-in template and find/replace batch rename | Delegates bulk rename to a configured external tool (normally Bulky in Mint) |
| In-manager search | Native recursive search from `Ctrl+F`; no indexer required | On-demand recursive filename search without LocalSearch; indexed metadata/content search only when the separate service is enabled | Native search; Tracker support is optional in current source |
| Archives | `thunar-archive-plugin` adds Create Archive / Extract Here / Extract To | Built-in compress/extract actions through `gnome-autoar`; File Roller can own archive MIME types for browsing | Commonly supplied through a separate extension |
| Device eject | Sidebar/context-menu mount, unmount, and eject; the side pane exposes an eject icon | Sidebar eject affordance | Sidebar/context-menu eject affordance |
| Cost on this MacBook | Smallest GUI runtime and dependency closure; search and thumbnailing are demand-driven | Larger GTK4/libadwaita/GNOME dependency closure than Thunar, but **no persistent crawler when LocalSearch is not enabled**; on-demand search costs CPU only while searching | Current source makes Tracker optional, but Nemo itself requires Cinnamon desktop libraries, XApp, and X11 support |

Thunar’s current documentation directly covers tabs, recursive search, trash, ten-operation undo/redo, bulk rename, thumbnails, and removable-device actions. `thunar-volman` is deliberately a Thunar helper rather than another general session daemon. See the official [file-manager window](https://docs.xfce.org/xfce/thunar/the-file-manager-window), [working with files](https://docs.xfce.org/xfce/thunar/working-with-files-and-folders), [preferences](https://docs.xfce.org/xfce/thunar/preferences), [bulk renamer](https://docs.xfce.org/xfce/thunar/bulk-renamer), and [removable media](https://docs.xfce.org/xfce/thunar/using-removable-media) documentation.

The earlier version of this report weighted Nautilus unfairly by treating its richest search configuration as if it were inseparable from the application. It is not. In current NixOS, `services.gnome.localsearch.enable` defaults to `false`; the old `services.gnome.tracker-miners.enable` option is renamed to it. Nautilus links the TinySPARQL client library, but that does not start a crawler. Without LocalSearch, Nautilus falls back to on-demand recursive filename search; it loses fast global metadata/content search, not ordinary in-manager file finding. The separate service boundary is visible in the current [NixOS LocalSearch module](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/desktops/gnome/localsearch.nix), while Nautilus's own [build definition](https://gitlab.gnome.org/GNOME/nautilus/-/blob/main/meson.build) lists the client library rather than the LocalSearch daemon. The [GNOME Files search documentation](https://help.gnome.org/users/gnome-help/stable/files-search.html.en) describes the user-facing filters; [LocalSearch](https://gnome.pages.gitlab.gnome.org/localsearch/) describes the optional persistent crawler/extractor architecture.

Nemo is feature-rich, and it does **not** force Tracker: the option is conditional in its current build. It still brings mandatory `cinnamon-desktop`, XApp, GTK3, and X11 dependencies, while its biggest unique daily feature here is split view, which §6 did not require. The official [Nemo repository](https://github.com/linuxmint/nemo), current [`meson.build`](https://github.com/linuxmint/nemo/blob/master/meson.build), and [`nemo-actions.h`](https://github.com/linuxmint/nemo/blob/master/src/nemo-actions.h) support that assessment.

### Final ranking

1. **Nautilus — selected, with LocalSearch disabled.** It is the clear visual winner, meets all named daily-use criteria, has built-in archive actions and adequate bulk rename, and does not impose a persistent indexer on NixOS. On-demand filename search is the correct resource trade here.
2. **Thunar.** Smallest and most configurable, with the best bulk renamer and most self-contained volume helper. It loses narrowly because its conventional GTK3 structure remains less aligned with the requested modern explorer look even after the strong Caelestia CSS adaptation.
3. **Nemo.** Capable and pleasant, but visually the most conventional here and burdened by Cinnamon-specific dependencies without a decisive benefit for this build.

**Plain trade-offs of the pick:** Nautilus has a larger GUI dependency closure than Thunar, its bulk renamer is less powerful, and it has no Nemo-style split pane. With LocalSearch omitted, search is slower and narrower than a fully indexed GNOME session. Bare Hyprland also needs one small automount helper. These are acceptable costs for the strongest visual fit and a coherent, complete daily file-management experience without persistent indexing.

### Selected Nautilus integration shape

- Packages/capabilities: Nautilus, `gvfs`, `udisks2`, `udiskie`, and File Roller. Do not enable the NixOS LocalSearch service or its older Tracker Miners alias.
- §4.1 association: make `inode/directory` resolve to `org.gnome.Nautilus.desktop`. Archive MIME types resolve to File Roller; contextual compress/extract remains built into Nautilus.
- Theme: Nautilus and current File Roller are GTK4/libadwaita, so feed them the four already-sourced libadwaita root variables and the GTK4 writer. Keep the broad GTK3 palette for the portal. Preserve the generated-file discipline, but do not copy iNiR’s disruptive `nautilus -q` restart.
- Preferences: enable local thumbnails and constrain remote preview/folder counting; retain the sidebar for Recent, Trash, network, and devices; use grid or list density matching the Colloid preview.
- Optional terminal action: if “Open in Terminal” is required inside Files, use the packaged Nautilus terminal extension rather than a custom script. Point it at the selected terminal.

### Removable media and Trash (§4.12)

Choose **one `udiskie` automounter** for the bare Hyprland session:

`UDisks2 system service → GVfs/GIO udisks2 volume monitor → udiskie hotplug policy → Nautilus sidebar mount/eject UI`

Nautilus uses the same GIO/GVfs UDisks2 volume model for devices, mounting, Trash, and eject, but a bare Hyprland session does not provide GNOME’s complete media-handling session. Run `udiskie` without its tray UI as the sole event-driven hotplug automounter; do not also start `thunar-volman` or another automounter. Keep automatic “open a new window on insertion” off initially. This small event listener is qualitatively different from a filesystem crawler: it reacts to UDisks events and does not walk the home directory. Trash remains GVfs/GIO Trash, including restore and empty-trash behavior; a removable filesystem’s ability to host its own trash still depends on that filesystem being writable and supported.

**Execution-time gate required by §4.12:** on the actual bare Hyprland session, insert a USB drive and verify one notification, one mounted volume, correct Nautilus sidebar appearance, writable file operations, move-to-trash versus permanent-delete behavior, safe unmount, and physical eject. Also verify behavior with no Nautilus window already open. Confirm that exactly one automounter owns hotplug behavior.

## Archive opener decision (B10 / §4.1)

**Pick: Nautilus built-in archive actions + File Roller as the archive opener.** The primary interaction remains contextual: Files supplies **Extract Here**, **Extract To…**, and **Compress…** through `gnome-autoar`. Double-clicking a `.zip` opens File Roller as a normal archive browser.

This avoids installing a Thunar-specific plug-in after selecting Nautilus. Nautilus already depends on `gnome-autoar` for contextual operations; File Roller supplies the explicit browser/editor fallback and follows the sourced GTK theme.

Configuration shape:

- Install File Roller; rely on Nautilus’s packaged `gnome-autoar` integration rather than adding custom extraction scripts.
- Associate `application/zip` and the supported tar/7z/RAR archive MIME families with File Roller’s desktop entry in the declarative `mimeApps` defaults. Do not associate by filename extension alone.
- Keep Nautilus’s built-in contextual archive actions. Do not add duplicate extension actions.
- Acceptance test: double-click ZIP opens File Roller; right-click ZIP exposes Extract Here/To; right-click selected ordinary files exposes Compress/Create Archive; encrypted ZIP prompts rather than failing silently; a deliberately malformed archive reports an error.

Why not Thunar Archive Plugin + Xarchiver: that pairing was coherent only with the old Thunar pick. It would be redundant and cross-manager baggage after selecting Nautilus.

## File-picker portal (B9 / §4.17)

### Backend ownership

`xdg-desktop-portal-hyprland` does **not** implement `FileChooser`; Hyprland’s own current documentation says to install the GTK backend alongside it. Portal selection is per interface, so the intended shape is:

```ini
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.FileChooser=gtk
```

In Nix terms, include both backends and generate the Hyprland portal preference above. XDPH remains first choice for the Hyprland-specific interfaces it implements (notably screen sharing and global shortcuts); GTK explicitly owns FileChooser and is fallback for interfaces XDPH lacks. This follows the official [Hyprland portal guidance](https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/) and the portal’s [per-interface configuration rules](https://flatpak.github.io/xdg-desktop-portal/docs/portals.conf.html).

### Theme, last directory, and Recents

- **Dark/themed:** current `xdg-desktop-portal-gtk` builds against GTK3 and constructs a `GtkFileChooserDialog`. It therefore consumes the sourced GTK3 settings and named-color CSS, not the four GTK4/libadwaita root variables. Generate `gtk-3.0/settings.ini` and `gtk-3.0/gtk.css` before the portal starts, set the dark preference in the same GTK writer, and give chooser rows/sidebar/selection/context menus the existing GTK3 colors. Do not add a one-off picker stylesheet.
- **Last directory:** the portal API has no “remember this forever” guarantee. It accepts a caller-supplied `current_folder`, and the GTK backend passes that to the chooser. Chromium stores the profile’s last selected directory and its Linux portal implementation sends an existing default path as `current_folder`; therefore Chrome is expected to remember it. This is partly application behavior, not a backend promise. See the portal [FileChooser API](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.FileChooser.html) and Chromium’s [Linux portal implementation](https://chromium.googlesource.com/chromium/src/+/refs/tags/132.0.6834.193/ui/shell_dialogs/select_file_dialog_linux_portal.cc#385).
- **Recents:** yes, when GTK recent files are enabled. The GTK backend explicitly adds each successful selected URI to the default `GtkRecentManager`, and GTK’s chooser exposes recent items. This is a shared per-user list, not an indexer. The GTK3 [RecentManager documentation](https://docs.gtk.org/gtk3/class.RecentManager.html) describes that store.
- **Preview:** the GTK portal adds a 128×128 preview widget for images it can decode. This is useful in Chrome upload flows and requires no separate file-manager thumbnail service.

### Execution-time acceptance test

The real acceptance test is **Chrome upload plus Save As**, not merely seeing both portal packages installed:

1. From a normal Chrome profile, upload one image: confirm the dark GTK chooser, correct parent/modal behavior, expected MIME filter, Recents, thumbnail preview, and that the next upload begins in the last selected directory.
2. Save a page/file: confirm the suggested filename, last directory, overwrite confirmation, and a usable Downloads path.
3. Repeat from any sandboxed browser packaging actually selected; portal document access differs from a host browser.
4. Drag a file **from Nautilus straight into a web page’s drop target**; this is the preferred no-dialog route and should use normal Wayland drag-and-drop. Separately try dragging onto the open GTK chooser. Do not promise that the latter will select/attach a file: it is chooser/widget behavior, not part of the portal contract. Record both results at execution time.

## Right-click everywhere (§4.13)

### File-manager context menu: native Nautilus

Keep this native, not QuickShell-drawn. Depending on target and location, Nautilus supplies Open/Open With, open in new tab/window, cut/copy/paste, rename or bulk rename, move to Trash/delete, star, properties, create folder, search, compress/extract, and device mount/unmount/eject. Add only the packaged terminal extension if that action is required. GTK4/libadwaita theming supplies the dark menu roles used by the rest of Files.

A QML component cannot sensibly be shared into a GTK application process. Share **visual tokens and action semantics**, not implementation: the QuickShell and GTK menus should use the same radius/color/spacing intent, while Nautilus remains accessible and native.

### Desktop wallpaper-root menu: sourced small adaptation

The “unsourced in all five repos” statement in the post-review addendum is now stale relative to the current local iNiR checkout. A community QuickShell implementation is present in:

- `repos/inir/modules/background/Background.qml`, desktop-menu integration around lines 1108–1144.
- `repos/inir/modules/common/widgets/ContextMenu.qml`, the reusable glass popup/menu component.

The pattern is exactly the required one: the per-screen background `PanelWindow` owns a right-button-only `MouseArea`; the click moves a 1×1 anchor item to pointer coordinates; the shared `ContextMenu` opens against that anchor; actions use existing detached-process or shell-global action services; the menu closes on activation/hover loss. It is below desktop widgets in z-order so widgets retain their input.

Adapt that component and reduce the model to the three required actions:

- **New Terminal** → existing safe application-execution helper launches the selected terminal, without interpolating a shell command.
- **Change Wallpaper** → call the already-planned wallpaper selector global action/IPC.
- **Display Settings** → call the already-planned independent QuickShell Display panel toggle, not a second monitor utility.

Minimal glue is one right-click `MouseArea`, one point anchor, one instance of the existing `ContextMenu`, and three action callbacks. Preserve per-screen ownership and popup edge adjustment so clicks near the right/bottom edges remain on-screen. No new menu framework and no desktop-icons/file-manager embedding are justified.

Taskbar and tray menus are intentionally not revisited here; their Caelestia/iNiR sources remain the settled answer.

## Requirement closure map

| Requirement/gap | Closure |
|---|---|
| §4.1 | `inode/directory` → Nautilus; archive MIME families → File Roller; contextual archive operations built into Nautilus |
| §4.12 | GVfs Trash; UDisks2 → GVfs/GIO → one `udiskie` automounter; USB/trash/eject execution test explicitly retained |
| §4.13 | Native themed Nautilus context menu plus adapted iNiR wallpaper-root QuickShell menu; existing task/tray work untouched |
| §4.17 | Nautilus and current File Roller consume the sourced GTK4/libadwaita work; the GTK portal consumes GTK3; chooser does not consume libadwaita root variables |
| §6 / A6 | Nautilus without LocalSearch is the sole selected manager; Thunar and Nemo are ranked alternatives, not parallel positions |
| B9 | GTK owns FileChooser per interface; Hyprland backend remains primary elsewhere; Chrome/DnD acceptance test retained |
| B10 | Nautilus built-in contextual archive actions + File Roller opener; double-click and contextual-action behavior specified |

## Bonus finds

- **Bonus:** NixOS makes the resource policy unusually clean: installing Nautilus does not mean enabling LocalSearch. The old Tracker Miners service option is renamed and remains opt-in.
- **Bonus:** current Thunar still has native recursive search and remains the strongest lightweight fallback; Catfish is unnecessary if the decision is ever revisited.
- **Bonus:** the GTK portal itself creates small image previews and records successful selections in GTK Recents. It does not require Nautilus’s thumbnailing path.
- **Bonus:** the newly present iNiR desktop-menu pattern removes the last unsourced part of §4.13. The work is now a narrow adaptation of a community implementation rather than a new component design.

## What I actually read/viewed vs what I didn't

### Read in full

- `SESSION_PREAMBLE.md`; `MASTER_REQUIREMENTS.md`; `research/GAP_REVIEW.md`; `research/SYNTHESIS.md`; `research/caelestia.md`; `research/iNiR.md`.
- The Caelestia Thunar template, GTK import file, `thunar-volman.xml`, `uca.xml`, and the relevant theme-application/manifest sections.
- iNiR’s full GTK theme writer and its GTK3/GTK4/settings templates.
- The complete official Thunar pages used above for the main window, working with files, preferences, removable media, bulk rename, `thunar-volman`, and the Archive Plugin.
- The XDG FileChooser interface and `portals.conf` documentation; current Hyprland XDPH page; current `xdg-desktop-portal-gtk` `filechooser.c` and build dependency declaration.
- Nemo’s README and current build definition; the complete action-definition header. I inspected relevant undo/menu source sections, but not every line of Nemo’s large menu implementation.
- GNOME Files help for browsing/tabs, search, delete/Trash, bulk rename, and archive operations, plus LocalSearch’s architecture documentation.
- iNiR’s complete reusable `ContextMenu.qml` and the desktop-menu integration slice of `Background.qml`. I did not read all 1,855 lines of the unrelated wallpaper/widget/effects implementation.

### Viewed

- Local Agridyne explorer/blur/panel previews and Saatvik333 Colloid Files/Tweaks previews at original resolution.
- Current dark Thunar 4.20, Nemo, and GNOME Files image-search previews. The Thunar image verifies the base application structure; Caelestia’s CSS was inspected to determine the target-specific transformation. The Nemo and Nautilus previews verify their dark layouts.
- Caelestia’s supplied shell screenshots to verify its palette, popup material, and rounding language. They do not show a full Thunar window.

### Not viewed or executed

- I did not render the three managers under the exact final generated palette on this MacBook. No available checked-in screenshot shows the final dark Caelestia Thunar CSS in this exact build, so the visual conclusion combines a current Thunar preview with the complete CSS rather than pretending such a screenshot exists.
- I did not launch a manager, mount media, open an archive, invoke a portal, test Chrome, test drag-and-drop, measure memory/CPU, or inspect live services. All USB, Trash-on-removable-media, Chrome upload/Save As, portal-parenting, and drag paths remain explicit execution-time tests.
- I did not read every line of Nautilus or Nemo application source; I used their complete user documentation and the specific current source/build files needed to verify dependencies and actions.

**Historical corrected pick (superseded by the operator decision above): Nautilus with LocalSearch disabled.** It delivered the best result inside the pipeline-imposed three-candidate comparison, but that candidate boundary was not authoritative.

**Current final pick: Dolphin.**
