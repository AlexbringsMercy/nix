# Superseded handoffs and plans — archived 2026-07-28

> **Archived documents are historical provenance, not active instructions.**
> They lose to `CURRENT_STATE_AUDIT.md`, the latest `EXECUTION_LOG.md` decisions,
> `GRAND_PLAN.md`, and `MASTER_REQUIREMENTS.md`.
>
> Do not resume from anything in this directory. Do not treat any "instructions
> for the next session," "first actions," or "current state" section in these
> files as live. Several of them state generation numbers, running architectures,
> and stage verdicts that were true when written and are false now.

Archived by the 2026-07-28 documentation and housekeeping pass, under operator
decision 18 (`EXECUTION_LOG.md` → *OPERATOR DECISIONS — 2026-07-28 — ACTIVE
GENERATION 26*). Moved with `git mv`; nothing was deleted, and full history
remains in Git.

**Active PM entry set after this archive:** `CURRENT_STATE_AUDIT.md` ·
`GRAND_PLAN.md` · `MASTER_REQUIREMENTS.md` · `SESSION_PREAMBLE.md` ·
`EXECUTION_LOG.md` · `PM_OPERATING_RULES.md` · `STAGE2_CLOSEOUT_WORK_ORDER.md` ·
`SOURCES.md`.

---

## Manifest

| Original path | Archived path | Superseded by | Why archived | May still be consulted for |
|---|---|---|---|---|
| `PM_HANDOFF.md` | `archive/superseded-handoffs/2026-07-28/PM_HANDOFF.md` | `CURRENT_STATE_AUDIT.md` + `PM_OPERATING_RULES.md` + `STAGE2_CLOSEOUT_WORK_ORDER.md` | Obsolete PM handoff. Its central operational claim — "gen 25 booted, gen 26 staged boot-only and NEVER TESTED" — is stale: the machine has since booted into generation 26. It also carries the "drag patch (built)" error inherited from the log. A PM reading it as current would mis-state the running system and skip a required build. | **Machinery only**, which remains accurate and is not duplicated elsewhere: the Codex `systemd-run` pipeline and resume flag order, the exact deploy command sequence, the armed-resume loop, the both-paths verification rule, the PM artifact directory rule, and the "lessons already paid for" list. |
| `PM_KICKOFF_PROMPT.md` | `archive/superseded-handoffs/2026-07-28/PM_KICKOFF_PROMPT.md` | `PM_OPERATING_RULES.md` §5 (first actions) | Obsolete kickoff prompt. It instructs the incoming PM to read `PM_HANDOFF.md` and do what it says, and to verify that the running system is generation 25 — a check that now fails correctly and would stop a valid session. | The shape of a PM kickoff message, if a new one is ever drafted. |
| `BUILD_PLAN.md` | `archive/superseded-handoffs/2026-07-28/BUILD_PLAN.md` | `GRAND_PLAN.md` (its l.4 names this file as superseded) | Waybar-era build plan that still claims current authority: "Document status: implementation deployed; Generation 10 default", followed by "Instructions for future Codex sessions — read this document completely before modifying the machine." The architecture it describes (Waybar, Rofi, matugen/awww/Waypaper, two workspaces) is retired. It also records the now-overridden rejection of `hyprbars`. | Original design intent and invariants from the 2026-07-15/16 migration; the reasoning behind early component rejections, when tracing why a later decision reversed one. |
| `MACBOOK_NIXOS_HYPRLAND_BUILD_PLAN.md` | `archive/superseded-handoffs/2026-07-28/MACBOOK_NIXOS_HYPRLAND_BUILD_PLAN.md` | — (symlink) | Relative symlink to `BUILD_PLAN.md`; moved with its target so it keeps resolving inside the archive rather than dangling in the repository root. | Nothing independently — it is an alias. |
| `OVERHAUL_PLAN.md` | `archive/superseded-handoffs/2026-07-28/OVERHAUL_PLAN.md` | `GRAND_PLAN.md` (component proposals) · `VISUAL_RESEARCH.md` (visual corrections) · `MASTER_REQUIREMENTS.md` §9 (accepted diagnostic findings) | Superseded plan. Its component proposals were overtaken by the research corpus and then by the Grand Plan; `VISUAL_RESEARCH.md` corrects a dozen of its specific claims by section number. Keeping it in the root put a second document titled "plan" beside the authoritative one. | Its **diagnostic findings**, which were accepted as inputs into `MASTER_REQUIREMENTS.md` §9 (template-alpha glass root cause, tone-80 mauve mechanism, VA-API absence, `vibrancy_darkness` inversion), and the section numbers that `VISUAL_RESEARCH.md` cites when correcting it. |
| `FABLE_PLAN_PROMPT.md` | `archive/superseded-handoffs/2026-07-28/FABLE_PLAN_PROMPT.md` | `GRAND_PLAN.md` — the document this prompt produced | The creative brief that commissioned the Grand Plan. Its purpose was discharged the moment the plan was written; it is a prompt, not a plan, and its presence in the root invited it to be read as design authority. | The provenance of the Grand Plan — what was locked, what was left to the designer's authority, and which prior documents were declared context rather than blueprint. |
| `macbook-setup-handoff.md` | `archive/superseded-handoffs/2026-07-28/macbook-setup-handoff.md` | `macbook-build-spec.md` (kept in root) + Stage 0 of `EXECUTION_LOG.md` | Obsolete handoff brief from the original NixOS installation chat, written to carry context across a chat boundary before the flake existed. Its "pick up where we left off" framing is a stale start-here guide. | The installation history — T2 firmware extraction, dual-boot partitioning, and the early hardware debugging that predates the repository. |
| `AURORA_OPERATOR_GUIDE.md` | `archive/superseded-handoffs/2026-07-28/AURORA_OPERATOR_GUIDE.md` | `docs/controls.md` (pointer paths) · `GRAND_PLAN.md` §6 (the intended interaction model) | Stale operator/acceptance guide tied to the retired architecture. It documents "the desktop installed as NixOS Generation 9", pins an expected `/nix/store` system path that is 17 generations out of date, and describes Waybar groups, Rofi, Waypaper and the old QuickShell panels throughout (22 Waybar references). Its "first-reboot acceptance checklist" would be read as a live gate. Nothing in the flake or any desktop entry references it. | The *style* of a day-to-day operator handbook and acceptance checklist — worth revisiting when the real one is written for the finished build (Stage 10). |

---

## What was deliberately **not** archived, and why

| File | Kept because |
|---|---|
| `nixos-hyprland-build-spec.md` | It is the build spec for the **Alienware 14**, not a superseded MacBook plan. `MASTER_REQUIREMENTS.md` §14 lists the Alienware port as explicitly deferred, not cancelled — this is forward-looking material for a different machine, and it claims no authority over the current build. |
| `ISSUE_LOG.md` | Active evidence. `CURRENT_STATE_AUDIT.md` cites its §20 (palette completeness) and §28 (T2 RTC skew) as live inputs, and `PM_OPERATING_RULES.md` lists it in the incoming PM's read set. |
| `VISUAL_RESEARCH.md`, `RESEARCH_GUIDE.md`, `visual-design-reference.md` | Research corpus and design reference. They are the sourced input Stage 4 will work from; `visual-design-reference.md` is on the explicit do-not-move list. |
| `README.md` | The repository's front door rather than a PM instruction document. Its stale Waybar-era architecture description and its pointer to the archived `BUILD_PLAN.md` were corrected in place instead, with a status note directing readers to the current authority set. |
