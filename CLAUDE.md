# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Dependencies
flutter pub get

# REQUIRED after pub get or any ARB file change — generates lib/l10n/app_localizations*.dart
flutter gen-l10n

# Run (device/emulator)
flutter run

# Static analysis
flutter analyze

# Build
flutter build appbundle   # Android AAB → build/app/outputs/bundle/release/app-release.aab
flutter build apk         # Android APK → build/app/outputs/flutter-apk/app-release.apk
flutter build ipa         # iOS

# Regenerate app icons / splash screen
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

> `lib/l10n/app_localizations.dart` and `lib/l10n/app_localizations_*.dart` are **generated** and git-ignored. Always run `flutter gen-l10n` after pulling changes to ARB files or after `pub get` in a fresh clone.

## Architecture

### Data flow

```
SharedPreferences (JSON)
    └─ Repository (abstract interface + SharedPrefs impl)
        └─ AsyncNotifier (Riverpod provider)
            └─ ConsumerWidget / ConsumerStatefulWidget (UI)
```

All state lives in Riverpod **AsyncNotifier** providers. Providers use optimistic updates: state is updated immediately, then persisted; on error the previous state is restored. The `SharedPreferences` instance is injected at startup via `sharedPreferencesProvider.overrideWithValue(prefs)` in `main.dart`.

### Key files

| Path | Role |
|---|---|
| `lib/models/models.dart` | All data models and enums in one file |
| `lib/providers/` | One provider file per domain entity |
| `lib/repositories/` | Abstract interfaces + SharedPrefs implementations |
| `lib/pages/` | One file per screen; `all.dart` is a barrel export |
| `lib/components/` | Reusable widgets (topbar, navbar, filter, shopping items) |
| `lib/services/import_export_service.dart` | Full-data JSON backup/restore |
| `lib/router.dart` | GoRouter config + `AppRoutes` constants |
| `lib/l10n/extensions.dart` | Extension methods for translating enums |
| `lib/l10n/app_en.arb` | i18n template (source of truth for keys) |

### Models

All models are in `lib/models/models.dart`:

- **DietItem** — food in the diet (name, weeklyTarget, currentStock, unit, categoryId)
- **MealPlan** — `Map<DayOfWeek, Map<MealType, List<MealPlanItem>>>` covering all 7 days × 5 meal types
- **MealPlanItem** — a single diet item entry within a meal (dietItemId, quantity)
- **ExtraItem** — non-diet checklist item (name, isBought, quantity?)
- **ShoppingCategory** — category for grouping diet items in the shopping list (name, priority)
- **SettingsData** — themeMode ('light'|'dark'|'system') + language code ('it','en','es','fr','de')
- **Unit** enum — `Grammi`, `Pezzi`, `Litri` (note: capitalized, triggers `constant_identifier_names` lint info — pre-existing, do not change)
- **MealType** / **DayOfWeek** enums — Italian-named but localised at display time via extensions

### Localization

ARB files in `lib/l10n/` are the source. `app_en.arb` is the template with metadata (`@key` blocks). Generated code is git-ignored.

Enum display names are **never** accessed via `.displayName` in the UI — always use the extension methods from `lib/l10n/extensions.dart`:

```dart
final l10n = AppLocalizations.of(context)!;
mealType.l10nName(l10n)   // MealTypeL10n extension
day.l10nName(l10n)        // DayOfWeekL10n extension
unit.l10nName(l10n)       // UnitL10n extension
```

To add a new UI string: add the key to `app_en.arb` and all other ARB files, then run `flutter gen-l10n`.

To add a new language: create `app_XX.arb`, add `Locale('XX')` to `supportedLocales` in `main.dart`, add the radio option in `settings.dart`, run `flutter gen-l10n`.

### Navigation

GoRouter with five flat routes defined in `AppRoutes` constants (`lib/router.dart`). Navigation uses `context.push(AppRoutes.X)`. The bottom `AppNavBar` drives the four main tabs; settings is pushed from the `AppTopBar` action button (hidden when already on the settings page).

### Filter widget

`Filter<T>` (`lib/components/filter.dart`) is generic. It exposes a `FilterController` for external reset. When used inside a dialog, pass `setDialogState` (from `StatefulBuilder`) as the `updateList` callback — **not** the page-level `setState` — otherwise the dialog list won't re-render.

### Import/Export

`ImportExportService` serializes all four provider states into a single JSON object. On non-web platforms it uses `FilePicker.saveFile`; on web it triggers a browser download via a platform-conditional import (`download_service_web.dart` / `download_service_stub.dart`).

## Known pre-existing lint warnings (do not suppress)

Seven `info`-level warnings from `flutter analyze`, all pre-existing:
- `constant_identifier_names` on `Unit.Grammi`, `Unit.Pezzi`, `Unit.Litri`
- Deprecated `Share`/`shareXFiles` in `import_export_service.dart`
- Deprecated `groupValue`/`onChanged` on `RadioListTile` in `settings.dart`
