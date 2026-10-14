# Claude Code Skills

Reusable [Claude Code skills](https://docs.anthropic.com/en/docs/claude-code/skills) for common workflows.

## Skills

| Skill | Description |
|---|---|
| [deliver](deliver/) | Shape outward text (reviews, comments, Slack asks, PR bodies, handoffs) for the reader it is going to |
| [pr-ready](pr-ready/) | Get a PR to a decision: hygiene, independent review, a defend-it briefing, and PR text, or a review kit for someone else's PR |

## Usage

Install a skill globally:

```bash
claude skill install --global path/to/skill
```

Or add to a project's `.claude/skills/` directory.
