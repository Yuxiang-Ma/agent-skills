---
name: bilingual-pages
category: publishing
description: This skill should be used when the user asks to "add a Chinese version", "make the page bilingual", "增加中文版", or needs to maintain translated variants of generated HTML/docs without them silently drifting apart.
---

# Bilingual Pages Without Drift

Maintain a translated page as a **derivation** of the source page, not a
copy — so that any source edit that would desynchronize the translation
fails the build instead of shipping stale text.

## The pattern

1. Build the source-language page first (from its template).
2. Derive the translation with an ordered list of exact replacements:

```python
ZH = [(exact_source_string, translated_string), ...]

def build_zh():
    html = build_en()
    for old, new in ZH:
        assert old in html, f"ZH replacement missed: {old[:60]!r}"
        html = html.replace(old, new, 1)
    return html
```

3. The `assert` is the point: edit the English template and forget the
   Chinese pair → the build fails loudly with the missing string.

## Rules

- Replace whole semantic units (a paragraph, a heading, a table row), not
  words — word-level pairs break on rewording.
- Keep technical tokens (identifiers, units, dataset names, numbers) in the
  source language inside translated text.
- Localize JS-embedded UI strings too (status labels, tooltips).
- Typography per language: pair fonts explicitly (e.g. serif display +
  CJK serif like Noto Serif SC; body + Noto Sans SC), and widen line-height
  for CJK (~1.7).
- Language toggle links on both pages, translated nav targets (`page.html`
  ↔ `page_zh.html`).

## Maintenance

- When restructuring the source template, prune dead pairs
  programmatically: rebuild source, keep pairs whose `old` still matches,
  list the dropped ones, add pairs for new content.
- **Scope string surgery to the template region.** A whole-file
  `.replace()` will also hit the same substring inside the translation-pair
  list and corrupt string literals (a real failure mode: a replacement
  containing a newline inside a single-quoted literal → SyntaxError). Slice
  the template span first, edit, splice back.
