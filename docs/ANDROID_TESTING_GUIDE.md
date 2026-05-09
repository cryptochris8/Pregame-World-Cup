# Testing on Android - Local Setup Guide

**Date**: December 26, 2025
**Purpose**: Run and test the Pregame World Cup app on Android devices/emulators

---

## ✅ Yes, You Can Test on Android Locally!

The app is fully compatible with Android and can be tested in multiple ways:

1. **Android Emulator** (Virtual device on your PC)
2. **Physical Android Device** (via USB cable)
3. **Wireless Debugging** (Android 11+ devices)

---

## Option 1: Android Emulator (Recommended for Testing)

### Step 1: Open Android Studio

If you don't have Android Studio installed:
1. Download from: https://developer.android.com/studio
2. Install and run Android Studio
3. Follow setup wizard to install Android SDK

### Step 2: Create/Start an Emulator

**Method A: Using Android Studio**
1. Open Android Studio
2. Click **Tools** → **Device Manager** (or AVD Manager)
3. Click **Create Device** (if no emulator exists)
4. Choose a device (recommend: **Pixel 5** or **Pixel 6**)
5. Select system image (recommend: **Android 13 (API 33)** or **Android 14 (API 34)**)
6. Click **Finish**
7. Click **▶ Play** button to start the emulator

**Method B: Using Command Line**
```bash
# List available emulators
emulator -list-avds

# Start an emulator
emulator -avd Pixel_5_API_33
```

### Step 3: Verify Emulator is Detected

```bash
# Check if Flutter sees the emulator
flutter devices
```

**Expected Output**:
```
Found 4 connected devices:
  sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33)
  Windows (desktop)           • windows       • windows-x64    • Microsoft Windows
  Chrome (web)                • chrome        • web-javascript • Google Chrome
  Edge (web)                  • edge          • web-javascript • Microsoft Edge
```

### Step 4: Run App on Emulator

```bash
# Run on the Android emulator
flutter run -d emulator-5554

# OR let Flutter auto-select Android device
flutter run -d android
```

**First Build**: Takes 3-5 minutes
**Subsequent Builds**: 30-60 seconds

---

## Option 2: Physical Android Device (USB Cable)

### Step 1: Enable Developer Options on Your Phone

