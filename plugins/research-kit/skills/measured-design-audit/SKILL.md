---
name: measured-design-audit
description: This skill should be used when the user asks to review, improve, or "beautify" a website's design, layout, colors, fonts, or accessibility. Replaces eyeballing with measurement — computed contrast, touch targets, font-size census, multi-viewport overflow — so every fix is provable and every claim has a number.
---

# Measured Design Audit

Never judge a page by looking at one screenshot. Measure every text node,
every interactive element, at every breakpoint — then fix only what the
numbers convict. In one real session this found 133 WCAG failures and
seventeen distinct font sizes that three prior visual reviews had missed.

## The audit battery (Playwright, one page.evaluate per route × viewport)

Run at 375 / 768 / 1280 / 1920 minimum. Collect in a single DOM walk:

- **Contrast**: for each text node, composite its `color` over the first
  ancestor with `background-color` alpha > 0.85; compute the WCAG ratio;
  flag < 4.5 (< 3.0 for ≥ 24 px or bold ≥ 18.66 px). Composited background,
  not declared background — semi-transparent inks lie.
- **Touch targets**: any `a/button/input/select` under 44 px in either
  dimension at phone/tablet widths. Include focus-revealed elements
  (skip links measure too).
- **Type census**: distinct rendered `font-size` values per page and the
  `font-family` histogram. More than ~7 sizes, or 1 px neighbours
  (17.9 / 18), is sprawl, not hierarchy.
- **Overflow**: `scrollWidth − clientWidth` at document level, plus any
  element whose rect exits the viewport (whitelist off-screen skip links).

## Fix by solving, not nudging

- Contrast: numerically solve the minimum color shift that reaches 4.5:1
  (scale toward black/white in steps, stop at the first passing value).
  Never hand-pick "a bit darker".
- Watch for **polarity bugs**: a muted token tuned for light backgrounds
  reused on a dark inverted panel gets WORSE when you darken it. Inverted
  states (hover/selected tabs) need their nested children inverted too.
- Type: snap to a declared scale (e.g. micro/label/body/lead/h3/h2/display
  as CSS variables); keep fluid `clamp()` headings, but check the clamp's
  rendered value at each breakpoint — a 17px floor renders 17.92 at 1280
  and sits 0.1 px off your 18px step.
- Spacing and letter-spacing: same treatment — census, then snap to a
  3–4 step scale. 0.01em differences carry no intent.

## Rules

1. Audit BEFORE and AFTER; report deltas (failures 133 → 0), not vibes.
2. A long word that must fit a narrow box has no static font-size answer
   if the box doesn't track the viewport linearly — use a soft hyphen
   (`Omni&shy;directional`) and let it break only when genuinely needed.
   `overflow-wrap: anywhere` licenses garbage breaks; never use it on
   headings.
3. Measure the box the text actually gets, not the column: a heading
   sharing its card with a glyph may own 180 px of a 405 px column.
4. Once a class of defect is fixed, freeze it as a regression test
   (see `design-regression-guard`).
