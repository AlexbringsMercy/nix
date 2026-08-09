# Deep research: the REAL fix for tiled-drag grab-offset loss — proposal only

Read `/home/alex/nix/SESSION_PREAMBLE.md` FIRST and treat it as precedence for this
entire task. The operator has ruled: **a fix for this exists; it has not been found
yet.** Under the preamble, "I couldn't find it" is a report of YOUR coverage, never
evidence of nonexistence. A previous single-pass session concluded "the ecosystem
lives with it" from a four-config sample — that conclusion is VOID and you do not
inherit it. You are on maximum reasoning effort with subagent support: USE
SUBAGENTS, in parallel, one per lane below, and add lanes they surface.

## The proven problem (live evidence, complete — do not re-litigate)

Hyprland 0.55.4, native-Lua config, single eDP-1 2560x1600 @ 1.5. When MBIND_MOVE
picks up a TILED window (Super+drag or hyprbars titlebar drag), the compositor
places it centered under the cursor (`mouse - size/2`, DragController), discarding
the grab offset — the window visibly leaps, half off-screen for tall windows.
Floating windows drag perfectly. Animation off changes nothing (proven live).
Goal state: dragging a tiled window keeps the grab point under the cursor, like
every mainstream OS.

## Constraints on the deliverable

- PROPOSAL ONLY. No tracked-file edits, no commits, no live hyprctl/Hyprland
  commands on the operator's session. A nested/headless Hyprland instance you
  launch yourself for empirical verification IS allowed and encouraged.
- Solutions must be sourced: an upstream option/patch/PR, a community plugin, a
  distro-carried patch, or a config pattern proven in a real config — with the
  exact citation. Bespoke code is last resort and only if nothing sourced exists
  after exhaustive coverage (per preamble rule 2).

## Lanes (one subagent each, parallel; expand as leads appear)

1. **Upstream history & tracker.** git-blame DragController's centering line:
   when was it introduced, what did the code do BEFORE (did older Hyprland
   preserve grab offset? if so this is a regression and someone filed it). Sweep
   issues/PRs/discussions for: drag offset, movewindow jump, center under cursor,
   tiled drag float placement, grab point. Open PRs count as findings — a
   cherry-pickable PR is a sourced fix.
2. **Config-surface deep dive on 0.55.4 AND newer.** Beyond the option list:
   interactions (drag_threshold + follow_mouse + float rules), window rules that
   change pickup behavior (e.g. a rule floating a window on drag start via
   events), the `precise_mouse_move` semantics verified in source not by name.
   Also: what config surface do 0.56/0.57+ add here (bump-relevant)?
3. **Plugin surface.** Can a plugin hook the drag pickup path the way hyprbars
   hooks decoration? Enumerate the hookable functions in 0.55.4 headers around
   DragController/changeMouseBindMode. Search the plugin ecosystem (hyprland-
   plugins, hyprpm/hyprload registries, awesome-hyprland, GitHub topic search)
   for anything touching drag/move/grab behavior.
4. **Patch carriers.** nixpkgs overlays/issues, AUR hyprland-git patch sets,
   Fedora/copr, Gentoo — is anyone carrying a grab-offset patch downstream?
   t2linux/Apple-specific trees too.
5. **Symptom search from the user side.** The exact complaint in the wild:
   Reddit r/hyprland, GitHub discussions, forums — "window jumps when dragging",
   "drag teleports window", "movewindow centers". What do people who FIXED it
   (not coped with it) actually do? Follow every solution claim to its config.
6. **Empirical: the pre-float wrapper.** In a HEADLESS/nested Hyprland 0.55.4
   (WLR headless backend), empirically test whether a lua-function mouse-bind
   action can float-in-place (float + exact resize/move to current geometry)
   and then enter window.drag() with press/release semantics intact. This was
   left unverified statically — settle it with a running compositor, scripted
   input (wtype/ydotool or Hyprland's own dispatchers), and hyprctl of THAT
   nested instance only.

## Report (raw data)

Ranked viable fixes with: mechanism, exact source citation, effort class
(config / plugin / cherry-pick / carried patch), risk, and what live check the
gate needs. Per-lane subagent accounting per preamble rule 5: what was searched,
what was read, what was NOT covered. If a lane found nothing, its coverage list
is the deliverable — "nothing exists" claims without coverage are void.
