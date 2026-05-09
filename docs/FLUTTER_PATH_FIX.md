# Flutter PATH Fix for PowerShell

**Issue**: Flutter works in Git Bash but not in PowerShell

**Error**:
```
The term 'C:\src\flutter\bin\flutter.bat' is not recognized...
```

---

## Quick Solution: Use Git Bash Instead

Since Flutter is working in Git Bash (my environment), you can simply run Flutter commands from Git Bash instead of PowerShell:

```bash
# Open Git Bash and run:
cd /d/Pregame-World-Cup
flutter run -d windows
```

---

## Permanent Fix: Update PowerShell PATH

### Option 1: Find Current Flutter Location

Run this in Git Bash to find where Flutter is installed:
```bash
which flutter
```

This will show you the actual path (e.g., `C:\Users\chris\AppData\Local\flutter\bin\flutter`)

### Option 2: Update Windows Environment Variable

1. Press **Win + X** → **System**
2. Click **Advanced system settings**
3. Click **Environment Variables**
4. Under **User variables**, find **Path**
5. Click **Edit**
6. Find the entry with `C:\src\flutter\bin` (the broken path)
7. Either:
   - **Remove it** (if you don't use Flutter elsewhere)
   - **Update it** to the correct path from step 1

8. Click **OK** to save
9. **Close and reopen** PowerShell

### Option 3: Reinstall Flutter

If you can't find where Flutter is currently installed:

1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter` (or `D:\flutter` if C: drive is full)
3. Add to PATH: `C:\flutter\bin`
4. Run `flutter doctor` to verify

---

## For Now: App is Building

I've started the app building from my environment using:
```bash
flutter run -d windows
```

The Windows desktop app should launch shortly. This is your first time building for Windows, so it may take 5-10 minutes.

---

## Alternative: Run on Chrome (Faster)

If Windows build is too slow, you can run on Chrome instead:

```bash
# From Git Bash:
flutter run -d chrome
```

This is much faster (30 seconds vs 10 minutes for first build).

---

**Current Status**: App building in background (Windows desktop)
**Next**: Test the UI with populated Firestore data