1. Open **Settings** on your Android phone
2. Go to **About phone**
3. Tap **Build number** 7 times (you'll see "You are now a developer!")

### Step 2: Enable USB Debugging

1. Go back to main Settings
2. **System** → **Developer options**
3. Enable **USB debugging**
4. (Optional) Enable **Install via USB** for faster installs

### Step 3: Connect Phone to PC

1. Connect your Android phone via USB cable
2. Phone will show: **"Allow USB debugging?"**
3. Check **"Always allow from this computer"**
4. Tap **OK**

### Step 4: Verify Phone is Detected

```bash
# Check connected devices
flutter devices
```

**Expected Output**:
```
Found 4 connected devices:
  SM G998U (mobile)  • 1234567890ABCDEF • android-arm64 • Android 13 (API 33)
  Windows (desktop)  • windows          • windows-x64   • Microsoft Windows
  Chrome (web)       • chrome           • web-javascript • Google Chrome
```

### Step 5: Run App on Phone

```bash
# Run on physical device
flutter run
```

Flutter will automatically select the connected Android device.

---

## Option 3: Wireless Debugging (Android 11+)

### Prerequisites
- Android 11 or higher
- Phone and PC on same Wi-Fi network
- ADB installed (comes with Android Studio)

### Step 1: Enable Wireless Debugging

1. Connect phone via USB first
2. On phone: **Settings** → **Developer options** → **Wireless debugging**
3. Enable **Wireless debugging**
4. Tap **Pair device with pairing code**
5. Note the **IP address, port, and pairing code**

### Step 2: Pair Device

On your PC:
```bash
# Pair using code (replace with your values)
adb pair 192.168.1.100:12345

# Enter the pairing code when prompted
```

### Step 3: Connect Wirelessly

```bash
# Connect to device (use the IP:port shown under "IP address & Port")
adb connect 192.168.1.100:5555

# Verify connection
flutter devices
```

### Step 4: Run App Wirelessly

```bash
flutter run
```

You can now unplug the USB cable and the app will run wirelessly!

---

## Quick Start Commands

### If you have an emulator already running:
```bash
flutter run -d android
```

### If you have a physical device connected:
```bash
flutter run
```

### To select specific device:
```bash
# List devices
flutter devices

# Run on specific device
flutter run -d emulator-5554
# OR
flutter run -d 1234567890ABCDEF  # Your phone's ID
```

---

## Troubleshooting

### Issue: "No devices found"

**For Emulator**:
```bash
# Check if emulator is running
emulator -list-avds

# Start emulator manually
emulator -avd Pixel_5_API_33
```

**For Physical Device**:
```bash
# Check ADB sees device
adb devices

# If device offline, restart ADB
adb kill-server
adb start-server
```

### Issue: "Could not find gradle"

```bash
# Create gradle wrapper (if missing)
cd android
./gradlew wrapper
cd ..

# Try running again
flutter run -d android
```

### Issue: "Android license not accepted"

```bash
flutter doctor --android-licenses

# Accept all licenses by typing 'y'
```

### Issue: Build fails with "INSTALL_FAILED"

```bash
# Clean build and rebuild
flutter clean
flutter pub get
flutter run -d android
```

### Issue: App installs but crashes immediately

Check logcat for errors:
```bash
adb logcat | grep Flutter
```

---

## Testing Checklist (Android-Specific)

After the app launches on Android, test these Android-specific features:

### Basic Functionality
- [ ] App launches without crashing
- [ ] All screens load (Teams, Matches, Groups, etc.)
- [ ] Data loads from Firestore
- [ ] Navigation works (bottom nav bar)
- [ ] Back button works correctly

### Android-Specific
- [ ] **Push notifications** (if implemented)
- [ ] **Deep links** (if configured)
- [ ] **Share functionality** works
- [ ] **Camera/Gallery** for profile pictures
- [ ] **Location services** for venue finder
- [ ] **App works offline** (cached data)

### Performance
- [ ] Smooth scrolling through teams/matches
- [ ] Images load efficiently
- [ ] No lag when switching screens
- [ ] Memory usage acceptable (check Android profiler)

### UI/UX
- [ ] Status bar color correct
- [ ] Safe areas respected (no notch overlap)
- [ ] Bottom nav doesn't overlap content
- [ ] Keyboard doesn't cover inputs
- [ ] Splash screen displays properly

---

## Performance Profiling on Android

### Enable Performance Overlay

While app is running, press **Shift + P** in terminal to show:
- **FPS (frames per second)** - should be close to 60 FPS
- **Frame render time** - should be under 16ms

### Run in Profile Mode (Better Performance)

```bash
# Profile mode (more accurate performance)
flutter run --profile -d android

# Release mode (production performance)
flutter run --release -d android
```

**Note**: Can't use hot reload in release mode

---

## Building APK for Testing

### Debug APK (Quick Build)
```bash
flutter build apk --debug

# APK location:
# build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (Optimized)
```bash
flutter build apk --release

# APK location:
# build/app/outputs/flutter-apk/app-release.apk
```

### Install APK on Device
```bash
# Install debug APK
adb install build/app/outputs/flutter-apk/app-debug.apk

# OR drag-and-drop APK to emulator
```

---

## Comparing Android vs Chrome

### Advantages of Testing on Android
- ✅ Real device performance
- ✅ Touch gestures (swipe, pinch, etc.)
- ✅ Native features (camera, GPS, notifications)
- ✅ Actual app experience
- ✅ Test on different screen sizes

### When to Use Chrome
- ✅ Faster iteration (hot reload is instant)
- ✅ Easy debugging (Chrome DevTools)
- ✅ No device setup required
- ✅ Good for UI-only testing

### Recommendation
**For World Cup App Testing**:
1. **Chrome**: Quick UI/UX testing and iteration
2. **Android Emulator**: Functional testing and user experience
3. **Physical Device**: Final testing before release

---

## Example: Full Testing Workflow

```bash
# 1. Check what's available
flutter devices

# 2. Start Android emulator (if needed)
emulator -avd Pixel_5_API_33

# 3. Wait for emulator to boot (30-60 seconds)

# 4. Run app on Android
flutter run -d android

# 5. App builds and installs
# First build: 3-5 minutes
# Subsequent: 30-60 seconds

# 6. App launches on emulator
# Test all features!

# 7. Hot reload for changes
# Make a code change, then press 'r' in terminal

# 8. Stop app when done
# Press 'q' in terminal
```

---

## Recommended Emulator Specs

For best testing experience:

**Device**: Pixel 5 or Pixel 6
**Android Version**: Android 13 (API 33) or Android 14 (API 34)
**RAM**: 2048 MB minimum
**Storage**: 8 GB minimum
**Graphics**: Hardware - GLES 2.0

---

## Next Steps After Android Testing

1. **Test on Multiple Devices**:
   - Small phone (5.5")
   - Medium phone (6.1")
   - Large phone (6.7")
   - Tablet (10")

2. **Test Different Android Versions**:
   - Android 12 (API 31)
   - Android 13 (API 33)
   - Android 14 (API 34)

3. **Test Edge Cases**:
   - Low memory device
   - Slow network connection
   - Offline mode
   - Different locales (language/region)

4. **Performance Testing**:
   - Monitor FPS (should be 60)
   - Check memory usage
   - Test with large datasets
   - Measure app startup time

---

## Summary

**Can you test on Android locally?** ✅ **YES!**

**Best Option for You**:
- If you have Android Studio: Use **Android Emulator** (Pixel 5, Android 13)
- If you have an Android phone: Use **Physical Device via USB**

**Quick Command**:
```bash
flutter run -d android
```

**First Build Time**: 3-5 minutes
**Subsequent Builds**: 30-60 seconds
**Hot Reload**: Instant (r key)

---

**The app is ready to run on Android right now - no additional setup needed in the codebase!**
