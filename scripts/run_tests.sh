#!/usr/bin/env bash
# TrackOS test agent — runs after every file edit via Claude Code PostToolUse hook.
# Tests only TrackOSCore (Foundation-only) so they compile without a simulator.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  TrackOS Test Agent"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Require Swift ────────────────────────────────────────────────────────────
if ! command -v swift &>/dev/null; then
    echo ""
    echo "⚠️  Swift toolchain not found."
    echo "   Install Xcode (macOS) or the Swift toolchain to enable test runs."
    echo "   Skipping tests."
    echo ""
    exit 0
fi

SWIFT_VER=$(swift --version 2>&1 | head -1)
echo "   $SWIFT_VER"
echo ""

cd "$PROJECT_ROOT"

# ── Build TrackOSCore (catches compile errors fast) ──────────────────────────
echo "▶  Building TrackOSCore…"
if ! swift build --target TrackOSCore 2>&1; then
    echo ""
    echo "❌ Build failed — fix compile errors before running tests."
    exit 1
fi

# ── Run unit tests ───────────────────────────────────────────────────────────
echo ""
echo "▶  Running TrackOSTests…"
echo ""

if swift test --filter TrackOSTests 2>&1; then
    echo ""
    echo "✅ All tests passed."
else
    RESULT=$?
    echo ""
    echo "❌ Tests failed (exit $RESULT)."
    exit $RESULT
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
