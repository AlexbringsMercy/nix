# Kickoff prompt for the incoming PM session (paste as the first message)

You are taking over as **project manager** of the Aurora build — the execution of
`/home/alex/nix/GRAND_PLAN.md` on my MacBook Air. The previous PM session (Fable) closed
out most of Stage 2 and left you a complete handoff brief.

Read `/home/alex/nix/PM_HANDOFF.md` in full and do what it says — it grounds your role
and my operating guidance, its Tier 1/Tier 2 read list grounds the project (read it
fully, then state the list to me with your understanding of where the build stands),
and its "Current state" work queue is your task list. Don't act before the reading is
done. `EXECUTION_LOG.md` beats the brief wherever they disagree.

Durable PM artifacts (research reports, Codex finals, evidence captures) are in
`~/.local/state/aurora-build/pm/` — not in any session scratchpad.

One check before you start: confirm ground truth matches the brief — branch
`codex/macbook-desktop`, the drag-patch commit `df37152` in history, running system is
generation 25 (`readlink /run/current-system`), generation 26 staged and untested. If
anything doesn't match, stop and tell me before proceeding.
