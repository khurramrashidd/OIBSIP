# Calculator App

**Oasis Infobyte — Android App Development Internship, Task 3**

A Flutter calculator with a proper expression engine (operator precedence
via shunting-yard), dark Material 3 theme, animated buttons, and a
hand-drawn 1024×1024 app logo.

## Feature checklist (from the task sheet)

- [x] Display showing current input + result
- [x] Number buttons 0–9 and decimal point
- [x] Operator buttons: + − × ÷
- [x] Equals (=) to evaluate
- [x] Clear (C) to reset
- [x] Backspace (⌫) to delete last character
- [x] Division-by-zero shows **Error**
- [x] 4-column button grid (`LayoutBuilder` + `Row`/`Column`, functionally equivalent to `GridLayout`)
- [x] No crashes on rapid/repeated taps (verified in widget test)

## Extras beyond the sheet

- Shunting-yard parser → **operator precedence** (× and ÷ before + and −)
- **Percent** (%) and **sign toggle** (+/−)
- Secondary expression line (shows what you just computed)
- **Haptic feedback** on every button
- Animated press feedback (scale + colour lerp)
- 1024×1024 PNG app logo at `assets/logo.png` (ready to use with `flutter_launcher_icons`)

## How to run

Open a terminal in this folder and run:

```bash
flutter create .
flutter pub get
flutter run
```

> `flutter create .` fills in `android/`, `ios/`, `web/` platform folders.
> It will **not** overwrite `lib/main.dart`, `pubspec.yaml`, `test/widget_test.dart`, or `assets/`.

Pre-submission full check:

```bash
flutter clean
flutter pub get
dart fix --apply
flutter analyze
flutter test
flutter build apk --release
```

Release APK: `build/app/outputs/flutter-apk/app-release.apk`

## App logo

`assets/logo.png` is a 1024×1024 PNG you can use as the launcher icon.

**Quick way to set it as the Android launcher icon** (optional, after
`flutter create .`):

```bash
flutter pub add dev:flutter_launcher_icons
```

Then add to the bottom of `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/logo.png"
  min_sdk_android: 21
```

And run:

```bash
dart run flutter_launcher_icons
```

## Project structure

```
calculator_app/
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
├── assets/
│   └── logo.png
├── lib/
│   └── main.dart
└── test/
    └── widget_test.dart
```
