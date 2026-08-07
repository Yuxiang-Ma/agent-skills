---
name: in-page-model-probe
category: debug
description: This skill should be used when a web page embeds a numerical or physical model in client-side JavaScript (a simulation, an interactive figure, a parameter-driven visualization) and its behavior needs to be verified or tuned — sweep parameters, check monotonicity, and reconcile model vs render without touching the UI.
---

# In-Page Model Probe

An interactive figure is a model plus a renderer. Testing it by dragging
the slider and squinting conflates the two. Probe the model directly in
page scope: real browser, real code, numeric output — then tune constants
against measurements instead of adjectives.

## The pattern

Classic scripts (`<script src>` without `type="module"`) expose top-level
`function` and `const` declarations to `page.evaluate` as bare
identifiers. Serve the site, load the page once, then evaluate an IIFE
that sweeps the model:

```python
rows = page.evaluate("""
(() => {
  const out = [];
  for (let i = 0; i <= 20; i += 1) {
    const p = i / 20;
    const m = modelFor(p);          // the page's own function
    out.push({ p, area: m.area, signal: m.coupling });
  }
  return out;
})()""")
```

Print a table; assert monotonicity, endpoint targets, and cross-view
agreement per row. For ES modules, attach the needed functions to
`window` behind a debug flag instead.

## Tune by sweep, not by nudge

Candidate constants get measured curves, not one-at-a-time guesses. A real
example: sweeping an "intimacy depth" across 0.055–0.22 showed the curve's
half-load shape was IDENTICAL at every value — the constant was a pure
gain, so the debate about its "right" value was empty and the low end
(max saturation) won by construction. One sweep replaced four
adjust-and-ask rounds.

For render-side constants, measure the render: screenshot the element,
count classified pixels (dark fraction, hue fraction) per candidate value,
pick the value whose measurement matches the model. Beware threshold
metrics on mid-range states — a luminance cutoff sits on the fence exactly
where the physics is half-strength; measure footprint (geometry) and
intensity (grey level) separately.

## Rules

1. Evaluate IIFE strings, not arrow-function args — Playwright's function
   wrapping can lose the classic-script global scope.
2. One fresh port per probe script; a stale server on a reused port serves
   the wrong tree and produces "identifier not defined" ghosts.
3. Distinguish diagnostic quantities from displayed ones: an aggregate can
   be legitimately non-monotone (new shallow contact dilutes a mean) while
   the displayed quantity must stay monotone — assert the right one.
4. Keep the probe in the repo (`tools/probe_model.py`); it documents how
   every constant was chosen and re-arms the next tuning session.
