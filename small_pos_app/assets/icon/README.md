# App Icon Generation

This directory contains the app icon design files.

## Design Description

The app icon features:
- **White rounded square** (outer frame)
- **Light green inner square** with rounded corners (#81C784)
- **Light green handle/loop** at the top (wallet/bag style)
- **Yellow circle** in the center (#FFD54F)
- **Black dollar sign ($)** symbol
- **No text** - clean, minimalist design suitable for Play Store

## Files

- `icon.svg` - Full icon design (512x512)
- `icon_foreground.svg` - Foreground layer for adaptive icon
- `icon_background.svg` - Background layer for adaptive icon

## Generating PNG Icons

### Option 1: Using Python Script (Recommended)

1. Install dependencies:
```bash
pip install cairosvg pillow
```

2. Run the script:
```bash
python generate_icon.py
```

This will generate all required icon sizes for Android.

### Option 2: Using Online Tools

1. Use an online SVG to PNG converter (e.g., https://convertio.co/svg-png/)
2. Convert `icon.svg` to PNG with these sizes:
   - 48x48 (mdpi)
   - 72x72 (hdpi)
   - 96x96 (xhdpi)
   - 144x144 (xxhdpi)
   - 192x192 (xxxhdpi)
   - 512x512 (Play Store)

3. Place the PNG files in:
   - `android/app/src/main/res/mipmap-{density}/ic_launcher.png`
   - Play Store: `assets/icon/icon_512.png`

### Option 3: Using Flutter Launcher Icons

1. Install the package (already added to pubspec.yaml):
```bash
flutter pub get
```

2. Create a 1024x1024 PNG from the SVG and save as `assets/icon/icon.png`

3. Run:
```bash
flutter pub run flutter_launcher_icons
```

## Play Store Requirements

- **Size**: 512x512 pixels (required)
- **Format**: PNG (32-bit with alpha channel)
- **Content**: No text, clean design
- **Background**: Can be transparent or solid color

The generated `icon_512.png` can be used directly for Play Store upload.

