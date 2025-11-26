# Dietando
Add the quantity of each food in your diet, set the quantity you already have in your house, and get the shopping list ready.

The actual goal of this project is exploring Flutter. The author wanted to try writing an application using Flutter. By the way, it could still be useful in its meaning.

# Commands

### Dependencies and tooling
- Install Flutter (stable channel) and ensure `flutter` is on the PATH.
- Fetch Dart/Flutter dependencies:

```bash path=null start=null
flutter pub get
```

### Run the application
- Run the app on a connected device or emulator (Android/iOS/desktop depending on your Flutter setup):

```bash path=null start=null
flutter run
```

- Run the web build in Chrome (uses the `web/` directory in this repo):

```bash path=null start=null
flutter run -d chrome
```

### Linting / static analysis
- This project enables `flutter_lints` via `analysis_options.yaml`. Run static analysis with:

```bash path=null start=null
flutter analyze
```

### Testing
- The project depends on `flutter_test` but currently has no `test/` directory. Once tests are added, you can run all tests with:

```bash path=null start=null
flutter test
```

- To run a single test file (replace with the actual path):

```bash path=null start=null
flutter test test/your_test_file.dart
```

### Icons generation
- App icons are managed via `flutter_launcher_icons` and `flutter_launcher_icons.yaml`. After changing icons, regenerate them with:

```bash path=null start=null
dart run flutter_launcher_icons
```