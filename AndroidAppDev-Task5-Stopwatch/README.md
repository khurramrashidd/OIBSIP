# Stopwatch App

**Oasis Infobyte — Android App Development Internship, Task 5**

A Flutter stopwatch with Start / Pause / Resume / Reset / Lap, dark theme,
tabular-figure time display, and proper Android lifecycle handling.

## Feature checklist (from the task sheet)

- [x] Large, clearly visible time display (`MM:SS.cs`, or `HH:MM:SS.cs` after 1 hour)
- [x] Start button
- [x] Stop/Pause button
- [x] Reset button
- [x] Buttons visually change state (disabled Reset/Pause when not applicable, Start → Lap when running)
- [x] Timer continues correctly across `onPause` / `onResume` (uses the system monotonic clock via Dart's `Stopwatch`)
- [x] **Bonus:** Lap functionality with scrollable split list

## How to run

Open a terminal in this folder (where `pubspec.yaml` sits) and run:

```bash
flutter create .
flutter pub get
flutter run
```

> `flutter create .` fills in the `android/`, `ios/`, `web/` platform
> folders that aren't shipped in this zip — same as your usual Flutter
> project setup. It will **not** overwrite `lib/main.dart` or `pubspec.yaml`.

### Before submission (full checklist)

```bash
flutter clean
flutter pub get
dart fix --apply
flutter analyze
flutter test
flutter build apk --release
```

Release APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

### If you want to run on web too

```bash
flutter build web
```

## Project structure

```
stopwatch_app/
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
└── lib/
    └── main.dart
```

Everything is in a single file (`main.dart`) by design — small, readable,
easy to walk an evaluator through.
