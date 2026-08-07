#!/usr/bin/env bash
# Deploy selected skills into a project (or globally), for Claude Code and
# other coding agents. Copy-based, idempotent, easy to add/remove.
#
#   ./install.sh --list
#   ./install.sh --project ~/myrepo                      # all skills -> .claude/skills/
#   ./install.sh --project ~/myrepo --skills gt-validation,render-verify
#   ./install.sh --project ~/myrepo --category dataset,debug
#   ./install.sh --global                                # -> ~/.claude/skills/
#   ./install.sh --project ~/myrepo --remove results-site
#   ./install.sh --project ~/myrepo --agents-md          # also append to AGENTS.md
#                                                        # (for agents that only read AGENTS.md)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/plugins/research-kit/skills"

usage() { grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

TARGET="" SKILLS="" REMOVE="" AGENTS_MD=0 CATEGORIES=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --list)
      for d in "$SRC"/*/; do
        n="$(basename "$d")"
        c="$(sed -n 's/^category: //p' "$d/SKILL.md" | head -1)"
        printf "%-34s %s\n" "$n" "${c:-uncategorised}"
      done | sort -k2,2 -k1,1
      exit 0 ;;
    --categories)
      for d in "$SRC"/*/; do sed -n 's/^category: //p' "$d/SKILL.md" | head -1; done \
        | sort -u
      exit 0 ;;
    --category) CATEGORIES="$2"; shift 2 ;;
    --project) TARGET="$2/.claude/skills"; ROOT="$2"; shift 2 ;;
    --global)  TARGET="$HOME/.claude/skills"; ROOT="$HOME"; shift ;;
    --skills)  SKILLS="$2"; shift 2 ;;
    --remove)  REMOVE="$2"; shift 2 ;;
    --agents-md) AGENTS_MD=1; shift ;;
    *) usage ;;
  esac
done
[[ -z "$TARGET" ]] && usage

if [[ -n "$REMOVE" ]]; then
  for s in ${REMOVE//,/ }; do
    rm -rf "$TARGET/$s" && echo "removed $s from $TARGET"
  done
  exit 0
fi

mkdir -p "$TARGET"
# --category selects by the `category:` field in each SKILL.md front-matter.
# Skills stay in ONE flat directory: Claude Code discovers
# .claude/skills/<name>/SKILL.md, and a nesting level would break both that and
# plugin loading. Categories are metadata, not layout.
if [[ -n "$CATEGORIES" ]]; then
  sel=""
  for d in "$SRC"/*/; do
    n="$(basename "$d")"
    c="$(sed -n 's/^category: //p' "$d/SKILL.md" | head -1)"
    for want in ${CATEGORIES//,/ }; do
      [[ "$c" == "$want" ]] && sel="$sel$n,"
    done
  done
  [[ -z "$sel" ]] && { echo "no skills in category: $CATEGORIES" >&2; exit 1; }
  SKILLS="$sel"
fi
if [[ -z "$SKILLS" ]]; then SKILLS="$(ls "$SRC" | tr '\n' ',' )"; fi
for s in ${SKILLS//,/ }; do
  s="$(echo "$s" | xargs)"; [[ -z "$s" ]] && continue
  [[ -d "$SRC/$s" ]] || { echo "unknown skill: $s (see --list)"; exit 1; }
  rm -rf "$TARGET/$s"
  cp -r "$SRC/$s" "$TARGET/$s"
  echo "installed $s -> $TARGET/$s"
done

if [[ "$AGENTS_MD" == 1 ]]; then
  MD="$ROOT/AGENTS.md"
  # Replace (or append) a managed block so re-runs stay idempotent
  START="<!-- agent-skills:research-kit start -->"
  END="<!-- agent-skills:research-kit end -->"
  TMP="$(mktemp)"
  if [[ -f "$MD" ]]; then
    awk -v s="$START" -v e="$END" '$0==s{skip=1} !skip{print} $0==e{skip=0}' "$MD" > "$TMP"
  fi
  {
    echo "$START"
    echo "## Research-kit skills (auto-managed; edit via install.sh)"
    for s in ${SKILLS//,/ }; do
      s="$(echo "$s" | xargs)"; [[ -z "$s" ]] && continue
      echo; echo "### skill: $s"
      # strip frontmatter
      awk 'f{print} /^---$/{c++; if(c==2) f=1}' "$SRC/$s/SKILL.md"
    done
    echo "$END"
  } >> "$TMP"
  mv "$TMP" "$MD"
  echo "updated $MD (managed block)"
fi
