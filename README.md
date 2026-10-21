# Claude Code Skills

Reusable [Claude Code skills](https://docs.anthropic.com/en/docs/claude-code/skills) for common workflows.

## Skills

| Skill | Description |
|---|---|
| [deliver](deliver/) | Shape outward text (reviews, comments, Slack asks, PR bodies, handoffs) for the reader it is going to. Adapted from [ayghri/i-have-adhd](https://github.com/ayghri/i-have-adhd) (MIT). |
| [orchestration](orchestration/) | Install, health-check, and run the check-in for a manager-and-roles orchestration policy across Claude Code and Codex |
| [pr-ready](pr-ready/) | Get a PR to a decision and leave you able to speak to it: hygiene, independent review, a one-hunk-at-a-time review page with margin notes and a teach-back, and PR text. Works outbound (your branch) and inbound (someone else's PR). |

## Usage

Install a skill globally:

```bash
claude skill install --global path/to/skill
```

Or add to a project's `.claude/skills/` directory.
