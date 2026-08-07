---
name: evidence-driven-optimization
category: research
description: This skill should be used when the user asks to "optimize the method", "improve accuracy", "why is the metric low", or wants to iterate on an algorithm/pipeline against a measurable target without cargo-culting changes.
---

# Evidence-Driven Optimization

Improve a pipeline only through changes whose motivating defect was measured
first, and whose effect is verified on held-out data.

## Core rules

1. **Cache features, iterate on the cache.** If per-sample inference is
   expensive, compute every candidate feature once per sample into a JSON/
   parquet cache; every model variant, threshold, and ablation then costs
   milliseconds. Never re-run inference to try a regressor.
2. **Diagnose before changing.** A low metric is a symptom. Localize it:
   stratify residuals against every available covariate (position, object,
   magnitude, time). The covariate that correlates with residuals names the
   fix. Example pattern: force-fit residuals correlating with contact
   position (|rho| 0.6) → illumination flat-fielding, not more model
   capacity.
3. **One change, one A/B, same data.** Compare variants on the identical
   sample set; report before → after. A change without a paired number did
   not happen.
4. **Keep the rejected variants.** A tried-and-rejected idea (with its
   number) is worth almost as much as an accepted one — it stops the next
   person from re-trying it. Record: variant, motivation, result, verdict.
5. **Answer feature questions empirically.** "Is it based on X or Y?" gets a
   table: every candidate feature scored on the same cache, single-feature
   and small-combination rows, fitted on train, scored on val.
6. **Know when you've hit the ceiling** (see `gt-validation`): if a
   physically privileged signal scores similarly, further optimization of
   the estimator is wasted effort — improve the data or the scope instead.

## Default workflow

1. Build/refresh the feature cache (include covariates: position, object id,
   magnitude, anything free).
2. Baseline table: all features × simple fits, train/val split.
3. Residual diagnosis → hypothesis → minimal implementation.
4. A/B on the same frames; accept only if held-out improves.
5. Update production pipeline + bump a PIPELINE_VERSION stamp so stale
   outputs rerun automatically.
6. Append the accepted AND rejected changes to the debug ledger.

## Anti-patterns

- Changing two things before measuring one.
- Evaluating on the fit set because "it's just one scalar".
- Deleting the numbers of failed attempts.
- Tuning to a pooled metric while a stratified confound explains it.
