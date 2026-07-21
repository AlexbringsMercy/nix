# The Grand Plan — Creative Brief for Fable

This is the linchpin of a weeks-long design project. Months of conversation, five deep-read research sessions, ten scoped session outputs, and a hard-won map of what's real all converge here — into one document you author. When it's done, everything before it collapses into it, and execution begins. Take the authority that implies.

## Who you are

You are the head designer of a complete operating system experience. Not an assembler of components from a research spreadsheet — a designer who understands how a person lives with their computer every day, and who builds something they'd be proud to use and show off.

You have full creative authority. Nothing is locked except what's explicitly marked below. Everything else — every component choice, every architectural decision, every visual treatment, every interaction pattern — is yours to propose, combine, rethink, or challenge with reasoning. Prior sessions made recommendations; you are not bound by them. Prior plans exist; they are context, not blueprints. If you see a better path than what's been proposed, take it and explain why.

**Who reads what you write.** Your output is `~/nix/GRAND_PLAN.md` — the complete, authoritative build plan for this operating system. When it's done, execution sessions work from it and only it. Those sessions are competent but literal, and this project has been burned repeatedly by agents who, handed a vague instruction, quietly built their own version of a component from scratch instead of adapting the real one. Your plan is what prevents that. Every component you specify must be traceable to a real source (repo + path) and concrete enough that a builder can't wander off and invent. Precision of attribution is not bookkeeping — it's the thing that makes your design executable.

## What you're designing

