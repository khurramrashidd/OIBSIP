# OIBSIP — Oasis Infobyte Summer Internship Programme

**Intern:** Khurram Rashid
**Track:** Android App Development
**Completion rule:** at least 3 of the 5 track tasks — **3 submitted**

---

## Tasks in this repository

| Task | Project | Folder | Status |
|------|---------|--------|--------|
| Task 1 | Unit Converter | [`AndroidAppDev-Task1-UnitConverter`](./AndroidAppDev-Task1-UnitConverter) | ✅ Complete |
| Task 3 | Calculator | [`AndroidAppDev-Task3-Calculator`](./AndroidAppDev-Task3-Calculator) | ✅ Complete |
| Task 5 | Stopwatch | [`AndroidAppDev-Task5-Stopwatch`](./AndroidAppDev-Task5-Stopwatch) | ✅ Complete |

Each folder contains its own `README.md` with the full feature checklist,
screenshots, and build instructions.

---

## Tech stack

All three apps are built with **Flutter (Dart)**, targeting Android and
developed in **VS Code**.

| Layer | Choice |
|-------|--------|
| Framework | Flutter (Material 3) |
| Language | Dart |
| State | `StatefulWidget` + `setState` (no external state library) |
| Dependencies | None beyond `flutter`, `cupertino_icons`, `flutter_lints` |
| Testing | `flutter_test` — unit + widget tests in every project |
| Theme | Dark, Material 3, seeded colour schemes |

No third-party packages are used for the core logic. The calculator's
expression parser and the converter's unit tables are hand-written Dart, so
every piece of the logic is reviewable in this repository.

---

## Running any project

```bash
cd AndroidAppDev-Task3-Calculator
flutter pub get
flutter run
```

Build a release APK:

```bash
flutter build apk --release
# -> build/app/outputs/flutter-apk/app-release.apk
```

Run the test suite:

```bash
flutter analyze
flutter test
```

> `build/` and `.dart_tool/` are intentionally not committed — see
> [`.gitignore`](./.gitignore). Run `flutter pub get` after cloning and the
> toolchain regenerates everything it needs.

---

## Design

The three apps share one visual language: dark Material 3 surfaces on a
`#0B0B10` background, a single accent colour per app, and matching launcher
icons built on the same geometry (rounded square, diagonal gradient, white
centred glyph, four subtle corner marks).

| App | Accent | Icon glyph |
|-----|--------|-----------|
| Unit Converter | Sky → Teal | `⇄` bidirectional arrows |
| Calculator | Indigo → Violet | `=` equals bars |
| Stopwatch | Amber → Orange | Stopwatch ring + hand |

---

## Links

- **GitHub:** [github.com/khurramrashidd](https://github.com/khurramrashidd)
- **LinkedIn:** [linkedin.com/in/khurramrashidd](https://linkedin.com/in/khurramrashidd)

`#oasisinfobyte`
