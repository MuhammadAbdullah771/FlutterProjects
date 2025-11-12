# iOS Build Guide for Task Manager App

## Prerequisites

### Required
- **macOS machine** (physical Mac, Hackintosh, or cloud Mac service)
- **Xcode** (latest stable version recommended, minimum 14.0)
- **Apple Developer Account** (free for testing on your own device, $99/year for App Store distribution)
- **Flutter SDK** installed on the Mac
- **CocoaPods** installed (`sudo gem install cocoapods`)

## Building on macOS

### Step 1: Transfer Your Project
Transfer this entire project folder to your Mac machine.

### Step 2: Install Dependencies
Open Terminal on your Mac and navigate to the project directory:

```bash
cd /path/to/task_manager_by_abdullah

# Get Flutter dependencies
flutter pub get

# Navigate to iOS directory
cd ios

# Install CocoaPods dependencies
pod install

# Go back to project root
cd ..
```

### Step 3: Open in Xcode
```bash
open ios/Runner.xcworkspace
```

**Important:** Always open `Runner.xcworkspace`, NOT `Runner.xcodeproj`!

### Step 4: Configure Signing & Capabilities

1. In Xcode, select the **Runner** project in the left sidebar
2. Select the **Runner** target
3. Go to **Signing & Capabilities** tab
4. Select your **Team** (Apple Developer Account)
5. Xcode will automatically generate a Bundle Identifier if needed
6. Ensure the following capabilities are enabled:
   - **Push Notifications** (for local notifications)
   - **Background Modes** → Check "Remote notifications" and "Background fetch"

### Step 5: Build for Simulator

```bash
# List available simulators
flutter devices

# Build and run on iOS simulator
flutter run -d "iPhone 15 Pro"  # or any available simulator
```

### Step 6: Build for Physical Device

1. Connect your iPhone/iPad via USB
2. Trust the computer on your device
3. In Xcode, select your device from the device dropdown
4. Run:

```bash
# Build and run on connected device
flutter run
```

### Step 7: Build Release IPA (for App Store or TestFlight)

```bash
# Clean previous builds
flutter clean
flutter pub get
cd ios
pod install
cd ..

# Build release IPA
flutter build ipa --release

# The IPA will be located at:
# build/ios/ipa/task_manager_by_abdullah.ipa
```

### Step 8: Archive for App Store (via Xcode)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Any iOS Device (arm64)** as the build target
3. Go to **Product** → **Archive**
4. Once archived, the Organizer window will open
5. Select your archive and click **Distribute App**
6. Follow the wizard to upload to App Store Connect or export for ad-hoc distribution

## Alternative: Build on Windows using Cloud Services

Since you're on Windows, you can use these cloud-based solutions:

### Option 1: Codemagic (Recommended)
1. Sign up at [codemagic.io](https://codemagic.io)
2. Connect your Git repository
3. Configure iOS build settings
4. Codemagic will build your iOS app in the cloud
5. Free tier includes 500 build minutes/month

### Option 2: GitHub Actions
1. Push your code to GitHub
2. Create `.github/workflows/ios.yml`:

```yaml
name: iOS Build

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Install CocoaPods
      run: |
        cd ios
        pod install
        cd ..
    
    - name: Build iOS
      run: flutter build ios --release --no-codesign
    
    - name: Upload IPA
      uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/iphoneos/Runner.app
```

### Option 3: Appetize.io
- Upload your IPA to test in a browser-based iOS simulator
- Great for demos and testing

### Option 4: Cloud Mac Services
- **MacStadium**: Rent a Mac in the cloud
- **MacinCloud**: Pay-per-hour Mac access
- **AWS EC2 Mac**: Amazon's Mac instances

## Troubleshooting

### Pod Install Fails
```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install --repo-update
```

### Code Signing Issues
- Ensure you're logged into Xcode with your Apple ID
- Go to Xcode → Preferences → Accounts
- Add your Apple ID if not present
- Download manual profiles if needed

### Build Fails with "No such module"
```bash
flutter clean
flutter pub get
cd ios
pod deintegrate
pod install
cd ..
flutter build ios
```

### Notification Permissions
The app already has the required notification permissions configured in `Info.plist`:
- `NSUserNotificationUsageDescription`: "Task reminders need notification access."
- `UIBackgroundModes`: remote-notification, fetch

## App Store Submission Checklist

Before submitting to the App Store:

1. ✅ Update version in `pubspec.yaml`
2. ✅ Update version in `ios/Runner/Info.plist`
3. ✅ Prepare app screenshots (required sizes)
4. ✅ Prepare app icon (1024x1024px)
5. ✅ Write app description and keywords
6. ✅ Set up App Store Connect listing
7. ✅ Test on multiple devices/simulators
8. ✅ Ensure all features work correctly
9. ✅ Review Apple's App Store Review Guidelines
10. ✅ Archive and upload via Xcode

## Current App Configuration

- **App Name**: Task Manager
- **Bundle ID**: Will be set in Xcode based on your team
- **Version**: 1.0.0 (Build 1)
- **Minimum iOS Version**: 13.0
- **Supported Devices**: iPhone, iPad

## Features Configured for iOS

✅ Local Notifications
✅ SQLite Database (via sqflite)
✅ File System Access (via path_provider)
✅ PDF Generation & Printing
✅ CSV Export
✅ Share Functionality
✅ Permissions Handling

All dependencies in your `pubspec.yaml` are iOS-compatible!

## Next Steps

1. Transfer project to a Mac or set up a cloud build service
2. Run `flutter pub get` and `pod install`
3. Open in Xcode and configure signing
4. Build and test on simulator/device
5. Archive and submit to App Store when ready

## Support

If you encounter issues:
- Check Flutter documentation: https://docs.flutter.dev/deployment/ios
- Check Apple Developer documentation: https://developer.apple.com
- Flutter iOS deployment guide: https://docs.flutter.dev/deployment/ios

Good luck with your iOS build! 🚀

