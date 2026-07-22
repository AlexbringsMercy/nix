CRASH ANALYSIS — the patched hyprbars was live during a Hyprland SIGSEGV. Determine whether the fault is the hover patch or the PM's deployment procedure, and adversarially re-audit the patch.

## Evidence (Hyprland crash report, `~/.cache/hyprland/hyprlandCrashReport1623.txt`)

- Signal 11 (SEGV).
- Plugins section lists **`hyprbars (Vaxry) 1.0` TWICE** — two instances were loaded simultaneously.
- Crash backtrace (top frames):
  - `#4 CConfigValue<long>::operator*() const`  (dereferencing a config int value)
  - `#5 CHyprBar::getPositioningInfo()`  in  `/nix/store/547zg2…-hyprbars-0.55.0/lib/libhyprbars.so`  ← the **UNPATCHED** plugin (the patched one is `5n10sci62…`)
  - `#6 CDecorationPositioner::getDataFor(...)`
  - `#7 CDecorationPositioner::onWindowUpdate(...)`
  - `#8 CWindow::updateWindowDecos()`
  - `#9 CWindowRuleApplicator::propertiesChanged(...)`
  - `#10 CRuleEngine::updateAllRules()`
- What the PM did (the trigger): the live compositor already had the unpatched `547zg2` loaded from the previous generation. The PM then ran, on the live session: `hyprctl plugin unload 547zg2`, `hyprctl plugin load <patched 5n10sci62>`, then `hyprctl reload` (which re-executes the config, including `hl.plugin.load(...)`). This left two hyprbars loaded.

## Tasks (analysis; no build/deploy/commit)

1. **Confirm or refute the double-load hypothesis.** Read `repos/hyprland-plugins/hyprbars/main.cpp` (`PLUGIN_INIT`, the `g_pGlobalState` singleton, `addConfigValueV2` registration) and `barDeco.cpp` `getPositioningInfo()`. Explain concretely how two simultaneously-loaded hyprbars instances (two `PLUGIN_INIT` runs, two registrations sharing/clobbering `g_pGlobalState` and the config-value pointers) would cause `getPositioningInfo()` to dereference a null `CConfigValue<long>` — i.e. the crash is a consequence of double-loading, not of the hover diff. Note `getPositioningInfo()` is not modified by the hover patch.

2. **Adversarially audit the hover patch for a latent crash on a CLEAN single load.** Re-read `modules/home/hyprland/patches/hyprbars-hover.patch` line by line and check: the `renderBarButtons` highlight (`configColor(HOVERCOLOR)`, the `m_iButtonHoverState & (1 << i)` read — is `m_iButtonHoverState` always valid/initialized at render time?); the `damageOnButtonHover` rewrite (the per-button bitfield loop, `assignedBoxGlobal()`, `cursorRelativeToBar()` — any null/invalid deref if called on every `onMouseMove` before the window is fully mapped/decorated?); the removal of `m_bButtonHovered` (grep the whole hyprbars tree to prove it is referenced nowhere else); and `onMouseMove` now calling `damageOnButtonHover()` unconditionally. Flag anything that could fault, with the exact line.

3. **Verdict + any hardening.** State clearly: is the hover patch sound on a clean single load, or does it need a fix? If a real bug exists, propose the minimal patch change (as an updated `hyprbars-hover.patch`) and re-verify `git apply --check` against v0.55.0 in `repos/hyprland-plugins`. Do NOT design the deployment procedure — that's the PM's job (a clean boot loads the plugin once). Focus purely on whether the patch is crash-safe.

Report your reasoning and verdict.
