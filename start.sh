#!/bin/bash

# Smart Travel Companion — START SCRIPT
# Starts PostgreSQL, Redis, Node.js backend, and Flutter app

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📱 Smart Travel Companion — Starting all services..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─────────────────────────────────────────────────────
# 1. Check PostgreSQL
# ─────────────────────────────────────────────────────
echo "✓ Checking PostgreSQL..."
if ! pg_isready -h 127.0.0.1 -p 5432 > /dev/null 2>&1; then
  echo "⚠ PostgreSQL is not running. Please start PostgreSQL:"
  echo "  sudo systemctl start postgresql  (or brew services start postgresql on macOS)"
  exit 1
fi
echo "  ✓ PostgreSQL running on 127.0.0.1:5432"

# ─────────────────────────────────────────────────────
# 2. Check Redis
# ─────────────────────────────────────────────────────
echo "✓ Checking Redis..."
if ! redis-cli ping > /dev/null 2>&1; then
  echo "⚠ Redis is not running. Please start Redis:"
  echo "  redis-server  (or brew services start redis on macOS)"
  exit 1
fi
echo "  ✓ Redis running on 127.0.0.1:6379"

# ─────────────────────────────────────────────────────
# 3. Start Node.js Backend Server
# ─────────────────────────────────────────────────────
echo "✓ Starting Node.js backend server..."
cd "$PROJECT_DIR/server"
if ! command -v node &> /dev/null; then
  echo "✗ Node.js not found. Please install Node.js"
  exit 1
fi
echo "  Starting on http://localhost:3000..."
# Start node server in background
node server.js &
SERVER_PID=$!
sleep 2

# Check if server is running
if ! kill -0 $SERVER_PID 2>/dev/null; then
  echo "✗ Node.js server failed to start"
  exit 1
fi
echo "  ✓ Backend running (PID: $SERVER_PID)"

# ─────────────────────────────────────────────────────
# 4. Start Flutter App
# ─────────────────────────────────────────────────────
echo "✓ Starting Flutter app..."
cd "$PROJECT_DIR"

if ! command -v flutter &> /dev/null; then
  echo "✗ Flutter not found. Please install Flutter"
  kill $SERVER_PID
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ All services ready! Starting the app..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

flutter run

# Cleanup on exit
cleanup() {
  echo ""
  echo "🛑 Shutting down..."
  if kill -0 $SERVER_PID 2>/dev/null; then
    kill $SERVER_PID
    echo "  ✓ Backend server stopped"
  fi
}

trap cleanup EXIT
