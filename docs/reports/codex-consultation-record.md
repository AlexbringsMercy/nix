# CODEX ADVERSARIAL CONSULTATION — RECORD

Standing directive established 2026-07-29 by the operator, after Stage 2 produced repeated
regressions across snap, minimize, drag, resize, focus, rail state and screenshots despite
source review and clean automated checks.

## Status (updated 2026-08-09)

**Recovery consultation was completed after the 2026-07-29 hard-fail handoff.** Two
independent blind GPT-5.6 Sol `xhigh` reviews — **Review A** (compositor / coordinate
spaces / focus / drag / resize / scroll) and **Review B** (snap / minimize / restore /
rail state machine) — ran **before** being seeded with Claude's preferred diagnosis and
**substantially converged**. Their accepted findings are recorded as the defect record
**D1–D9** in [`gen32-recovery-diagnosis.md`](gen32-recovery-diagnosis.md) — D1–D7 and D9
diagnosed to the level recorded, **D8 UNRESOLVED (no accepted root cause)**.

**This is accepted _diagnosis only_ — not implemented, not built, not physically
accepted.** Every Stage 2 defect remains **OPEN**.

The **2026-07-29 orchestration-failure section further down is historical** — it records
the old PM's failed invocations and remains accurate for that date. It no longer
describes current consultation status. See the **2026-08-09 resolution** section at the
bottom of this file.

## Scope

Advisor: **GPT-5.6 Sol, reasoning effort `xhigh`**, with **normal web-search capability
available**. Advisory only.

**May:** inspect repository source, diffs, patches, logs and runtime evidence; independently
diagnose; challenge hypotheses; identify conflicts and regression risks; propose exact source
changes, pseudocode or patch diffs; design static/unit/runtime tests.

**May not:** edit the working tree; run builds; stage or activate generations; commit or push;
execute implementation autonomously; expand scope beyond the assigned defect cluster.

Claude remains responsible for evidence gathering, implementation, builds, commits and
deployment. Codex exists specifically to challenge Claude before those actions occur.

## When consultation is mandatory

Before implementation for any change involving: Hyprland or plugin source patches · snap,
tiling, minimize, restore or snap/reservation bookkeeping · titlebar drag, resize or coordinate conversion ·
keyboard/Wayland focus · synchronous IPC or subprocesses inside compositor callbacks · rail
toplevel identity/grouping/restoration · screenshot lifecycle or focus restoration · any
correction touching code that previously regressed · any proposed fix whose failure could freeze
input, corrupt window state, crash the shell/compositor or require another reboot.

Routine documentation, an obvious typo, or a proven isolated declarative value does not require
this process.

## Required workflow

**Pass 1 — blind independent diagnosis.** Before revealing Claude's preferred root cause or
implementation, give Codex: the operator's exact physical observations; gen 31 versus gen 32
behaviour; relevant logs and timestamps; the exact source/diff between the generations; the
currently loaded compositor/plugin identities; and the architectural requirements and acceptance
behaviour. Ask it to diagnose independently, without inheriting the PM's diagnosis, and to state
what is proven, what is only likely, what further evidence is needed, and the safest minimal
correction architecture — looking specifically for blocking calls, coordinate-space errors,
state-machine ordering, partial transactions, stale bookkeeping and interactions between patches.

Required Pass 1 output: Observed failure · Proven facts · Most likely root cause · Competing
explanations · Source locations involved · Evidence that would distinguish them · Recommended
correction architecture · Regression risks · Static/unit tests · Physical runtime tests ·
Confidence.

**Claude then forms its own diagnosis and proposed correction.**

**Pass 2 — adversarial review** (also `xhigh`) evaluates whether the proposal explains the entire
trace; whether it risks destroying pairings; whether it can regress Xbox reconnect latency or
other Bluetooth devices; whether a service restart, live test, rebuild or reboot is actually
necessary; and the exact acceptance tests.

**Any material Claude/Codex disagreement is surfaced to Alex before implementation. It may not be
silently resolved by PM preference.**

**No implementation before both independent reviews and the adversarial review are complete.**

## Invocation requirement

Use a **bounded invocation method that captures the real child process and its completion state.**
The 2026-07-29 session repeatedly mistook a `nohup`/wrapper exit for the child's completion and
read partial output as failure. Wait on the actual `codex` process, not a wrapper.

## Attempt log — 2026-07-29 (all failed; none accepted)

