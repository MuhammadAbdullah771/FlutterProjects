# Task Manager by Abdullah

Task Manager is a Flutter MVVM app scaffold featuring SQLite persistence, local notifications with repeat rules, export (CSV/PDF), backup/restore, search & filtering, and theme toggling.

## Getting Started

1. [Install Flutter](https://docs.flutter.dev/get-started/install) (stable channel, Flutter 3.22+ recommended).
2. Fetch dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

4. Build release:

   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

## Features

- MVVM + Provider architecture (`lib/data`, `lib/viewmodels`, `lib/views`).
- SQLite database via `sqflite` with migration-ready schema (`DatabaseService`).
- Repeat rules (daily/weekly/interval) with occurrences tracking.
- Local notifications with sound selection, scheduling, and repeat handling.
- Subtasks with progress indicators.
- Search, filter by tag/priority/date.
- Export CSV/PDF (`ExportService` + `printing`, `share_plus`).
- Backup/restore database file.
- Settings with theme toggle, notification controls, Ad placeholders, legal links.
- Unit tests for recurrence logic and data layer.

## Notifications

### Android
- Permissions declared in `android/app/src/main/AndroidManifest.xml`.
- For Android 13+, POST_NOTIFICATIONS permission is requested at runtime (handled automatically by plugin).

### iOS
- Enable Push Capability in Xcode.
- Add notification capability (`Info.plist` already configured).
- Provide custom sounds if used (add to `Runner` project `Resources`).

## Exports & Sharing

- Navigate to Settings → Export & Share.
- Select a date range and tasks.
- Export as CSV or PDF; share using the platform share sheet.

## Backup & Restore

- Settings → Backup database copies the SQLite file to application documents.
- The same file is used for restore. For production, integrate a file picker or cloud sync.

## Monetization hooks

- `SettingsPage` includes TODO placeholders for AdMob integration and legal links.
- Insert `BannerAd` / `NativeAd` widgets into `HomePage` or detail views once keys are available.
- Implement remote-configured premium upsells by expanding `SettingsViewModel`.

## Testing

```bash
flutter test
```

Tests cover recurrence utilities and basic database CRUD (uses `sqflite_common_ffi` for in-memory DB).

## TODOs

- Replace placeholder backup workflow with user-driven file pickers.
- Implement remote push integration if needed (currently local notifications only).
- Configure AdMob IDs and surfaces.
- Harden PDF layout for large datasets (pagination, theming).

---

After copying these files, run `flutter pub get` then `flutter run`. Allow notification permissions on first launch to enable reminders.
