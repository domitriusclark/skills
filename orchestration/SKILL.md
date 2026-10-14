---
name: orchestration
description: Install, health-check, and run the check-in for a manager-and-roles orchestration policy across Claude Code and Codex.
disable-model-invocation: true
---

The top-level session manages and delegates to five roles (scout, worker, heavy-worker, taste-specialist, reviewer) across Claude and Codex models. Every delegation is logged, and routing changes only through a check-in backed by that log.

- [policy.md](policy.md): the routing policy, installed as a managed block in `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`.
- [check-in.md](check-in.md): the review questions and decision rules.
- [templates/](templates/): agent profiles. `claude/` installs to `~/.claude/agents/`, `codex/` to `~/.codex/agents/`.
- [scripts/orchestratorctl](scripts/orchestratorctl): `doctor`, `log`, and `report`. Needs Python 3.11 or later.

GPT roles need the Codex CLI and its Claude Code plugin, and `doctor` expects `~/.codex/config.toml` to set `model = "gpt-6-astra"` with `model_reasoning_effort` of `medium` or `high`. Without Codex the Claude roles still work, and `doctor` reports the Codex checks as problems.

Run the mode the user named. If they named none, ask: install, doctor, or check-in.

## Install

1. Show the user the model IDs in `policy.md` and confirm they have access to each. The IDs also appear in the templates and in the constants at the top of `scripts/orchestratorctl`; a model change edits all three.
2. For each of `policy.md`, `check-in.md`, and `templates/` that already exists under `~/.config/agent-orchestration/` and differs from this skill's copy, show the diff and ask which wins. In step 3, drop each one the user keeps from the `cp` line. Never overwrite one silently. Also tell the user that step 4 replaces any existing `~/.claude/agents/{critical-reviewer,opus-specialist}.md` and `~/.codex/agents/{scout,worker,heavy-worker,reviewer}.toml`, so they can rename their own first.
3. Run `python3 -c 'import tomllib'`. If it fails, `python3` is older than 3.11: stop and tell the user to install a newer Python. Then copy the files, with `<skill>` as this skill's directory:
   ```bash
   mkdir -p ~/.config/agent-orchestration ~/.local/bin ~/.claude ~/.codex
   touch ~/.claude/CLAUDE.md ~/.codex/AGENTS.md
   cp -R "<skill>/policy.md" "<skill>/check-in.md" "<skill>/templates" ~/.config/agent-orchestration/
   install -m 755 "<skill>/scripts/orchestratorctl" ~/.local/bin/orchestratorctl
   ```
4. Run `~/.local/bin/orchestratorctl doctor --repair`. It writes the policy between the `MANAGED ORCHESTRATION` markers in both instruction files, appending the block if absent, and installs the agent profiles. Each overwritten file is backed up to `~/.config/agent-orchestration/backups/auto/` under a dot-prefixed name, so list it with `ls -a`. A symlinked instruction file is written through, so the link survives.
5. Report every `repaired:` and `problem:` line.

Done when `doctor` prints `healthy` or `repaired`, or each remaining problem is one the user accepted, such as running without Codex.

## Doctor

Run `~/.local/bin/orchestratorctl doctor` and report the status and each problem. Add `--repair` only after the user says yes, because it rewrites global instruction files. Once installed, the policy itself has each session run `doctor --repair --quiet` before its first delegation, so drift from `policy.md` repairs automatically. Add `--probe` to confirm each model answers; each probe can take up to 150 seconds.

## Check-in

1. Run `~/.local/bin/orchestratorctl report`. If it prints `collect evidence`, no tasks are logged yet: say so and stop. If it prints `not due`, report the counts and stop unless the user wants an early check-in.
2. Run `~/.local/bin/orchestratorctl doctor --probe`.
3. Answer every question in `check-in.md` in one or two lines, citing report counts or named tasks.
4. Propose at most one routing change that follows the decision rules, with the exact `policy.md` text before and after.
5. Wait for the user's yes. Then edit `~/.config/agent-orchestration/policy.md`, plus the templates and `orchestratorctl` constants if a model changed, and run `doctor --repair` to propagate it.
6. Write the record to `~/.config/agent-orchestration/check-ins/<YYYY-MM-DD>.md` with sections Trigger, Evidence, Review questions, Decision, Follow-ups, and a status line saying whether the user confirmed it.

Never edit the managed block in `CLAUDE.md` or `AGENTS.md` by hand: the next `doctor --repair` overwrites it from `policy.md`.
