---
name: single-source-visual-consistency
category: design
description: This skill should be used when one physical or statistical quantity appears in multiple views of the same page or figure — a schematic, a zoomed inset, a readout, a simulated sensor image — and the user reports the views "don't match" or "look inconsistent". Establishes one source-of-truth function per quantity and a measured consistency chain.
---

# Single-Source Visual Consistency

When the same quantity is drawn twice, the two drawings WILL drift: one
gets clamped for layout, the other gets a display gamma "to look better",
and six weeks later a reviewer asks why the readout says 99 % while the
picture shows half. Every shared quantity gets exactly one law, one
function, consumed by every view — and a test that walks the chain.

## The pattern

1. Name the shared quantities explicitly. In a sensor-mechanism page:
   coupled-area fraction, device-scale contact width, camera patch size.
2. One exported function per quantity (`contactChordUnits(area)`), defined
   once at module scope. Every view calls it; no view re-implements or
   clamps it privately. A clamp one view needs is part of the law or it is
   a lie.
3. Displayed ink equals the reported number. If a view prints "57 %", the
   pixels must measure ≈ 57 % — count them in the test (canvas
   `getImageData`, classify by hue, exclude caption zones). A display gamma
   that makes ink exceed the number is the readout contradicting itself.
4. Rendering transforms must be provably neutral: any strictly increasing
   height map keeps an above-plane fraction bit-identical, so vertical
   exaggeration is safe — but document the argument next to the transform.
5. Chain test at several operating points (not just endpoints — mid-range
   is where laws forked): drawn A == law(x), drawn B == law(x) / field,
   readout == model(x), at x ∈ {mid, full}.

## Failure modes this catches (all from one real page)

- Two views "sharing" a law where one had a `min(92, …)` clamp: they agreed
  below 60 % pressure and silently diverged above it.
- A zoomed inset scaled to its own window's statistics, so the wide view
  and the inset implied different contact sizes (fix: the camera images the
  device scale; its patch is chord / field-of-view, not the micro fraction).
- A legibility standoff (constant 2.5 px air gap) that made the picture
  deny the model at high coupling — encode it as a sliding contract that
  closes as the quantity grows.
- Fencepost under-counting: summing run endpoint differences loses one
  sample-cell per run (~12 pp across a fragmented state); each sample owns
  one spacing-wide cell.

## Rules

1. Grep for the law's magic numbers before claiming consistency; a second
   `14 + sqrt(x) * 104` anywhere is a fork.
2. Constants a test needs (field-of-view span) live at module scope so
   `page.evaluate` reads the page's value instead of hard-coding a copy.
3. Record accepted approximations (a genuine 1-D slice has a variance
   floor vs its 2-D field) in a PARAMS.md — deliberate gaps documented,
   accidental gaps asserted away.
