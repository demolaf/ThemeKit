#!/usr/bin/env bash
#
# Fails if CHANGELOG.md has no "## [<tag>]" entry for the given tag -- catches
# a tag shipped with no changelog section at all (a real gap: 0.2.2 shipped
# with no entry until this was caught by hand).
#
# Also does a soft, non-fatal check: do the inline-code symbols mentioned in
# that entry actually appear somewhere in the tag's diff? This is intentionally
# a warning, not a failure -- unlike Scripts/check_doc_samples.swift, there's
# no way to compile prose, and a symbol can legitimately be described without
# being part of the diff (e.g. referencing an unrelated existing API).
#
# Usage: Scripts/check_changelog_entry.sh [<tag>]
#   <tag> defaults to the most recent tag reachable from HEAD.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGELOG="$REPO_ROOT/CHANGELOG.md"

TAG="${1:-$(git -C "$REPO_ROOT" describe --tags --abbrev=0)}"
PREV_TAG="$(git -C "$REPO_ROOT" describe --tags --abbrev=0 "${TAG}^" 2>/dev/null || true)"

echo "Checking CHANGELOG.md for tag: $TAG"

if ! grep -qE "^## \[${TAG}\]" "$CHANGELOG"; then
    echo "Error: CHANGELOG.md has no '## [$TAG]' entry." >&2
    exit 1
fi
echo "  found heading for $TAG"

SECTION="$(awk "/^## \[${TAG}\]/{flag=1; next} /^## \[/{flag=0} flag" "$CHANGELOG")"
SYMBOLS="$(grep -oE '`[A-Za-z_][A-Za-z0-9_.<>:-]*`' <<< "$SECTION" | tr -d '`' | sort -u || true)"

if [ -n "$PREV_TAG" ] && [ -n "$SYMBOLS" ]; then
    DIFF="$(git -C "$REPO_ROOT" diff "$PREV_TAG" "$TAG")"
    MISSING=""
    while IFS= read -r symbol; do
        [ -z "$symbol" ] && continue
        if ! grep -qF -- "$symbol" <<< "$DIFF"; then
            MISSING="$MISSING $symbol"
        fi
    done <<< "$SYMBOLS"
    if [ -n "$MISSING" ]; then
        echo "Warning: symbols in the $TAG changelog entry not found in 'git diff $PREV_TAG $TAG':"
        echo "  $MISSING"
        echo "(non-fatal -- may be legitimate prose, but worth a second look)"
    fi
else
    echo "  (no previous tag or no inline-code symbols to cross-check)"
fi

echo "CHANGELOG check passed for $TAG."
