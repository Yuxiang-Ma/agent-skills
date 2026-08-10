---
name: verification-that-can-fail
category: debug
tags: [mutation-testing, red-green, test-quality, false-pass, evidence]
description: This skill should be used whenever you are about to trust a green check — a passing test suite, a regression harness, a comparison script, an eval — and especially before claiming work is done. Use it when the user asks "is this actually working?", "validate our results", or when a verification passes on the first try.
---

# Verification That Can Fail

A check you have never seen fail is not evidence. Most bad verifications do not
report failure — they report success, on a criterion that could not have
distinguished the outcomes you care about.

Across one long refactor, defects in the *verification* outnumbered defects in
the *code under test* by roughly six to one. Every one surfaced as green.

## Core rules

1. **Confirm the criterion can discriminate.** Before believing a passing
   comparison, ask what a failure would have looked like and whether the
   statistic could express it. Comparing kept-row *sets* was meaningless where
   the join key was non-unique: 166,104 rows collapsed to 31,096 keys, so
   matching the key set was equally consistent with emitting either count.
   Check uniqueness, cardinality, or variance of the quantity you compare.

2. **Watch for thresholds that are trivially satisfiable.** "Difference ≤ the
   observed maximum" clears almost anything when the spread is wide. Report
   *where* a result falls in the reference distribution — below its floor,
   inside it, above its ceiling — so a marginal pass cannot read as a strong
   one.

3. **Red-green every regression test.** Write it, watch it pass, then
   reintroduce the exact defect and watch it fail, then restore. A test added
   after a fix has never demonstrated it can detect anything.

4. **Mutation-test the suite on the logic that matters.** Inject real defects
   into the load-bearing functions — invert a comparison, drop a column from a
   schema, replace a masked mean with an unmasked one, "correct" a deliberately
   odd expression — and confirm the suite goes red for each. Uncaught mutations
   name the exact coverage you lack.

5. **Guard the guard.** Any check built on parsing (a regex over a doc, a
   glob over a directory, a scrape of a report) must first assert it matched
   something. When the format changes, the parser silently matches nothing and
   every dependent assertion passes vacuously.

6. **Evidence must postdate the code it validates.** After changing a shared
   function, previously-recorded results no longer apply, however
   behaviour-preserving the change looked. Two sources' "exact match" evidence
   predated an optimisation of the filter they depend on; a bit-identity unit
   test on random arrays existed, but it is not an end-to-end result on real
   data. Check the ordering mechanically (`git log` on the dependency versus
   when the result was produced), not by memory.

7. **A failing exit code is not a failing test.** A run that died of a full
   disk, an OOM, or a lost output file tells you nothing about the thing under
   test. Read the actual output before diagnosing; treating an environment
   failure as a product failure sends you hunting a bug that does not exist
   while the real problem stays unfixed.

8. **Name what a pass actually establishes.** Not every verification is the
   same strength. Distinguish exact row-level equality from set equality on a
   non-unique key, and both from "consistent with an unrecoverable random
   seed". An unqualified PASS spanning a mixture of these voids whatever
   grading scheme you built.

## Tests that look like coverage but are not

- **A test named for a case its fixture never produces.** One asserting
  "difference falls inside the spread" was built with numbers that put it
  *below* the floor — green forever, and it never exercised its own name.
  When a test passes immediately, verify the fixture reaches the intended
  regime before moving on.
- **An empty parametrisation.** Removing the last entry from the list driving
  `@parametrize` leaves a test that skips silently and still reads as a test.
- **A unit test standing in for an integration path.** Six tests covering a
  function's pure logic passed while the CLI wrapping it could not complete a
  single real invocation, because the registry it needed was populated only in
  a subprocess.
- **A verifier that shares code with the thing it verifies.** It will agree
  with a shared bug. Re-check with an independent implementation.

## Before claiming completion

Run the command, read the output, count the failures — in this message, not
from memory of an earlier run. Then state the claim *with* the evidence
attached. "Should pass", "the agent reported success", and "it passed earlier"
are not verification, and the delta between them and a fresh run is exactly
where this skill earns its cost.