A daily-driver NixOS + Hyprland desktop on a 2020 MacBook Air (T2, Intel i3 dual-core, Iris Plus, 8GB RAM, single 13" Retina display at 1.5x scale, 121GB partition). The user (Alex) previously ran Windows for 20 years and macOS at work. This OS needs to be at least as easy as both and more beautiful than either.

The current state: NixOS is installed and boots. Hyprland runs. The infrastructure (flake, T2 integration, QuickShell skeleton, PipeWire) is mostly solid. Everything user-facing is janky or broken — the visual layer was built from scratch by agents who couldn't read the repos they claimed to be adapting. It all needs to be replaced with real community-sourced components, properly adapted.

**Design for this exact machine.** It's a modest dual-core / 8GB / integrated-GPU laptop. That is not a reason to strip beauty — it's the constraint that makes the beauty impressive. Smoothness *on this hardware* is part of the governing test: a gorgeous effect that stutters on this machine fails it. This is about how treatments are implemented (cheap GPU-accelerated blur over CPU-melting compositing, sane widget wake cycles), not about narrowing what the OS offers — generous inclusion still holds. It also connects to how agent and build workloads are contained (open question #4).

## The soul of the build

Alex's design philosophy in his own words, distilled from months of conversation:

**"Is this streamlined enough that ANYONE could use it?"** — the governing test for every decision. Compare to perfect Linux builds, to Windows, to macOS. If something requires memorizing a hotkey, if it's hidden, if it's ugly, if it's tucked away — it fails.

**Everything clickable, hotkeys optional.** Buttons and visual controls for all common actions. Hotkeys exist for power users, never as the only path. Redundancy between button and hotkey is a feature. "It's the user's choice whether they want to use a button or remember a hotkey."

**Dark glass with aurora light.** Deep near-black blues, black, purple, teal/seafoam, deep dark green in smooth gradient blobs. NOT navy (the word reliably produces flat corporate assets). Real glass — wallpaper visible through panels. Smooth animations on everything. Raycast-level UI refinement. The vibe: dark clean modern glass with aurora light bleeding through.

**No throwaway bridges.** Nothing gets built that's planned to be replaced later. Everything builds toward the end state from the start.

**Adapt, never build from scratch.** Every visual component comes from an existing community implementation. "Adapt" means compatibility conversion — minimal changes for function and polish. Not "look at the code once then write your own version."

**Grab everything, cut later.** Alex prefers generous inclusion of features and bonus finds. He cuts what he doesn't want at review time — agents don't preemptively omit.

**He doesn't use Alt+Tab much** (ADHD — full window switching is disorienting). He prefers clicking taskbar buttons to cycle through windows. The bar and workspace buttons are his primary navigation, not keyboard switchers.

---

## How to read your inputs

You're about to read 15+ files totaling thousands of lines, written at different times, that openly disagree with each other. Two things will keep you out of trouble:

**Read like the failures didn't.** SESSION_PREAMBLE.md tells the story of a claim that five consecutive sessions got wrong by grepping for a filename instead of reading the repo. When a load-bearing claim smells off, or a component is central to your design, open the repo on disk and look — the code and previews outrank any write-up about them. **If you delegate any reading or verification to sub-agents, every one of them must read `SESSION_PREAMBLE.md` first.** That failure *was* sub-agents grepping instead of reading; don't re-run it.

**When sources conflict, this is the order of authority:**

1. **Locked decisions** (below) — fixed, not yours to relitigate.
2. **Your own reasoned creative judgment** — can override any recommendation in any file, *including* MASTER_REQUIREMENTS, when you can say why it's better. This is what "full creative authority" means; use it, and show the reasoning.
3. **`MASTER_REQUIREMENTS.md`** — the reconciled mechanical/requirements backbone. On facts, requirements, and prior decisions, it wins over the other documents.
4. **Recency among research** — the ten session outputs and `caelestia-full-inventory.md` supersede `SYNTHESIS.md` where they conflict (Synthesis predates the repos being on disk); the research as a whole supersedes `OVERHAUL_PLAN.md`'s component proposals.
5. **Ground truth for any component's actual behavior** — the repo on disk. A verified read of source and previews beats every second-hand claim.

Read roughly in the order below; you may parallelize, but apply full-read discipline to anything you rely on.

## Files to read

### Tier 1 — Read fully, these are your foundation

**`~/nix/MASTER_REQUIREMENTS.md`**
The consolidated requirements backbone. Design philosophy (§0/§2/§3), interaction model, visual direction, all user references with corrected annotations, the complete bug log (§5), component requirements (§6), dev workspace spec (§7), agent rules (§1), hardware invariants (§10), and the §15 decisions log. Most current mechanical authority — see the authority ladder above for how it and your judgment interact.

**`~/nix/macbook-build-spec.md`**
The original granular design intent for *this* machine. This is where Alex's actual vision lives — the ilyamiro video analysis with specific animation highlights, the dashboard-architecture (independent widgets) vs hub-architecture (single morphing panel) decision, the morphing transition mechanics, specific visual references, and the interaction philosophy with concrete examples. Richer creative context than the master requirements captures.

**`~/nix/SESSION_PREAMBLE.md`**
The caelestia failure case study (mandatory — it explains why five sessions were wrong about caelestia's sidebar), the repo access map (every reference repo is cloned under `~/nix/repos/`), and the hardened research rules. You have filesystem access to every repo if you need to verify a claim or investigate a component directly.

### Tier 2 — Read fully, these are your research inputs

**`~/nix/research/SYNTHESIS.md`**
Cross-repo findings from the first five deep-read sessions. Organized by requirement with candidate comparisons, adaptation deltas, and architecture sections (palette, motion, glass). **Caveat:** produced before the repos were cloned to disk; some findings (especially agridyne and caelestia) were based on incomplete reads. The ten session files and `caelestia-full-inventory.md` supersede it where they conflict.

**`~/nix/research/GAP_REVIEW.md`**
Fable's own gap review — the 40+ missing items, bonus proposals, unresolved comparisons, and the "combine recommendations that are secretly from-scratch" warnings. Your earlier work. The addendum section has post-review decisions and clarifications.

**`~/nix/research/caelestia-full-inventory.md`**
The definitive, code-traced read of the entire caelestia stack (shell: 57,875 lines / 449 files, plus the C++ plugin and the CLI), mapping each screenshot Alex sent to the exact code that renders it. **This is the authoritative caelestia source — it supersedes every prior caelestia claim, including the older `caelestia.md` deep read and Synthesis's caelestia sections.** It closes the five-session "sidebar = notification drawer" error for good: the rich left surface is `modules/bar/` + `modules/windowinfo/` + `modules/dashboard/` + tray, while `modules/sidebar/` is a separate 42-line notification drawer. Read this before you resolve open question #2 (how much of caelestia's shell to carry). `shell-surfaces.md` references it.

**`~/nix/visual-design-reference.md`**
Concrete visual specs and annotated screenshot analysis from direct conversation with Alex — the creative grounding document that turns abstract design intent into actual property values and "this not that" comparisons. When you need the visual story to be concrete rather than adjectival, this is where the specifics live.

**The ten research session outputs (read all):**
- `~/nix/research/shell-surfaces.md` — Dock ranking (DMS > iNiR > ekremx25), launcher slice analysis, display panel. **Caveat:** this session initially repeated the caelestia sidebar error but was corrected mid-session after being forced to read caelestia's shell in full; it now credits the left surface as `modules/bar/` + `modules/windowinfo/` + `modules/dashboard/` + tray — a full interactive vertical taskbar with live window previews, tray menus, tabbed dashboard, and drill-in submenus. Factor the corrected understanding in (and see `caelestia-full-inventory.md`, which it cites).
- `~/nix/research/lock-screen.md` — Open comparison. **Decision reached with Alex:** ilyamiro appearance + Vast cinematic depth/unlock engine + DMS safety lifecycle + iNiR/DMS status pills. A strong recommendation, not gospel — if you see a problem or a better composition, say so.
- `~/nix/research/window-input.md` — Per-window controls (hyprbars viable on the pinned NixOS flake), focus policy (click-to-focus), minimize via hidden workspace, drag-to-workspace from DMS, gestures, input bug fixes. Solid.
- `~/nix/research/hardware-drivers.md` — Webcam (unconfirmed, needs live test), gpu-screen-recorder, gaming latency (2.4GHz WiFi interference), T2 speaker profile, t2fanrd, boot-default fix, keyboard backlight. Hardware-grounded.
- `~/nix/research/dev-experience.md` — Alt+Tab (snappy-switcher now, QuickShell live-thumbnail later), dev workspace composition from caelestia's toggle.py, agent hooks, zellij for persistence, fzf find-file, Starship, LazyVim leans for Neovim. Solid.
- `~/nix/research/daily-guardrails.md` — Battery lifecycle (UPower + PPD), night light (hyprsunset), audio auto-switch (WirePlumber), device-specific EQ (EasyEffects + AutoEq), disk GC policy, captive portals, lid-close suspend (systemd-logind), agent lag management (systemd slice). Comprehensive.
- `~/nix/research/app-lifecycle.md` — Tuxmate is NixOS-compatible but just a snippet generator; nix-software-center as GUI store; two-lane install (declarative default + imperative "click to install"); nh for update-diff; nvd for generation comparison. Clean.
- `~/nix/research/settings-dialogs.md` — Caelestia Nexus isn't cleanly extractable but comes nearly free if carrying the caelestia shell; polkit baked into QuickShell; regreet as greeter; restic for backup; iNiR emoji picker. The Nexus cost chains to the caelestia-shell-scope question (#2).
- `~/nix/research/file-management.md` — **OVERRIDDEN: Dolphin is the file manager.** Qt-based (same toolkit as QuickShell), modern UI, split panes, built-in terminal panel. Thunar/Nautilus/Nemo rejected. The session's Thunar recommendation is superseded.
- `~/nix/research/wallpaper-pipeline.md` — skwd-wall does handle transitions via its Rust daemon. The daemon-free SliceDelegate approach loses transitions. **Open question for you (#1):** keep the daemon (making awww redundant) or go daemon-free + awww? Reason it through.

### Tier 3 — Reference as needed

**`~/nix/OVERHAUL_PLAN.md`** — The plan created before the research sessions. Diagnostic findings are accepted inputs (§9 of master requirements); component proposals are superseded by the research.

**`~/nix/EXECUTION_LOG.md`** — What physically exists on the machine now. Infrastructure mostly solid; visual layer is junk.

**`~/nix/research/RESEARCH_SESSIONS.md`** — The session architect's scoping. The **no-session list** at the bottom is important — it catalogs everything that's config-work, already-resolved, or plan-time composition. These items need to appear in YOUR plan, not silently vanish.

**`~/nix/VISUAL_RESEARCH.md`** — Pre-repo-clone visual research: genuine finds (especially the iNiR discovery and the palette/motion/glass architecture sections) but some claims based on partial reads. Synthesis absorbed most of it — reference it when Synthesis is thin on a visual specific.

**Earlier research files** (`~/nix/research/ilyamiro.md`, `agridyne.md`, `caelestia.md`, `iNiR.md`, `cxOrz.md`) — Deep repo reads from the first pass. Reference when the synthesis or session outputs are thin on a specific component. (For caelestia, `caelestia-full-inventory.md` supersedes `caelestia.md`.)

**Repos on disk** (`~/nix/repos/`) — Every reference repo is cloned locally; you have full filesystem access. If you need to verify a claim, check a file, or investigate a component, go look. Especially: `~/nix/repos/agridyne-dotfiles-dt/rice-contents/` (was zipped, never properly read until session 1's correction) and `~/nix/repos/caelestia/shell-main/shell-main/` (the 57k-line shell).

---

## Decisions that are actually locked

These are the ONLY hard constraints. Everything else is your creative call with reasoning.

- **skwd-wall** is the wallpaper picker. Non-negotiable — it's the best Alex has seen.
- **Dolphin** is the file manager. Qt-based, aligns with QuickShell, user's preference.
- **QuickShell bar**, not Waybar. Waybar is retired.
- **NixOS with flakes + Home Manager.** The OS and config-management approach.
- **Hyprland 0.55** with native Lua config. The compositor.
- **QuickShell** as the primary widget/panel framework.
- **Fish** (interactive) / **Bash** (scripts). **Kitty** terminal.
- **T2 hardware constraints** are immutable (§10 of master requirements).

## Open questions for your judgment

These came up in discussion but never made it into any file. Factor them into your design and resolve each one explicitly:

1. **skwd-wall daemon vs awww.** The wallpaper picker's Rust daemon handles transitions natively. If we keep the daemon, awww is potentially redundant. If the daemon also supports scripted/timed changes (for auto-cycling), awww is fully redundant. If not, awww stays for auto-cycling only. What's the right call?

2. **How much of caelestia's shell to carry.** The launcher, Nexus settings center, notification model, and window previews all come from caelestia. Carrying more of the shell means more comes "nearly free." Carrying less means more independent adaptation. This is the single most consequential architectural question — reason through it (with `caelestia-full-inventory.md` in hand).

3. **Lid close behavior.** systemd-logind owns suspend; hypridle locks before sleep. T2 suspend needs live testing. How should this be structured in the plan?

4. **Agent workload management.** Claude Code and Codex can pin both cores for minutes. A systemd `agent.slice` with deprioritized CPU/IO/memory keeps the desktop responsive; Nix builds need separate containment. How does this integrate (and how does it square with "smooth on this machine")?

5. **Recent config changes to preserve.** Moonfin server, TV connection (firewall ports), Xbox controller Bluetooth — set up outside this project; do not clobber them.

6. **Current broken things.** Screenshot keybind dead, brightness keys broken, start-hyprland warning on reboot. Symptoms of config drift — the plan should produce a clean state that resolves them.

## What the plan should be

Not a rigid format — structure it however makes the most cohesive argument. It is a design with a point of view, not a form to fill in. But a builder reading it must be able to answer:

**The architecture.** How do all the pieces fit together? What's the QuickShell shell composition — what components, from what sources, how do they interact? What's the palette/theming system? The animation vocabulary? How do the bar, panels, sidebar/dock work? How does everything recolor together when the wallpaper changes?

**The visual story.** What does this OS look and feel like, from boot to lock screen to daily use? Not abstract ("glassmorphism") — concrete enough that someone building it knows what to produce.

**Every component.** Where it comes from (source attribution: repo + path), what adaptation is needed, where it lives in the shell, how the user interacts with it, what triggers it. Nothing unattributed, nothing from scratch.

**The interaction model.** How does the user do everything they need to do? Boot → login → open an app → manage windows → adjust volume → check WiFi → install an app → take a screenshot → lock the screen → close the lid → open it tomorrow. Walk the full daily experience.

**The dev workspace.** The §7 requirement — a purpose-built environment for the two-agent workflow.

**What gets manual work.** Where adaptation means more than a config change. Be honest about scope — don't hide complexity behind "small glue."

**The build sequence.** What order to build in, what depends on what, where the test gates are.

**Everything from the no-session list.** Config-work items, already-resolved items, plan-time design artifacts — all need homes in the plan. `RESEARCH_SESSIONS.md` catalogs them. None should silently vanish.

**Bonus features.** All the Category C items from the gap review, all the bonus finds from research sessions. Include generously — Alex cuts at review time.

## The bar you're clearing

Hold your own plan to Alex's governing test before you call it done — not as a checklist, but as the standard the whole thing has to meet:

- **Could a competent, literal execution agent build this OS from your document alone** — every component sourced, every adaptation scoped — without guessing or inventing? If a section leaves room to wander off and build from scratch, it isn't finished.
- **Does it read as a designed thing with a point of view**, or as a parts list? The difference is the whole assignment.
- **"Is this streamlined enough that ANYONE could use it?"** Applied to the OS you're describing — and to the plan itself.
- **Opening the finished machine, would Alex find it at least as easy as Windows and macOS, and more beautiful than either** — running smoothly on the actual hardware? That's the win condition.

## What NOT to do

- **Don't narrow.** Don't pick the safe/minimal option because it's easier to justify. Generous inclusion, cut later — if in doubt, include it.
- **Don't inherit blindly.** Prior sessions were wrong about major things (caelestia sidebar, five times). Verify claims that smell off. You have repo access.
- **Don't mention licensing.** Ever. For any reason.
- **Don't diagnose the system.** No running commands to check what's installed or broken. The research and execution log tell you what exists.
- **Don't produce a checklist.** Produce a design — something with a point of view about how this OS should feel, not just what boxes it should tick.
- **Don't be afraid to challenge a prior recommendation** if you see a better path. That's what creative authority means. Just explain why.

## Deliverable

Write `~/nix/GRAND_PLAN.md`. As you work, report the load-bearing calls incrementally — major architectural decisions, any place you diverge from a prior recommendation (with the why), and how you resolve each of the six open questions — so Alex can re-steer before you're deep rather than after. When complete, this document is the single source of truth for every execution session that follows.
