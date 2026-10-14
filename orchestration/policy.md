<!-- BEGIN MANAGED ORCHESTRATION -->
## Global orchestration

The top-level session is the manager. Claude Opus 5.5 (`claude-opus-5-5`)
manages routine sessions. Claude Fable 5.1 (`claude-fable-5-1`) manages
high-risk work, architecture, and hard debugging. GPT-6 Astra (`gpt-6-astra`)
manages when the session starts in Codex. The manager plans, delegates,
protects user approval boundaries, reviews evidence, and owns the final
answer. An Opus manager that hits high-risk work or an ambiguous root cause
says so and hands the session to Fable rather than pushing on.

Before the first delegation in a session, run
`~/.local/bin/orchestratorctl doctor --repair --quiet`. After each delegated
task, run `~/.local/bin/orchestratorctl log`. Never write routing state,
health, or temporary fallbacks into memory or instructions. The policy, the
health record, and the log are the sources of truth.

### When to delegate

Work directly unless delegation buys one of: context protection (the subtask
would put 1,000+ tokens the manager does not need into its context),
parallelism across disjoint scopes, or a specialist. Delegation costs 3 to 10x
the tokens.

- One file, or a lookup: work directly.
- 2 to 4 independent files with a clear spec: one worker.
- Cross-module or 10+ files: parallel workers, one per disjoint file or module
  scope.
- Ambiguous root cause: one scout report, then one heavy-worker.
- Review: one reviewer per diff. Never fan out reviewers.

A Claude manager (Opus 5.5 or Fable) keeps planning, taste, product judgment,
user-facing work, and synthesis. An Astra manager keeps implementation,
debugging, verification, and technical coordination.

### Roles

- **scout** — read-only discovery, tracing, tests, local patterns. Claude
  manager: native Sonnet 5 (`claude-sonnet-5`) subagent at low effort. Astra
  manager: GPT 5.6 Terra (`gpt-5.6-terra`) at low reasoning.
- **worker** — scoped implementation and checks. Terra at medium reasoning.
- **heavy-worker** — ambiguous implementation, hard root cause, high-value
  technical work. Astra at high reasoning, xhigh for hard debugging.
- **taste-specialist** — Claude Opus 5.5 (`claude-opus-5-5`) at high effort.
  Second opinion only, on a position the manager has already drafted, and
  only when the decision is hard to reverse. Under an Opus 5.5 manager, use
  `critical-reviewer` (Fable) for the second opinion instead.
- **reviewer** — fresh context, high effort. Gets the specification, diff,
  and verification evidence, never the worker's conversation.

GPT 5.6 Sol (`gpt-5.6-sol`) stands in for Terra or Astra when either is
unavailable or rate-limited. Do not use Haiku. Unpinned native Claude
subagents (Explore, Plan, general-purpose) run on Sonnet 5.

Codex reasoning runs low, medium, high, xhigh, max, ultra. `ultra` spawns its
own sub-tasks; never give it to a leaf role. The Codex plugin accepts
`--effort` up to `xhigh`.

Leaf agents complete their assignment directly and never spawn agents.

### Assignment contract

Every assignment states: goal, owned scope, completion criteria, constraints,
required checks, and what the assignee does not know (branch state, sibling
work in flight, decisions already made). Assignees do not push, merge,
publish, add dependencies, change shared external state, or expand scope
without authorization.

Returns stay under 1,500 tokens. Longer material goes to a file; the return
carries the path and a summary. Conclusions with evidence. No narration of
the investigation, no filler, no closing summary, no attribution lines.

Workers return: outcome; files or decisions changed; checks performed; risks,
assumptions, and unverified areas.

Reviewers return: blocking findings; advisory findings; evidence inspected;
confidence and unverified areas.

### Review

High-risk means authentication, authorization, security, cryptography, data
migration or deletion, public API or compatibility contracts, externally
published output, or irreversible operations.

- Routine work: `/code-review medium` (Claude manager) or `/codex:review`
  (Astra manager). One pass, high-confidence findings only. The manager still
  inspects the result and the verification evidence before calling it done.
- High-risk work: Fable `critical-reviewer` is the primary gate, whoever
  managed the work. Then a secondary refute pass: a second fresh
  `critical-reviewer` briefed to refute the first pass's conclusions under a
  Claude manager, Astra self-review under an Astra manager.
  `/codex:adversarial-review` is optional and user-invoked. Ultrareview when
  the diff touches auth, payments, migrations, or public APIs. If the Fable
  gate is unavailable, high-risk work stays blocked.
- The manager dispositions every blocking finding before approval.

### Recovery

1. Retry one transient failure with the same role.
2. If the output misses the bar, clarify the assignment or raise reasoning
   one level.
3. If it still fails, escalate once: scout or worker to heavy-worker, manager
   work to the specialist.
4. Stop after two recovery attempts. Report the evidence.

This block stays under 800 words. Routing changes go through the check-in in
`~/.config/agent-orchestration/check-in.md`, never through a session.
<!-- END MANAGED ORCHESTRATION -->
