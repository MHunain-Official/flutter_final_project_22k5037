#!/bin/bash

# Smart Travel Companion — Android Emulator Start Script
# Starts PostgreSQL, Redis, Node.js backend, and Flutter on Android emulator

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📱 Smart Travel Companion — Android Emulator Setup..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─────────────────────────────────────────────────────
# 1. Check PostgreSQL
# ─────────────────────────────────────────────────────
echo "✓ Checking PostgreSQL..."
if ! pg_isready -h 127.0.0.1 -p 5432 > /dev/null 2>&1; then
  echo "⚠ PostgreSQL is not running. Please start PostgreSQL first."
  exit 1
fi
echo "  ✓ PostgreSQL ready at 127.0.0.1:5432"

# ─────────────────────────────────────────────────────
# 2. Check Redis
# ─────────────────────────────────────────────────────
echo "✓ Checking Redis..."
if ! redis-cli ping > /dev/null 2>&1; then
  echo "⚠ Redis is not running. Please start Redis first."
  exit 1
fi
echo "  ✓ Redis ready at 127.0.0.1:6379"

# ─────────────────────────────────────────────────────
# 3. Start Node.js Backend Server
# ─────────────────────────────────────────────────────
echo "✓ Starting Node.js backend server..."
cd "$PROJECT_DIR/server"
if ! command -v node &> /dev/null; then
  echo "✗ Node.js not found."
  exit 1
fi
node server.js > server.log 2>&1 &
SERVER_PID=$!
sleep 3

if ! curl -s http://localhost:3000/health > /dev/null; then
  echo "✗ Backend failed to start"
  kill $SERVER_PID 2>/dev/null || true
  exit 1
fi
echo "  ✓ Backend running at http://localhost:3000 (PID: $SERVER_PID)"

# ─────────────────────────────────────────────────────
# 4. Check for Android Emulator
# ─────────────────────────────────────────────────────
echo "✓ Checking for Android devices..."
cd "$PROJECT_DIR"

if ! command -v flutter &> /dev/null; then
  echo "✗ Flutter not found."
  kill $SERVER_PID 2>/dev/null || true
  exit 1
fi

# Check for connected devices
DEVICES=$(flutter devices 2>/dev/null | grep -i "android\|physical" || true)
if [ -z "$DEVICES" ]; then
  echo "⚠ No Android devices found. Launch an emulator:"
  echo "  flutter emulators --launch Pixel_5_API_30"
  echo "  (or connect a physical device)"
  kill $SERVER_PID 2>/dev/null || true
  exit 1
fi

echo "  ✓ Android device(s) detected:"
echo "$DEVICES" | head -3

# ─────────────────────────────────────────────────────
# 5. Start Flutter App
# ─────────────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ All services ready! Launching the app..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

flutter run

# Cleanup on exit
cleanup() {
  echo ""
  echo "🛑 Shutting down backend..."
  if kill -0 $SERVER_PID 2>/dev/null; then
    kill $SERVER_PID
    echo "  ✓ Stopped"
  fi
}

trap cleanup EXIT INT
