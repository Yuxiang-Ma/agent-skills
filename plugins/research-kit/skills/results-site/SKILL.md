---
name: results-site
category: publishing
tags: [static-site, huggingface-space, evidence-first, reporting]
description: This skill should be used when the user asks to "make a results website", "publish results to a page/HF Space", "展示方法和效果", or wants research results presented online concisely but with every claim traceable to evidence.
---

# Evidence-First Results Site

Build a static results site (Hugging Face Space `sdk: static` or any static
host) where every sentence is backed by a number and every number by a
figure or table.

## Information architecture

Four page roles; do not mix them:

| page | role | word budget |
|---|---|---|
| index | executive summary — one figure + one paragraph per section, links out | ~800 words |
| method | how it is designed — pipeline, design decisions, optimization journey | one page |
| results | the method × dataset matrix — predicted-vs-GT scatter per dataset | figures-first |
| gallery | raw samples: panels and clips | captions only |

Rules:
- **One claim, one source.** Every quantitative sentence links to the figure/
  table that proves it.
- **Dataset quality controlled within rows.** On the results page, plot all
  methods per dataset side by side with shared axes — differences between
  panels are then method differences, not dataset differences.
- **Big tables collapse.** Per-item tables (>15 rows) go behind
  `<details><summary>` or a separate page; the summary line states n.
- **Keep the negative results and the debug ledger** — collapsed, not
  deleted. They are the credibility.
- Numbers are injected from the evaluation artifacts (JSON) at build time,
  never typed into HTML — stale prose is a build error waiting to be caught.

## Build mechanics (static, no framework)

- Generate pages from Python (or any script) with the page template in
  source control; a `publish` script uploads the folder
  (`huggingface_hub.upload_folder` for Spaces).
- Interactive elements: hand-rolled SVG + vanilla JS with real exported data
  beats a chart library for one bespoke chart; embed the data as a small
  JSON asset.
- For bilingual sites use the `bilingual-pages` skill.
- After every build: verify with the `render-verify` skill, then verify the
  LIVE deployment by fetching key strings from the published URL.

## Condensation pass (run before shipping)

1. Count words per page (strip tags/scripts). If index exceeds ~2× the
   method page, it is duplicating detail — move, don't summarize twice.
2. Every paragraph: can a figure caption carry it? Then delete the
   paragraph.
3. Every figure: does the title state the finding (not the axes)? Fix
   titles first, cut prose second.