| # | Configuration | Outcome / cause |
|---|---|---|
| 1 | `xhigh`, prompt via stdin `-` | No response body. Later found **still running**; the wrapper had exited while the child continued. PM misread partial output as a silent failure. |
| 2 | `xhigh`, prompt as argument | **Endless web-search loop** — 30+ searches against BlueZ, Quickshell and kernel sources; never produced an answer. |
| 3 | `-c tools.web_search=false` | **Wrong config key (PM error).** Search remained enabled; looped again. |
| 4 | `--disable web_search` | **Deprecated flag (PM error).** Tool advised the correct form is top-level `web_search`. |
| 5 | `-c web_search="disabled"` | Emitted only its commentary phase, then no final message. |
| 6 | `high` effort, `web_search="disabled"` | Same — commentary only. Confirms reasoning effort was not the variable. |
| 7 | Clean re-run from a script file, `xhigh`, `web_search="disabled"` | **Terminated by operator directive before completion. Explicitly NOT accepted** — it was launched with web search disabled, contrary to the intended advisor configuration. |

A trivial control prompt returned correctly, so the CLI and the model function.
**The tool must not be characterised as incapable on the basis of these invocation failures.**

## Artefact locations — INCOMPLETE, NON-AUTHORITATIVE

`~/.local/state/aurora-build/xbox-known-good/codex-attempts-INCOMPLETE/`

- Prompts: `codex-bt-pass1.md`, `codex-bt-pass1b.md`, `codex-bt-pass2.md`
- Partial outputs: `codex-bt-pass1-out.txt`, `codex-bt-1b-out.txt`, `codex-bt-1c-out.txt`,
  `codex-bt-1d-out.txt`, `codex-bt-1e-out.txt`, `codex-bt-2-out.txt`, `codex-bt-3-out.txt`
- Runner script: `run-codex-bt.sh`
- Termination record (PID/PPID/elapsed/command): `codex-termination-record.txt`
- **`codex-HYPRLAND-pass1-PREPARED-NEVER-RUN.md`** — a complete blind Pass-1 packet for the
  compositor and snap defect clusters, written but **never executed**. Usable as a starting
  point; it predates the hovered-scroll defect, which must be added.
- Codex session rollouts: `~/.codex/sessions/2026/07/29/rollout-*.jsonl`

## Open consultations (as of 2026-07-29 — resolved 2026-08-09, see below)

1. **Compositor / coordinate spaces / focus / drag / resize** — must include the unequal
   hovered-but-unfocused scroll path.
2. **Snap / minimize / restore / rail state machine.**
3. **Bluetooth** — compare the failed and successful Xbox traces. Must not block the window work.

---

## 2026-08-09 — recovery consultation completed

The next PM completed the mandated blind-review workflow. Artifacts (runtime state, **not
tracked in Git**) live under `~/.local/state/aurora-build/pm/gen32-recovery/`.

**Two independent blind Pass-1 reviews — completed and converged:**

| Review | Cluster | Artifact | Outcome |
|---|---|---|---|
| A | Compositor / input / focus / drag / resize / scroll | `reviewA-compositor-input.md`, `reviewA-final.md` | completed |
| B | Snap / minimize / restore / rail state machine | `reviewB-state-machine-rail.md`, `reviewB-final.md` | completed |

Both were run before being shown Claude's preferred diagnosis (`claude-diagnosis.md`) and
**substantially converged** with it and each other. The converged, load-bearing findings
are recorded as the defect record **D1–D9** in
[`gen32-recovery-diagnosis.md`](gen32-recovery-diagnosis.md) (D1–D7 and D9 diagnosed;
**D8 remains unresolved**), and the corrected **reservation/reflow** snap model (superseding
the old pair model) is in
`docs/plans/GRAND_PLAN.md` §6.2. Claude's revised diagnosis is
`claude-diagnosis-v2-reservation-reflow.md`.

**Adversarial (Pass-2) review — artifacts present; not asserted as an accepted gate here.**
An initial adversarial review was superseded (`reviewC-SUPERSEDED-final.md`) and re-run
against the reservation/reflow model (`reviewC2-adversarial-reservation-reflow.md`,
`reviewC2-final.md`). These artifacts exist, but this record does **not** claim a fully
accepted adversarial sign-off — the operator's acceptance gate for implementation is
separate and remains open.

**Bluetooth consultation (Review D) — artifact present; conclusions unchanged.** A
Bluetooth review artifact exists (`reviewD-xbox-bluetooth.md`, `reviewD-final.md`), but it
did **not** establish a root cause or reliable repeatability. The authoritative Xbox status
is `docs/reports/xbox-bluetooth-diagnostic.md`: immediate connection proven, ≥13 min stable
once, repeatability **unproven**, root cause **unknown**. No spontaneous disconnect is
proven.

**Boundary:** accepted diagnosis ≠ implemented/physically-accepted fix. No Stage 2 defect
has been implemented, built, or physically accepted. All remain OPEN.
