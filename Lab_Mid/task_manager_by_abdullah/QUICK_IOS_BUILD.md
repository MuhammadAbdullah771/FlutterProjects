# Quick iOS Build Reference

## 🚀 Fastest Way to Build (No Mac Needed!)

### Using GitHub Actions (FREE)

```bash
# 1. Push to GitHub
git init
git add .
git commit -m "iOS build ready"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main

# 2. Wait for build (5-10 minutes)
# 3. Download IPA from GitHub Actions → Artifacts
```

That's it! ✅

---

## 🍎 If You Have a Mac

```bash
# 1. Get dependencies
flutter pub get
cd ios && pod install && cd ..

# 2. Build
flutter build ios --release

# 3. Or run on simulator
flutter run
```

---

## 📱 Install IPA on iPhone (Without App Store)

### Method 1: TestFlight (Recommended)
1. Upload IPA to App Store Connect
2. Add testers
3. They install via TestFlight app

### Method 2: Direct Install (Development)
1. Connect iPhone to Mac
2. Open Xcode
3. Window → Devices and Simulators
4. Drag IPA to device

### Method 3: Third-party Tools
- **AltStore** (free, requires computer)
- **Sideloadly** (free)
- **Cydia Impactor** (free)

---

## 🔧 Common Commands

```bash
# Clean build
flutter clean && flutter pub get

# Build for simulator
flutter build ios --simulator

# Build for device
flutter build ios --release

# Build IPA
flutter build ipa --release

# Run on connected device
flutter run

# List devices
flutter devices
```

---

## ✅ Checklist

Before building:
- [ ] `flutter pub get` completed
- [ ] `pod install` completed (on Mac)
- [ ] No errors in `flutter analyze`
- [ ] Tests pass with `flutter test`
- [ ] Version updated in `pubspec.yaml`

---

## 🆘 Quick Fixes

**Build fails?**
```bash
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
flutter build ios
```

**Pod install fails?**
```bash
cd ios
pod cache clean --all
pod deintegrate
pod install --repo-update
```

**Code signing issues?**
- Open Xcode
- Select Runner target
- Signing & Capabilities
- Select your Team

---

## 📊 Build Status

Your app is configured for:
- ✅ iOS 13.0+
- ✅ iPhone & iPad
- ✅ Local notifications
- ✅ Background modes
- ✅ All plugins iOS-compatible

---

## 🎯 Quick Links

- [Full Guide](IOS_BUILD_GUIDE.md)
- [Summary](IOS_BUILD_SUMMARY.md)
- [Flutter iOS Docs](https://docs.flutter.dev/deployment/ios)

---

**Need help?** Check `IOS_BUILD_GUIDE.md` for detailed instructions!

