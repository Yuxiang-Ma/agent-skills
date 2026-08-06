---
name: debug-ledger
description: This skill should be used during any multi-step technical investigation or long autonomous work session — keeps a found→fix ledger and a plan file so that failures, rejected ideas, and negative results survive context loss and become publishable evidence.
---

# Debug Ledger

Failures are data. Keep them in a structured ledger from the first bug, in a
plan file that lives in the repo — not in the conversation.

## The ledger format

A table in the plan/notes file, one row per defect:

| found | evidence | fix | verified by |
|---|---|---|---|
| what was wrong | the number/observation that exposed it | what changed | the re-run number |

Plus a **rejected-ideas** list: variant, motivation, measured result,
verdict. A rejected idea with a number ("quadratic background: rho 0.61 →
0.50, absorbs real signal — rejected") prevents the next person (or the
next session) from re-trying it.

## Rules

1. **Write the row when the fix lands**, not at the end — end-of-session
   reconstruction loses the evidence column.
2. **Negative results are deliverables.** A method that fails out-of-domain
   with a number (in-domain 0.96 → out-of-domain 0.04) is a finding; keep it
   in the final report/site, typically as a collapsed section.
3. **Every fix names its regression check** — what re-ran to prove the fix,
   and that previously-passing checks still pass. An optimization that
   flips a previously-green test is a new ledger row, not a footnote.
4. **Plan file discipline** (long sessions): goals, phases with checkboxes,
   key facts (paths, constants, auth), the ledger, and current status —
   updated as phases close. After context loss, the plan file is the resume
   point.
5. Version-stamp regenerable artifacts (`pipeline_version` in outputs) so a
   fixed pipeline invalidates stale outputs mechanically instead of by
   memory.

## When to surface it

- In results pages/reports: a "what actually went wrong" section builds
  more trust than the headline metric.
- In commit messages: the defect and its evidence, not just the change.
