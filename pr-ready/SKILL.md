---
name: pr-ready
description: Get a PR to a decision. Outbound (our branch): hygiene, independent review through the orchestrator, a defend-it briefing, and the PR text, ready for the user to post. Inbound (their PR): a verdict-first review kit with draft comments in the repo's conventions. Use when the user says a PR is ready, asks to "prep the PR", "run pr-ready", wants a review before submitting, or is reviewing someone else's PR ("brief me on #123", "review kit"). Offer it when substantial branch work is done and a PR is the next step.
---

# pr-ready

This skill decides what to say. `/deliver` decides how to say it. Send every piece of outward text through `/deliver`, and name its reader:

| Piece | Reader |
|---|---|
| Review body, inline comments | The PR author |
| PR title and body (outbound) | The reviewers |
| Kit or briefing page | The user, preparing |
| Terminal summary | The user, about to act |

**Never** posts the PR, approves, submits a review, force-pushes, or writes files into the repo. State lives in `~/.agents/knowledge/<repo-key>/` (`repo-key` = slug of `git remote get-url origin`, e.g. `github.com-netlify-cli`). The GitHub actions are the user's.

**Repo-agnostic.** Nothing here describes one repository. Repo habits come from the research step and live in that repo's `review-norms.md`. If a norm is not in that file, do not assume it.

## 0. Scope

1. **Direction.** Outbound = we authored the branch; inbound = the user reviews someone else's. Ambiguous: `gh pr view --json author`, then confirm.
2. **Base ref.** State it. A stacked branch bases on its parent branch, not main.
3. **Load** `~/.agents/knowledge/<repo-key>/`: `review-norms.md`, `briefings/`, and `knowledge-map.md` if present.
4. **Research norms** when `review-norms.md` is missing, older than four weeks, or asked for. Delegate to a scout (read-only `gh api graphql`, background). Sample 30 to 50 merged PRs with reviews and threads. Answer, each in one line with a count: approve vs changes-requested ratio among humans; body vs inline; any comment prefix scheme found by frequency; recurring catches across reviewers; bot reviewers by login; whether reviewers say what they ran; the user's own comment voice here. Write date, sample size, and a confidence line. Under ten merged PRs with human reviews: write "insufficient history, generic defaults" and stop inferring.
5. **Ticket.** If the branch, body, or user names a Linear issue, fetch it. Its scope and done-when drive the compliance table. Connector down: say so, continue.
6. **Context from people.** Slack, Linear comments, standup notes the user offers about priority, sequencing, or deferred follow-ups. It can change the verdict. Ask once if none was offered and the PR looks like part of a series.
7. **Diff.** Outbound: `git diff <base>...HEAD` plus `git status`. Inbound: `git fetch origin pull/<n>/head`, diff against the merge-base, record the head SHA. Every excerpt is stamped with it. Empty diff: stop.
8. **Existing threads** on an open PR via GraphQL. A finding already raised is marked, not repeated.

## 1. Hygiene (outbound only)

Report both passes as one unit, wait for approval, apply only what was approved.

**Comments.** A comment states a constraint the code cannot show, in one or two lines. Flag: narration of what adjacent code does; ticket, date, or person references; history and self-dialogue; blocks several times their needed length; session-invented names. Give `file:line`, a verdict (drop, trim, rephrase, refactor), and a keep list of load-bearing comments. If `/comment-audit` is installed, invoke it instead.

**PR text.** Title imperative, under 70 characters, matching `git log` conventions. Body follows `.github/PULL_REQUEST_TEMPLATE.md` when present; otherwise Problem, Approach, Tests (command and result), Risk, Rollback, one or two lines each. Every claim is supported by the diff. Link the ticket the way this team does. No file-by-file restating.

## 2. Findings

1. **Pre-pass.** Check the diff against each recurring catch in `review-norms.md`. No norms, no pre-pass.
2. **Independent review**, per the orchestration policy in `~/.claude/CLAUDE.md`. Routine: `/code-review medium`. High-risk (auth, security, data deletion or migration, public API, published output, irreversible operations): fresh-context `critical-reviewer` as the gate, then the Codex refute pass:
   ```bash
   COMPANION=$(ls -t ~/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs | head -1)
   node "$COMPANION" adversarial-review --background --base <base-ref> "<one line: what the PR claims>"
   ```
   Reuse prior findings when the head SHA matches a saved briefing, and say so. If a reviewer is unavailable, say so; high-risk work stays blocked without the gate.
3. **Run what can be run**, with the repo's documented invocations: tests for every touched module (name the ones with none), the linter on changed files, the type check. A finding a local action could settle gets that action; one that cannot is labelled a hypothesis.
4. **Disposition.** One severity each: **Blocking**, **Ask first** (blocking unless named context covers it), **Should fix**, **Question**, **Nit**. Carry provenance (mine, reviewer, already on PR). Disagreeing with a reviewer's severity takes one line. Nothing is dropped without a disposition. Outbound: fixes for Blocking and Should fix (mechanical ones now, logic after approval); Question and Ask first become one honest sentence in the body; rejected findings keep their reason because a reviewer will ask.

## 3. The artifact

One page per PR, redeployed to the same URL. Save the markdown source to `~/.agents/knowledge/<repo-key>/briefings/<branch-or-pr>.md` first. Load `artifact-design`, static page, about one screen, collapsibles for everything below the fold. Excerpts are copied from the head SHA at publish time, never from memory.

**Inbound kit, in order:** verdict in one label (calibrated to the repo's decision norm) plus two sentences on what decides it; fact line (diff size, counts by severity, local checks, CI as reported); context from people and what it changed; ticket compliance as done, partial, missing; findings ranked, collapsed to key, severity, title, `path:line`, expanded to the draft comment (written by `/deliver` for the author, in the repo's convention), the excerpt, a probe (where, do, expect), provenance; where to look, in order, linking GitHub file anchors; verify table. Under details: how this repo reviews, looks fine, background.

**Outbound briefing, in order:** where this lands (fixed, acknowledged in the body, rejected and why); ticket compliance; likely pushback, two or three decisions with the defense and excerpt; honest weak spots; where to look, in order; verify table, which doubles as the body's test plan. Under details: alternatives rejected, if asked X say Y.

Not on the page: a how-to block, navigation, the diff, a quiz. If the page seems to need them, it is too long.

## 4. Wrap-up

Terminal summary through `/deliver`, for the user about to act: their next action (post the PR, answer N questions, post N draft comments), the open items, the artifact link, and, outbound, the `gh pr create` command with the approved title and body file. Stop.

Record concepts taught in `knowledge-map.md` (new, seen, solid). Offer, never force, a short comprehension check drawn from the pushback material; a solid answer marks the concept solid.

Phases run standalone on request: "just the review", "just the kit", "refresh the norms", "grill me on <PR>".
