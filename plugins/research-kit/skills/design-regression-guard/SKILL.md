---
name: design-regression-guard
category: design
tags: [visual-regression, assertion, design-qa]
description: This skill should be used after fixing any visual, layout, accessibility, or content defect on a website — turn each fixed defect class into an automated assertion so it cannot silently return. Use when the user says "make sure this doesn't break again", after a design-review round, or when building a check suite for a static site.
---

# Design Regression Guard

Every defect class you fix by hand will return unless a machine re-checks
it. The reason a site accumulates 17 font sizes and a hundred contrast
failures is that its test suite asserted none of them. Fix → freeze, in the
same commit.

## The pattern

Add a `design` mode to the site's Playwright check script, covering every
route × a viewport matrix (375/768/1280/1920 — bugs live at the widths the
old suite skipped). Assert, per page:

- zero text nodes below WCAG AA against composited backgrounds
- zero interactive elements under 44 px on phone/tablet
- distinct rendered font sizes ≤ a per-route ceiling (ratchet it down)
- zero page-level horizontal overflow
- media keeps its aspect ratio (letterbox/stretch detection) and canvas
  backing stores track devicePixelRatio (softness detection)

For data-driven graphics, assert the **semantic contract**, not pixels:
"the drawn fraction equals the reported percentage ± 3 pp", "view A's width
law equals view B's". Read the page's own model functions via
`page.evaluate` so the test and the page share one source of truth.

## Starter assertion (semantic contract for a data graphic)

```python
# The drawn ink must match the number the page prints beside it.
amber = page.evaluate("""() => {
  const c = document.querySelector('#field-canvas');
  const d = c.getContext('2d').getImageData(0, 0, c.width, c.height).data;
  let ink = 0, total = 0;
  for (let i = 0; i < d.length; i += 4) {
    if (d[i+3] < 200) continue;                  // skip transparent
    total += 1;
    if (d[i] - d[i+2] > 90) ink += 1;            // hue classifier
  }
  return ink / Math.max(total, 1);
}""")
reported = page.evaluate("modelCoupledFraction()")   # the page's own model
assert abs(amber - reported) < 0.03, (
    f"drawn {amber:.1%} vs reported {reported:.1%}")
```

## Why in the same commit

From a real session, the guard caught its own author twice within hours:

- a footer link added during the very round that introduced the touch-target
  rule shipped at 14 px tall — the new check failed it before commit;
- a phone-width word-break fix silently clipped the same word on desktop —
  the aspect/overflow guard caught it in the final sweep.

Human review missed both. That is the argument: the guard's first victims
are your own fixes.

## Rules

1. One assertion per defect CLASS, not per instance; parameterize by route.
2. Encode sliding contracts honestly: if a legibility gap may close as a
   physical quantity grows, assert `floor = f(quantity)`, not a constant
   the physics will violate.
3. When a guard blocks a legitimate change, update the guard's bound in the
   same commit with one sentence on why the old bound guarded a
   since-removed behavior.
4. Keep exploratory (verbose report) and gating (pass/fail) versions of the
   same measurements as separate scripts; the report finds, the gate keeps.
