---
name: dataset-release-integrity
category: dataset
description: This skill should be used when publishing or maintaining a multi-config dataset release (HuggingFace, Zenodo, an internal data lake) — when the user asks to "add a subset", "fix the dataset schema", "update the dataset card", "unify the configs", or whenever a README/datacard makes a structural claim that nobody checks against the data.
---

# Dataset Release Integrity

A dataset card is a *claim* about the data. Nothing enforces it, so it drifts,
and the drift is invisible until a user's code raises. Treat every structural
statement in the card as an assertion that must be tested against the parquet.

## Core rules

1. **The card's front-matter is executable, so test it.** Config names, split
   names and the implied schema are what the hub uses to build the index. Parse
   the front-matter and compare it against the actual files: every config on
   disk declared, every declared config present, every split value in the data
   appearing in its declaration. One release advertised "30 columns, every row
   identical" while two of twelve configs carried 26 — for months, silently.

2. **Schema uniformity is a user-facing contract, not cosmetics.** Cross-config
   concatenation requires matching feature names and types. Two configs short
   of four columns broke the card's own quick-start example for 93,155 rows.
   Assert every config against one canonical schema object.

3. **Acceptance is running the user's snippet, not inspecting the schema.**
   After a schema fix, column counts matching proves the necessary condition.
   Copy the example out of your own README and execute it —
   `load_dataset(...)` for each config, then `concatenate_datasets`. That is
   the form the defect took, so that is the form the fix must be proven in.

4. **A column that exists is not a column that works.** Backfilling a missing
   key column with nulls makes the schema uniform, which is worth doing — and
   changes nothing about whether rows can be identified. State both. "The
   column is there now" is exactly the surface change that gets mistaken for a
   capability, so pin the distinction with a test that asserts the source is
   *still* unjoinable.

5. **Fix the mirror and the release together.** A local staging tree is the
   oracle every check compares against. Updating the hub and leaving the mirror
   stale makes the guards pass on obsolete data: one pinning test kept
   asserting a defect that had already been fixed upstream, and stayed green
   because its oracle was old. Sync both, then let the guards fail and follow
   the failures.

6. **Do not normalise names that carry information.** Split names like
   `data_indoor` / `flat` / `recon` look like a convention violation next to
   train/val/test, but they encode domain or sensor identity. Renaming them for
   tidiness destroys data and breaks parity with what users already downloaded.
   Uniformity applies to *structure*, not to values.

## Before touching published bytes

Order matters, because the release is already in other people's hands:

1. Build corrected shards to a **separate output directory**; never rewrite in
   place. The published tree stays byte-identical until the upload step.
2. Verify property-by-property against the source: row count unchanged, every
   pre-existing column value-for-value identical, binary blobs (images, audio)
   **not re-encoded**, new columns exactly as specified, final schema equal to
   the canonical one including type and order.
3. Re-check **independently** — code that does not import the transform. A
   verifier sharing code with the thing it verifies agrees with a shared bug.
4. Confirm the output **filenames match the published ones** exactly, or the
   upload adds shards instead of replacing them.
5. Record the current revision as a rollback point before uploading.
6. Only then upload, and re-verify by downloading a shard and reading its
   schema. A file listing is not a schema check; identical filenames tell you
   nothing about contents.

## Keeping the card honest

Ship the checks as tests, not as review discipline:

- declared configs == configs on disk
- each declared config's splits == split values in its rows
- every config's columns == the canonical schema
- documented row/column counts in any tier or summary table == measured counts

Add a guard for the guard: assert the parser actually matched something. A
regex that silently stops matching turns every test built on it into a
vacuous pass, which is worse than having no test at all.
