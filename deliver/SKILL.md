---
name: deliver
description: Shape anything meant for another person to act on (reviews, inline comments, Slack asks, PR bodies, handoffs, status updates, briefings) for the reader it is going to. Reads the session and the destination to decide who that reader is and how much to explain. Invoke with /deliver; other skills send their outward text through it.
---

# deliver

Every message has a reader. Work out who from the session before writing.

## 1. Read the context

Infer from the session and where the text is going:

1. **Destination:** GitHub review body or inline comment, PR body, Slack channel, DM or thread, Linear, email, an artifact, the terminal.
2. **Reader:** the author of the work, a reviewer, a teammate from another area, someone deciding, or the user.
3. **What they already know:** their own code, the thread so far, the domain, or nothing.
4. **What they must do:** fix, decide, answer, approve, or nothing.

A calling skill that names the reader wins. Otherwise, put your guess in one line above the draft ("Reader: Sean, PR author, review body") so the user can correct it.

## 2. Pick the depth

| Reader | Already knows | Gets |
|---|---|---|
| Author of the work | How it works | Asks only. Where, what's wrong, `Fix:`. No reasons. |
| Peer from another area | The domain, not this work | The ask, plus one line of context per item. Terms defined. |
| Someone deciding | The goal, not the details | The verdict and the tradeoff. No code. |
| The user, preparing | Nothing yet | Full evidence. Verdict first, detail collapsed. |

When one piece of work has two readers, such as a review kit for the user and comments for the author, shape each part for its own reader.

## 3. Write

1. Line one is the single action or ask. Include a deadline only when one exists. Give a time estimate only for the user's own next step.
2. Blocking items come before optional ones. Number them, and show five or fewer.
3. Test every clause: does this reader need it to act? Cut what they already know. Keep a reason only when they might disagree, or can't see the problem themselves.
4. Say the concrete thing, not a stand-in word ("load-bearing," "seam," "floor").
5. Put context and evidence last, after a `---` rule, under a bold one-word label. Five bullets or fewer, and only what the reader lacks.
6. The last line says what happens next, and what happens if nothing does.

Formatting by channel:

- **GitHub, Linear, email:** plain markdown, no HTML.
- **GitHub inline comment:** one item, no header.
- **Slack:** the ask and the items go in the top post; the evidence goes in a thread reply.
- **Artifact for the user:** collapsibles are fine.

## 4. Check before sending

For each item, delete every clause after the `Fix:`. If the reader could still act on it, leave them deleted.

Too much: `skill.mjs:219`: spawnSync has no timeout, and ctx-generate.yml sets no timeout-minutes, so a hung validator stalls the loop until GitHub's 6-hour limit and the remaining groupings never run. Fix: add a timeout; status then comes back null, which already throws as a retryable tool error.

Right: `skill.mjs:219`: no timeout, so a hung validator stalls Generate for up to 6 hours. Fix: add `timeout: 60_000, killSignal: 'SIGKILL'`.

## 5. Corrections stick

When the user says a draft is too dense or too thin, shift the level and keep it for the rest of the session. Record the correction as a feedback memory, so the next session starts there.

Break these rules when the reader asks for an explanation, and before a destructive action.
