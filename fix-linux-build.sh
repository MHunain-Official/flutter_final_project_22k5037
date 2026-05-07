#!/bin/bash

# Fix Flutter Linux Build — Linker Symlink Workaround
# This script creates necessary symlinks for Flutter Linux development

echo "🔧 Fixing Flutter Linux build environment..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Step 1: Create LLVM bin directory if it doesn't exist
if [ ! -d "/usr/lib/llvm-18/bin" ]; then
    echo "ℹ Creating /usr/lib/llvm-18/bin directory..."
    mkdir -p /usr/lib/llvm-18/bin
fi

# Step 2: Create symlinks for linker if not present
if [ ! -L "/usr/lib/llvm-18/bin/ld" ] && [ ! -f "/usr/lib/llvm-18/bin/ld" ]; then
    echo "✓ Linking ld..."
    sudo ln -s $(which ld) /usr/lib/llvm-18/bin/ld 2>/dev/null || \
    echo "⚠ Failed to create ld symlink (may require sudo password)"
fi

if [ ! -L "/usr/lib/llvm-18/bin/ld.lld" ] && [ ! -f "/usr/lib/llvm-18/bin/ld.lld" ]; then
    echo "✓ Creating ld.lld (fallback to ld)..."
    sudo ln -s $(which ld) /usr/lib/llvm-18/bin/ld.lld 2>/dev/null || \
    echo "⚠ Failed to create ld.lld symlink (may require sudo password)"
fi

# Step 3: Verify
echo ""
echo "Verifying linker availability..."
if [ -f "/usr/lib/llvm-18/bin/ld" ]; then
    echo "✓ /usr/lib/llvm-18/bin/ld found"
else
    echo "✗ /usr/lib/llvm-18/bin/ld not found"
fi

if [ -f "/usr/lib/llvm-18/bin/ld.lld" ]; then
    echo "✓ /usr/lib/llvm-18/bin/ld.lld found"
else
    echo "✗ /usr/lib/llvm-18/bin/ld.lld not found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Fix complete! Now trying flutter run..."
echo ""

# Step 4: Clean and run Flutter
cd "$(dirname "$0")"
flutter clean
flutter pub get
flutter run
