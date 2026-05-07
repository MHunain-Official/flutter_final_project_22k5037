# 🚀 Quick Start — Smart Travel Companion

## Prerequisites

Ensure the following are installed and running:

```bash
# Check PostgreSQL
pg_isready -h 127.0.0.1 -p 5432

# Check Redis
redis-cli ping
# Output: PONG

# Check Node.js
node --version
# Should be >= v18

# Check Flutter
flutter doctor
```

---

## ⚡ RECOMMENDED: Android Emulator

**Best approach for development** — avoids Linux linker issues.

```bash
cd /home/eon/Desktop/Personal/Quiz/flutter_final_project_22k5037
./start-android.sh
```

Or manually:
```bash
# Step 1: Launch Android Emulator
flutter emulators --launch Pixel_5_API_30

# Step 2: In server directory (new terminal)
cd server && node server.js

# Step 3: In project directory (another terminal)
flutter run
```

---

## ⚡ Method 1: Use start.sh Script (for Linux with build tools)

**Note:** Requires Linux development tools (gcc, clang, cmake, ninja).

```bash
cd /home/eon/Desktop/Personal/Quiz/flutter_final_project_22k5037
./start.sh
```

If you get linker errors, see **Troubleshooting** below.

---

## ⚡ Method 2: Manual Start (Step-by-Step)

### Step 1: Start PostgreSQL (if not running)

```bash
# Linux
sudo systemctl start postgresql

# macOS
brew services start postgresql

# Or verify it's already running
pg_isready -h 127.0.0.1 -p 5432
```

### Step 2: Start Redis (if not running)

```bash
# In a separate terminal
redis-server

# Or verify it's already running
redis-cli ping
```

### Step 3: Start Node.js Backend

```bash
cd /home/eon/Desktop/Personal/Quiz/flutter_final_project_22k5037/server
node server.js

# Expected output:
# ✓ Server running on http://localhost:3000
# ✓ PostgreSQL connected
# ✓ Redis connected
```

### Step 4: Start Flutter App (in a new terminal)

```bash
cd /home/eon/Desktop/Personal/Quiz/flutter_final_project_22k5037

# On Linux (with required build tools installed)
flutter run

# On Android emulator
flutter run -d emulator-5554

# On iOS simulator
flutter run -d iPhone
```

---

## 🛠️ Linux Build Requirements

**If you want to build on Linux desktop** (not recommended), install build tools:

### Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  clang \
  cmake \
  ninja-build \
  libgtk-3-dev \
  pkg-config

# Verify linker is found
which ld
```

### Fedora

```bash
sudo dnf install -y \
  gcc \
  g++ \
  clang \
  cmake \
  ninja-build \
  gtk3-devel
```

### After installing, retry:

```bash
flutter clean
flutter pub get
flutter run
```

---

## ⚠️ EXACT ERROR FIX: `ld.lld not found in /usr/lib/llvm-18/bin`

### This is what you're seeing:
```
ERROR: Target dart_build failed: Error: Failed to find any of [ld.lld, ld] in LocalDirectory: '/usr/lib/llvm-18/bin'
```

### **Solution 1: Create Symlink (Easy, requires sudo)**

```bash
# Find where ld is located
which ld

# Create symlinks in the LLVM directory
sudo ln -s /usr/bin/ld /usr/lib/llvm-18/bin/ld
sudo ln -s /usr/bin/ld /usr/lib/llvm-18/bin/ld.lld

# Verify
ls -la /usr/lib/llvm-18/bin/ld*

# Then try again
flutter clean && flutter run
```

### **Solution 2: Install Full Build Toolchain (Recommended)**

```bash
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  clang \
  cmake \
  ninja-build \
  libgtk-3-dev \
  pkg-config

flutter clean && flutter run
```

### **Solution 3: Use Android Emulator Instead (No build tools needed)**

See section "RECOMMENDED: Android Emulator" above.

---

## 📱 Running on Different Platforms

### Android Emulator

```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulator --launch Pixel_5_API_30

# Run the app
flutter run
```

### iOS Simulator (macOS only)

```bash
# Open simulator
open -a Simulator

# Run the app
flutter run
```

### Web (Linux/macOS/Windows)

```bash
flutter run -d chrome
```

---

## 🧪 Test the Backend

```bash
# Health check
curl http://localhost:3000/health

# Register user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Ali Hassan",
    "email": "ali@example.com",
    "password": "test123"
  }'

# Get places
curl "http://localhost:3000/api/places?page=1&limit=5"
```

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| `Failed to find ld.lld or ld in /usr/lib/llvm-18/bin` | **Use Android Emulator** (recommended) or install build tools: `sudo apt-get install build-essential clang cmake ninja-build libgtk-3-dev` |
| `Connection refused` on backend | Ensure backend is running: `curl http://localhost:3000/health` |
| `Password authentication failed` | Check PostgreSQL credentials in `server/.env` |
| `ECONNREFUSED` on Redis | Start Redis: `redis-server` |
| App won't launch on Android | Make sure Android SDK is installed: `flutter doctor` |
| `firebase_core` errors | Run `flutter clean` then `flutter pub get` |
| No emulator available | Create one: `flutter emulators create --name Pixel_5 Pixel_5_API_30` |

---

## 📚 Full Troubleshooting Guide

**See [TROUBLESHOOTING_LINKER.md](TROUBLESHOOTING_LINKER.md)** for detailed solutions to the `ld.lld not found` error with step-by-step commands.

---

**Happy developing!** 🎉
