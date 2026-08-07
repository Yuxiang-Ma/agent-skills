# agent-skills

Portable skills for coding agents, distilled from real research-engineering
sessions — not aspirational checklists. Each skill exists because skipping it
cost hours at least once.

**research-kit** (13 skills, by category):

### dataset — building and maintaining data releases

| skill | one line |
|---|---|
| `dataset-release-integrity` | a dataset card is a claim nobody checks: test declared configs/splits/schema against the parquet, prove a schema fix by running the card's own example, and never rewrite published bytes in place |
| `release-parity-refactor` | refactoring code whose output already shipped: the artifact is the spec, find the real producer by output fingerprint, grade sources by whether a proof is possible, never tune a parameter to make the check pass |

### research — validating methods without fooling yourself

| skill | one line |
|---|---|
| `evidence-driven-optimization` | feature-cache workbench; every change motivated by a measured defect and verified A/B on held-out data; rejected variants kept |
| `gt-validation` | validate estimators against ground truth without fooling yourself (non-circular splits, ceilings, stratification, method × dataset matrices) |

### debug — investigation discipline and trustworthy verification

| skill | one line |
|---|---|
| `debug-ledger` | found→fix ledger + plan-file discipline; negative results are deliverables |
| `in-page-model-probe` | probe a page's embedded JS model via page.evaluate: parameter sweeps, monotonicity, model-vs-render reconciliation |
| `render-verify` | headless-render screenshot loop for generated HTML/figures; what grep can't catch, a screenshot does |
| `verification-that-can-fail` | a check you have never seen fail is not evidence: red-green every regression, mutation-test the suite, guard the parser, and make sure the criterion could express the failure you care about |

### publishing — shipping results others can check

| skill | one line |
|---|---|
| `bilingual-pages` | translated pages as asserted derivations of the source — desync fails the build instead of shipping stale text |
| `results-site` | evidence-first static results sites (HF Space): four page roles, one-claim-one-source, collapse big tables, numbers injected at build time |

### design — web/design work verified by measurement

| skill | one line |
|---|---|
| `design-regression-guard` | every fixed visual defect class becomes an assertion in the same commit; the guard's first victims are your own fixes |
| `measured-design-audit` | design review by measurement: computed WCAG contrast, 44px touch targets, font-size census, multi-viewport overflow — fixes solved numerically, not nudged |
| `single-source-visual-consistency` | one law per shared quantity across schematic, inset, readout and sensor views; a chain test walks model → ink → number |

## Install

### Claude Code — as a plugin (recommended)

```
/plugin marketplace add Yuxiang-Ma/agent-skills
/plugin install research-kit@yuxiang-agent-skills
```

### Any project — copy just what you want

```bash
git clone https://github.com/Yuxiang-Ma/agent-skills
cd agent-skills
./install.sh --list                          # name + category
./install.sh --categories                   # dataset, research, debug, ...
./install.sh --project ~/myrepo --skills gt-validation,render-verify
./install.sh --project ~/myrepo --category dataset,debug
./install.sh --project ~/myrepo --remove render-verify
./install.sh --global                       # ~/.claude/skills for every project
```

Skills land in `<project>/.claude/skills/<name>/SKILL.md` — Claude Code picks
them up automatically; the standard SKILL.md format (YAML frontmatter with a
trigger `description` + markdown body) is also readable by other
skill-aware agents.

### Agents that only read AGENTS.md (Codex-style)

```bash
./install.sh --project ~/myrepo --agents-md
```

Appends the selected skills into an auto-managed block in `AGENTS.md`
(idempotent — re-running replaces the block).

## Add / modify / remove skills

- One skill = one directory = one `SKILL.md`. Add a directory under
  `plugins/research-kit/skills/`, push, re-run `install.sh` in consuming
  projects (or `/plugin update`).
- Keep `SKILL.md` lean: trigger description in frontmatter, rules +
  workflow in the body, long material in `references/` (only if real files
  exist).
- Per-project overrides: after installing, edit the copy in
  `<project>/.claude/skills/` freely — installs are copies, not symlinks,
  precisely so projects can diverge.

## Companion collections

Broader third-party skills (documents, D3 visualizations, design systems,
browser automation): [awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills).

## Provenance

Distilled from a long React-dataset force-recovery session (GT validation
across FEATS/FoTa/GlowTact, evidence-driven optimization ρ 0.34→0.65, a
bilingual HF results site, and a 10-row debug ledger). The rules encode what
actually failed, not what sounds rigorous.

License: MIT
