---
name: pr-ready
description: Get a PR to a decision, and leave the user able to speak to it. Outbound (our branch): hygiene, independent review through the orchestrator, a review workspace page, a teach-back, and the PR text ready to post. Inbound (their PR): the same workspace page with draft comments in the repo's conventions. Use when the user says a PR is ready, asks to "prep the PR", "run pr-ready", wants a review before submitting, or is reviewing someone else's PR ("brief me on #123", "review kit"). Offer it when substantial branch work is done and a PR is the next step.
---

# pr-ready

Two jobs, in this order: get the PR to a decision, and leave the user able to explain the change without reading the diff twice. The second is not optional. A page that catalogs findings and skips the map has failed even when every finding is right.

This skill decides what to say. `/deliver` decides how to say it. Every piece of outward text goes through `/deliver` with its reader named: review body and inline comments for the PR author; PR title and body for the reviewers; the page and the terminal summary for the user.

**Never** posts the PR, approves, submits a review, force-pushes, or writes files into the repo. State lives in `~/.agents/knowledge/<repo-key>/` (`repo-key` = slug of `git remote get-url origin`). The GitHub actions are the user's.

**Repo-agnostic.** Repo habits come from `review-norms.md` and nowhere else. A norm not in that file is not assumed.

## 0. Scope

1. **Direction.** Outbound = we authored the branch; inbound = the user reviews someone else's. Ambiguous: `gh pr view --json author`, then confirm.
2. **Base ref.** State it. A stacked branch bases on its parent, not main.
3. **Load** `~/.agents/knowledge/<repo-key>/`: `review-norms.md`, `knowledge-map.md`, `calibration.md`, `briefings/`.
4. **Calibrate** (lazy, background scout). For each briefing whose PR has since merged and is not yet in `calibration.md`: compare our findings against the human review threads. Append one line per PR: date, PR, hits, misses (what humans caught that we did not), false positives (what we raised that was dropped), and what each miss was about. Keep a running tally at the top. The tally goes on the page. No merged PRs: write "no merged reviews checked yet".
5. **Research norms** when `review-norms.md` is missing, older than four weeks, or asked for. Scout, read-only `gh api graphql`, 30 to 50 merged PRs with human reviews. One line each with a count: approve vs changes-requested among humans; body vs inline; comment prefix scheme; recurring catches; bot logins; whether reviewers say what they ran; the user's own voice here. Date, sample size, confidence. Under ten PRs: "insufficient history, generic defaults".
6. **Ticket.** If the branch, body, or user names a Linear issue, fetch it. Its done-when drives the compliance table and the approach verdict. Connector down: say so, continue.
7. **Context from people.** Slack, Linear comments, standup notes the user offers. It can change the verdict. Ask once if none was offered and the PR looks like part of a series.
8. **Diff.** Outbound: `git diff <base>...HEAD` plus `git status`. Inbound: `git fetch origin pull/<n>/head`, diff against the merge-base, record the head SHA. Every excerpt is stamped with it. Empty diff: stop.
9. **Existing threads** on an open PR via GraphQL. A finding already raised is marked, not repeated.

## 1. Hygiene (outbound only)

Report both passes as one unit, wait for approval, apply only what was approved.

**Comments.** A comment states a constraint the code cannot show, in one or two lines. Flag narration, ticket or date or person references, history, blocks several times their needed length, session-invented names. Give `file:line`, a verdict (drop, trim, rephrase, refactor), and a keep list. If `/comment-audit` is installed, invoke it instead.

**PR text.** Title imperative, under 70 characters, matching `git log`. Body follows `.github/PULL_REQUEST_TEMPLATE.md` when present; otherwise Problem, Approach, Tests (command and result), Risk, Rollback, one or two lines each. Every claim is supported by the diff. No file-by-file restating.

## 2. Findings

