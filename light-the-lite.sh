#!/usr/bin/env bash
# light-the-lite.sh — copy The Forge Lite skeleton into a target project.
#
# Usage:
#   ./light-the-lite.sh                 # install into current working dir
#   ./light-the-lite.sh <target-dir>    # install into the named dir
#
# What it copies:
#   .claude/skills/         — all skills (the five phases + grill-me + diagnose)
#   .claude/plans/{active,done}/ — empty plan dirs (with .gitkeep)
#   .claude/settings.json   — starter allowlist (only if missing in target)
#   templates/CLAUDE.md     → target/CLAUDE.md  (only if missing)
#   templates/CONTEXT.md    → target/CONTEXT.md (only if missing)
#   templates/README.md     → target/README.md  (only if missing)
#
# Refuses if target already has .claude/plans/ (Lite is already installed).

set -euo pipefail

# ─── resolve source root from $0 ─────────────────────────────────────────────
SCRIPT_PATH="${BASH_SOURCE[0]}"
# Resolve symlinks
while [[ -L "$SCRIPT_PATH" ]]; do
  SCRIPT_DIR="$(cd -P "$(dirname "$SCRIPT_PATH")" && pwd)"
  SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
  [[ "$SCRIPT_PATH" != /* ]] && SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_PATH"
done
SRC="$(cd -P "$(dirname "$SCRIPT_PATH")" && pwd)"

# ─── resolve target ──────────────────────────────────────────────────────────
TARGET="${1:-$(pwd)}"
if [[ ! -d "$TARGET" ]]; then
  echo "✗ Target directory does not exist: $TARGET" >&2
  exit 1
fi
TARGET="$(cd -P "$TARGET" && pwd)"

# ─── color helpers ──────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  GREEN=$'\033[32m'
  YELLOW=$'\033[33m'
  RED=$'\033[31m'
  BOLD=$'\033[1m'
  DIM=$'\033[2m'
  N=$'\033[0m'
else
  GREEN='' YELLOW='' RED='' BOLD='' DIM='' N=''
fi

green()  { printf '%s%s%s\n' "$GREEN" "$*" "$N"; }
yellow() { printf '%s%s%s\n' "$YELLOW" "$*" "$N" >&2; }
red()    { printf '%s%s%s\n' "$RED" "$*" "$N" >&2; }
bold()   { printf '%s%s%s\n' "$BOLD" "$*" "$N"; }

# ─── preflight ───────────────────────────────────────────────────────────────
if [[ "$SRC" == "$TARGET" ]]; then
  red "✗ Source and target are the same directory ($SRC)."
  echo "  Run light-the-lite.sh from outside the Lite repo, or pass a different target." >&2
  exit 1
fi

if [[ -d "$TARGET/.claude/plans" ]]; then
  red "✗ Target already has .claude/plans/ — Lite appears to be installed."
  echo "  Path: $TARGET/.claude/plans" >&2
  echo "  Remove it (or its parent) manually to re-install." >&2
  exit 1
fi

# ─── copy skills ─────────────────────────────────────────────────────────────
bold "Installing The Forge Lite into:"
printf '  %s\n\n' "$TARGET"

if [[ ! -d "$SRC/.claude/skills" ]]; then
  red "✗ Source missing .claude/skills/ — is this actually the Lite repo? ($SRC)"
  exit 1
fi

mkdir -p "$TARGET/.claude/skills"
cp -R "$SRC/.claude/skills/." "$TARGET/.claude/skills/"
skill_count="$(find "$TARGET/.claude/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
green "  ✓ Copied .claude/skills/ ($skill_count skills)"

# ─── copy knowledge (if present in source) ───────────────────────────────────
if [[ -d "$SRC/.claude/knowledge" ]]; then
  mkdir -p "$TARGET/.claude/knowledge"
  cp -R "$SRC/.claude/knowledge/." "$TARGET/.claude/knowledge/"
  green "  ✓ Copied .claude/knowledge/"
fi

# ─── scaffold plans/{active,done} ────────────────────────────────────────────
mkdir -p "$TARGET/.claude/plans/active" "$TARGET/.claude/plans/done"

# Preserve any READMEs that exist in source
for sub in active done; do
  if [[ -f "$SRC/.claude/plans/$sub/README.md" ]]; then
    cp "$SRC/.claude/plans/$sub/README.md" "$TARGET/.claude/plans/$sub/README.md"
  fi
  # .gitkeep so empty dirs survive `git add`
  : > "$TARGET/.claude/plans/$sub/.gitkeep"
done

if [[ -f "$SRC/.claude/plans/README.md" ]]; then
  cp "$SRC/.claude/plans/README.md" "$TARGET/.claude/plans/README.md"
fi

green "  ✓ Scaffolded .claude/plans/{active,done}/"

# ─── copy settings.json (only if missing) ────────────────────────────────────
if [[ -f "$SRC/.claude/settings.json" ]]; then
  if [[ ! -f "$TARGET/.claude/settings.json" ]]; then
    cp "$SRC/.claude/settings.json" "$TARGET/.claude/settings.json"
    green "  ✓ Copied .claude/settings.json"
  else
    yellow "  ! .claude/settings.json already exists in target — left alone"
  fi
fi

# ─── copy root templates (only if missing in target) ─────────────────────────
copied_templates=()
skipped_templates=()
for f in CLAUDE.md CONTEXT.md README.md; do
  if [[ -f "$SRC/templates/$f" ]]; then
    if [[ ! -f "$TARGET/$f" ]]; then
      cp "$SRC/templates/$f" "$TARGET/$f"
      copied_templates+=("$f")
    else
      skipped_templates+=("$f")
    fi
  fi
done

if [[ "${#copied_templates[@]}" -gt 0 ]]; then
  green "  ✓ Copied templates: ${copied_templates[*]}"
fi
if [[ "${#skipped_templates[@]}" -gt 0 ]]; then
  yellow "  ! Left untouched (already present): ${skipped_templates[*]}"
fi

# ─── summary ─────────────────────────────────────────────────────────────────
echo
bold "Done."
echo
printf '%s%s%s\n' "$DIM" "  Target:        $TARGET" "$N"
printf '%s%s%s\n' "$DIM" "  Plans live in: $TARGET/.claude/plans/active/" "$N"
echo
echo "  Next: /ponder"
echo
