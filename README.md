# aegi

This repository is a lightweight monorepo container. The Flutter mobile app lives in [`app/`](app/), and the repo root stays neutral so future sibling projects can be added without committing to shared tooling yet.

## Layout

```text
.
├── app/        # Flutter mobile app
├── documents/  # Product and design docs
└── README.md
```

## Flutter app workflow

Run Flutter commands from `app/`:

```bash
cd app
flutter pub get
flutter analyze
flutter test
flutter run
```

Equivalent one-liners from the repo root:

```bash
cd app && flutter pub get
cd app && flutter analyze
cd app && flutter test
cd app && flutter run
```

## Notes

- Open the repo root if you want a monorepo workspace view.
- Open `app/` directly if you want the Flutter project in isolation.
- Future apps can be added as sibling directories at the repo root when needed.
