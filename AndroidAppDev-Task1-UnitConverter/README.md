# Unit Converter App

**Oasis Infobyte — Android App Development Internship, Task 1**

A Flutter unit converter with 8 measurement categories, dual unit dropdowns,
live conversion, swap, and input validation. Dark Material 3 theme matching
the Calculator app, with its own logo in the same visual family.

## Feature checklist (from the task sheet)

- [x] Input field for the numeric value to be converted
- [x] Dropdown (Spinner) to select the **source unit**
- [x] Dropdown (Spinner) to select the **target unit**
- [x] Convert button that computes and displays the result
- [x] Result display with unit label
- [x] At least **3 measurement categories** — ships with **8**
- [x] Input validation: toast if the field is empty or non-numeric
- [x] Category selector that **resets the unit dropdowns** on switch

## Extras beyond the sheet

- **8 categories:** Length, Weight, Temperature, Volume, Speed, Area, Data, Time
- **Swap button (⇄)** reverses source and target in one tap
- **Live conversion** as you type (the Convert button is still there, and it's
  the one that validates and toasts — exactly as the sheet describes)
- **Copy to clipboard** for the result
- **Rate line** under the result: `1 cm = 0.3937007874 in`
- Haptic feedback, animated category chips, 1024×1024 app logo

## A note on temperature

Temperature is **affine**, not a simple ratio — `°C → °F` is `v × 9/5 + 32`,
not a multiplier. So `Unit` stores a `toBase`/`fromBase` function pair rather
than a single factor. Tests cover the classic cases (0 °C = 32 °F,
100 °C = 212 °F, −40 °C = −40 °F, 0 K = −273.15 °C).

## How to run

Open a terminal in this folder and run:

```bash
flutter create .
flutter pub get
flutter run
```

> `flutter create .` fills in `android/`, `ios/`, `web/` platform folders.
> It will **not** overwrite `lib/`, `pubspec.yaml`, `test/`, or `assets/`.

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

After `flutter create .`:

```bash
flutter pub add dev:flutter_launcher_icons
```

Append to `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/logo.png"
  min_sdk_android: 21
```

Then:

```bash
dart run flutter_launcher_icons
```

## Project structure

```
unit_converter_app/
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
├── assets/
│   └── logo.png
├── lib/
│   ├── main.dart        # UI
│   └── units.dart       # unit model + conversion table + formatting
└── test/
    └── widget_test.dart # 26 tests (maths + UI)
```

Conversion logic is split into `units.dart` so the maths is testable without
touching the UI — and so an evaluator can read the conversion table on its own.
