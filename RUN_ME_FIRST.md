# ▶️ RUN ME FIRST — Quick Fix Guide

You're seeing this error:
```
ERROR: Target dart_build failed: Error: Failed to find any of [ld.lld, ld] in LocalDirectory: '/usr/lib/llvm-18/bin'
```

## 🚀 To get the app running NOW:

### **Step 1: Choose Your Path**

**Path A** — Fix Linux build (2 min) ✅ Best for desktop development
```bash
sudo ln -s /usr/bin/ld /usr/lib/llvm-18/bin/ld
sudo ln -s /usr/bin/ld /usr/lib/llvm-18/bin/ld.lld
cd /home/eon/Desktop/Personal/Quiz/flutter_final_project_22k5037
flutter clean && flutter run
```

**Path B** — Install build tools (5-10 min) ✅ Most reliable
```bash
sudo apt-get update && sudo apt-get install -y build-essential clang cmake ninja-build libgtk-3-dev pkg-config
cd /home/eon/Desktop/Personal/Quiz/flutter_final_project_22k5037
flutter clean && flutter run
```

**Path C** — Use Android Emulator (no linker needed) ✅ Fastest if you have Android SDK
```bash
flutter emulator --launch Pixel_5_API_30
# Wait for emulator to launch, then:
cd /home/eon/Desktop/Personal/Quiz/flutter_final_project_22k5037
flutter run
```

---

## 🎯 Recommended: Path A (Symlink)

It's the quickest and doesn't require installing 500MB of tools.

```bash
# 1. Create the linker symlinks
sudo ln -s /usr/bin/ld /usr/lib/llvm-18/bin/ld
sudo ln -s /usr/bin/ld /usr/lib/llvm-18/bin/ld.lld

# 2. Verify they exist
ls -la /usr/lib/llvm-18/bin/ld*
# You should see:
# /usr/lib/llvm-18/bin/ld -> /usr/bin/ld
# /usr/lib/llvm-18/bin/ld.lld -> /usr/bin/ld

# 3. Go to project directory
cd /home/eon/Desktop/Personal/Quiz/flutter_final_project_22k5037

# 4. Clean and run
flutter clean
flutter pub get
flutter run
```

---

## ❓ Still Having Issues?

### Create the directory first:
```bash
sudo mkdir -p /usr/lib/llvm-18/bin
sudo ln -s /usr/bin/ld /usr/lib/llvm-18/bin/ld
sudo ln -s /usr/bin/ld /usr/lib/llvm-18/bin/ld.lld
```

### Or check for linker manually:
```bash
which ld       # Should show /usr/bin/ld
which ld.lld   # Will likely show nothing
ls /usr/bin/ld* # Lists available linkers
```

---

## 📖 For More Details

- Full troubleshooting: [TROUBLESHOOTING_LINKER.md](TROUBLESHOOTING_LINKER.md)
- General setup: [QUICKSTART.md](QUICKSTART.md)
- Project info: [doc/architecture.md](doc/architecture.md)

---

**Pick Path A above and follow the 4 steps. Should work!** ✨