1. **Orientation first, before any finding.** Write, in under 120 words: what the change does and why; the shape (the parts, in the order a reviewer should read them); the approach verdict (**right**, **arguable**, **wrong**, one reason, judged against the ticket's done-when; no ticket and no stated goal: "arguable, no stated goal", and the first step becomes asking the author); the one thing that decides the review, checkable in under two minutes. Every sentence points at a file or a named part. If it cannot be written that way, the PR is too big to review as one unit; say so.
2. **Pre-pass** against each recurring catch in `review-norms.md`.
3. **Independent review**, per the orchestration policy in `~/.claude/CLAUDE.md`. Routine: `/code-review medium`. High-risk (auth, security, data deletion or migration, public API, published output, irreversible operations): fresh-context `critical-reviewer` as the gate, then the Codex refute pass:
   ```bash
   COMPANION=$(ls -t ~/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs | head -1)
   node "$COMPANION" adversarial-review --background --base <base-ref> "<one line: what the PR claims>"
   ```
   Reuse prior findings when the head SHA matches a saved briefing, and say so. Reviewer unavailable: say so; high-risk stays blocked.
4. **Run what can be run**: tests for every touched module (name the ones with none), the linter on changed files, the type check. A finding a local action could settle gets that action; one that cannot is a hypothesis.
5. **Disposition.** One severity each: **Blocking**, **Ask first**, **Should fix**, **Question**, **Nit**. Provenance (mine, reviewer, already on PR). Every finding carries a **how I know** line: what was traced, run, or compared, and what was not. Disagreeing with a reviewer takes one line. Nothing is dropped without a reason. Outbound: fixes for Blocking and Should fix (mechanical now, logic after approval); Question and Ask first become one honest sentence in the body.

## 3. The page

One page per PR, same URL on redeploy. Save the markdown source to `~/.agents/knowledge/<repo-key>/briefings/<branch-or-pr>.md` first. Build the page from `templates/review-page.html` in this skill's directory: keep its layout, tokens, script, and the `db` + `user` capabilities; replace the content. Publish with `capabilities: {db: {}, user: {}}`. Do not add cards, a findings list, a how-to, or a quiz.

**Rail**, always above the fold: orientation (what, approach chip); the decider with an amber edge; the reading order with a time per hunk; progress; the calibration tally; what is not shown and why; checks run.

**Hunks**, one on screen at a time, in review order, not file order. Each: path linked to its GitHub diff anchor; one italic line on why it is in the walk; the diff, copied from the head SHA, with a gutter tick on each noted line; notes in the right margin at their line, serif, each with severity, the reason, the draft comment with a copy button, and the how-I-know line. Skipped hunks are named in the rail, not shown. Footer: the three-way check (I could explain this, Read it but not sure I could, I disagree with the note), a Notes for Claude box, Back and Next, and an "Up next" line.

**End**: Before you post, built from the three-way answers (unsettled, unsure, disputed, each with the exact terminal phrase to use); the review body draft with copy; a Notes for Claude box for the whole review; Say it back (three sentences the user writes first; mine revealed only after); collapsed: ticket compliance, verify table, provenance and norms.

The page writes one document, `review/<pr>`, with `states`, `notes`, `say`, `updated`.

**Outbound differences.** Add `<meta name="pr-ready:direction" content="outbound">` beside the title; the template switches labels, flags, and the say-it-back prompt. Mark a hunk whose finding is still open with `data-unfixed`. Hunks are the places a reviewer will stop, in the order they will read. Each margin note is a pushback: what they will ask, the answer in two or three lines, the excerpt that proves it, and how I know. Honest weak spots are notes too, marked **weak**, with what you say when asked. Fixed findings are listed in the rail under "fixed before posting", not shown as hunks. The three-way check reads: I could defend this, Not sure I could defend it, I'd change this before posting. Before you post blocks on unfixed Blocking or Should fix, on any "change this", and on unsettled hunks. Say it back asks for two sentences: what this PR does and why this way; they double as the body's first lines. Under details: alternatives rejected, if asked X say Y.

## 4. Teach-back, in the terminal

Before the terminal summary, read `review/<pr>` with `ArtifactData` (collection `review`). Then:

1. Any hunk marked **disagree** (inbound): defend it in three lines or drop it, and say which. Marked **change this** (outbound): propose the change in three lines, apply after approval, redeploy the page. Nothing is posted until this is settled.
2. Any hunk marked **unsure**: ask one question about that hunk, in the form a reviewer would ask. No re-explaining first.
3. All settled, none unsure: ask one question anyway, drawn from the concept in `knowledge-map.md` with the weakest status that this PR touches. Outbound: ask it from the pushback material.
4. Compare the say-it-back with the orientation. Name the gap in one line, or say there is none.

Two questions per PR at most. A solid answer moves the concept to `solid` with the date; a skip leaves it and it is asked again next time it shows up. Record new concepts as `new`, each in two lines with where it lives. Every note in `notes` is read and answered or acted on; a note about the page itself becomes a feedback memory.

## 5. Wrap-up

Terminal summary through `/deliver`, for the user about to act: their next action (post the PR, answer N questions, post N draft comments), the open items, the page link, and, outbound, the `gh pr create` command with the approved title and body file. Stop.

Phases run standalone on request: "just the review", "just the page", "refresh the norms", "calibrate", "grill me on <PR>", "read my notes".
