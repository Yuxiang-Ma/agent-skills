---
name: render-verify
description: This skill should be used when the user generates HTML pages, figures, or visual artifacts and needs to verify they actually render correctly — "check the page", "does it look right", or after any site/figure build before publishing.
---

# Render-Verify Loop

Never ship generated visual output you have not looked at. Text-level checks
(grep for a string) catch missing content; only a rendered screenshot
catches invisible content — overlapping curves, unreadable scales, broken
layout, fonts that didn't load.

## The loop

```bash
cd <site-dir>
(python3 -m http.server 8899 >/dev/null 2>&1 &)
sleep 1
google-chrome --headless --disable-gpu \
  --window-size=1100,2400 --hide-scrollbars \
  --virtual-time-budget=6000 \
  --screenshot=/tmp/render.png http://localhost:8899/page.html
kill %1
```

Then **look at the image** (multimodal read), judge, fix, re-render. Serve
over HTTP rather than `file://` so `fetch()`-driven scripts run.

## What screenshots catch that grep cannot

- Two curves at different magnitudes plotted on one axis → one invisible
  (fix: plot the difference/offset on its own scale).
- A 0.2 mm effect on a 100 mm axis → invisible band.
- Template placeholders rendered literally (`__VAR__`, `{name}`).
- CJK fallback fonts, clipped labels, legend covering data.
- Interactive JS silently failing (readout stuck at "–").

## Rules

1. Screenshot at desktop width AND once at ~375 px if the page is public.
2. For long pages, set window height to cover the section under change; for
   full-page checks use a tall window rather than scrolling stitches.
3. After publishing, verify the LIVE URL too: fetch it and assert key
   strings AND asset URLs return 200 — local success does not imply the
   deployment picked everything up.
4. Word-count pass for content pages: strip tags/scripts, count words; a
   page that doubled in words without new findings is duplicating.
5. Delete throwaway screenshots after judging; keep only ones that document
   a decision.
