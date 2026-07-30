# PM KICKOFF — GEN 32 RECOVERY

Start here. You do not need to read any prior chat transcript.

## Situation in one paragraph

Generation 32 is booted and **physically FAILED** despite an automated structural gate of
41 PASS / 0 FAIL / 0 UNVERIFIED. Ten operator-observed defects span snap, focus, drag, tiled
resize, rail state and pointer scrolling. Stage 2 is **OPEN**, the operator gate was stopped,
and no Stage 3 work is permitted. The previous PM session was terminated by the operator and
**none of its root causes are accepted**. A separate, still-open Xbox controller Bluetooth
issue is intermittent, not a generation regression, and must not block the window work.

## Read first, in this order

1. `SESSION_PREAMBLE.md`
2. `PM_OPERATING_RULES.md`
3. `PM_HANDOFF_GEN32_HARD_FAIL_2026-07-29.md` ← ground truth, failure matrix, constraints
4. `GRAND_PLAN.md` §6 (window model) and `STAGE2_CLOSEOUT_WORK_ORDER.md`
5. `docs/stage2-runtime-gate.md` (the gate that was stopped)
6. `EXECUTION_LOG.md` (tail)

## First actions

1. **Verify live ground truth. Do not inherit the handoff blindly.** Confirm booted generation,
   branch/HEAD, tree cleanliness, free disk, loaded compositor and plugin identities, and which
   diagnostic processes are running.
2. **Inspect the gen 31 → gen 32 source and ordered patch differences yourself** with
   `nix derivation show` on both compositor outputs. The only compositor delta is
   `hyprland-dwindle-resize-workarea.patch`, appended last; the other two patches are
   byte-identical store paths. Do **not** assume a small patch is isolated.
3. **Run two blind GPT-5.6 Sol `xhigh` advisory reviews**, web search available, read-only,
   bounded invocation that captures the real child process and completion state:
   - **Review A — compositor / coordinate spaces / focus / drag / resize.**
     **Include defect F8, the unequal hovered-scroll path**, in this review.
   - **Review B — snap / minimize / restore / rail state machine.**
   Pass 1 must be blind: give the reviewer the operator's exact observations, the gen 31 vs 32
   behaviour, logs, timestamps, exact source/diff and acceptance behaviour — **not** your
   diagnosis. A prepared (never-executed) blind packet exists at
   `~/.local/state/aurora-build/xbox-known-good/codex-attempts-INCOMPLETE/codex-HYPRLAND-pass1-PREPARED-NEVER-RUN.md`;
   it predates F8, so add it.
4. **Compare the failed and successful Xbox traces** and obtain a proper Bluetooth consultation
   **without blocking the window diagnosis**. Evidence and checksums are in
   `~/.local/state/aurora-build/xbox-known-good/` (see handoff §5).
5. **Surface any material Claude/Codex disagreement to Alex** before implementing. It may not be
   resolved by PM preference.
6. **Produce one root-cause report and one frozen correction manifest before editing anything.**
7. **Batch the correction into one closure and one later reboot.** No per-fix builds or reboots.

## Hard constraints

- No implementation before both blind reviews **and** the adversarial second review are complete.
- **Preserve the rail previews and exact-window selection** — the one window-model item that
  works. Also preserve everything in handoff §4.
- **Do not** fix the hovered-scroll defect by raising a global `scroll_factor`; the focused path
  is already correct.
- **Do not** claim restore-position is solved until snap itself is stable.
- Gen 31 is comparison evidence only, **not** an accepted fallback; do not roll back without
  Alex's explicit approval.
- Tell Alex to **avoid snap on gen 32** until the correction lands.
- Boot-only deploys only (`nix-env --profile --set` + `switch-to-configuration boot`).
- Never pass `--override-input macbook-config path:/home/alex/nix`.

## Highest-priority hypothesis — unproven, verify independently

The snap dispatch in `modules/home/hyprland/hyprland/keybinds.lua` calls
`io.popen("hyprctl monitors -j")` from inside a Hyprland Lua bind callback, and `hyprctl`'s
client socket timeout is exactly 5 s. This *may* explain both the ~5 s freeze and the
rail-overlapping geometry (the fallback returns all-zero reserved margins). **It was never
verified by instrumentation.** Prove or reject it; do not inherit it. No synchronous
`hyprctl`/IPC/subprocess call may run inside a compositor callback in the corrected design, and
the fix must not be "shorten the timeout".

## Operator's state at handoff

Two acceptance items are outstanding on the Xbox controller and only Alex can answer them:
**is the LED steady**, and **do buttons, sticks and triggers produce input**. `bluetoothd` is
still in runtime debug mode (`kill -USR1 1050` restores normal logging without a restart; no
config change was made). A revocable root-channel kitty window may still be open — closing it
revokes root.
