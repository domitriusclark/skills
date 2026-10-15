# Orchestration check-in

Run the first review after 10 meaningful delegated tasks or 14 days from the
first recorded task, whichever comes first:

```sh
~/.local/bin/orchestratorctl report
~/.local/bin/orchestratorctl doctor --probe
```

## Review questions

1. Did delegation save manager time or add coordination overhead?
2. Which roles were used, and which never earned their place?
3. How often did work require a retry or escalation?
4. Did medium effort usually succeed for ordinary work?
5. Did independent reviews find blocking issues that manager review missed?
6. Were any cross-family routes unavailable or unreliable?
7. Did Fable retain judgment/taste work and Sol retain technical execution?
8. Were safety, scope, and user approval boundaries preserved?

## Decision rules

- Keep a route unchanged when it works reliably and avoids unnecessary
  coordination.
- Clarify its assignment contract before increasing model or effort.
- Raise effort or escalate a role when repeated failures share the same
  complexity cause.
- Remove a profile that has no distinct use after enough representative work.
- Add a new permanent model route only when repeated tasks show a stable niche.
- Change one routing variable at a time so the next check-in remains useful.
- Never automatically weaken high-risk review or approval requirements.

Record the decision and the evidence behind it. Telemetry informs the decision;
it does not rewrite policy.
