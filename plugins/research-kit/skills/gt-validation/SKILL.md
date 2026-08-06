---
name: gt-validation
description: This skill should be used when the user asks to "validate a method/estimator", "compare with ground truth", "find datasets to validate on", or needs to evaluate a perception/estimation pipeline against labeled or proxy ground truth without fooling themselves.
---

# Ground-Truth Validation

Validate an estimator against external datasets so that the numbers survive
adversarial scrutiny — including your own.

## Core rules

1. **Non-circular splits.** Never define the evaluation set using the signal
   under test. If you split "contact vs no-contact" rows, the split must come
   from an independent signal (a different sensor, metadata, an unrelated
   statistic of the same data).
2. **Fit and evaluate on disjoint data.** Any fitted constant — even a single
   scalar — comes from a train half (or a different dataset) and is scored on
   the held-out half. Report the fit's provenance next to the number.
3. **Scope before scoring.** Identify regimes the method cannot represent
   (saturation ranges, out-of-scope loading modes) from physics or data,
   exclude them explicitly, and REPORT the exclusion as a limitation — never
   silently.
4. **Stratify before averaging.** Pooled correlations hide confounds
   (per-object gain, spatial position, force bands). Report pooled AND
   stratified metrics; when stratified ≫ pooled, name the confound.
5. **Estimate the ceiling.** Find a physically privileged predictor in the
   dataset (commanded depth, encoder position) and score it too. If the
   ceiling is 0.8, your 0.65 means something different than if it is 1.0.
6. **No ground truth? Use agreement + proxies.** Two independent methods that
   agree at high rank-correlation, plus zero-response on known-negative
   samples, is real evidence. A monotone proxy (press depth vs force) gives
   attenuated rank correlation — say so when reporting it.

## Default workflow

1. Inventory candidate datasets (HF hub, lab disks, aggregate datasets like
   FoTa often hide labeled subsets inside archives — read manifests, not just
   file listings).
2. Peek at actual samples FIRST: image geometry, label fields, units, gel or
   sensor variant. One decoded sample prevents a day of wrong pipelines.
3. Establish references/zeroing from the dataset's own free samples; if free
   samples are scarce, use a per-pixel median over scattered samples and say
   so.
4. Build a per-frame **feature cache** (expensive inference once, metrics
   forever) — see the `evidence-driven-optimization` skill.
5. Produce the method × dataset matrix: every method on every dataset,
   predicted-vs-GT scatter per dataset so dataset quality is controlled
   within a row.
6. Record every failed protocol in the debug ledger (see `debug-ledger`).

## Reporting

- Always: n, metric, scope, fit provenance, exclusions.
- Banded absolute errors (per force/level band) alongside rank correlation —
  they answer different questions.
- Cross-dataset scale stability is a finding: report the spread of
  independently fitted scales.
