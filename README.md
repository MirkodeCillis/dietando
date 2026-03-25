# Dietando

Inserisci gli alimenti della tua dieta, imposta le quantità già presenti in casa e ottieni la lista della spesa settimanale pronta all'uso.

> Il progetto nasce come esplorazione pratica di Flutter. L'autore ha voluto costruire un'applicazione completa usando il framework, ma il risultato è comunque funzionale.

---

## Funzionalità

- **Piano pasti** — organizza i pasti della settimana (colazione, pranzo, cena e spuntini) per ciascun giorno, selezionando gli alimenti dalla dieta.
- **Inventario** — gestisci il magazzino di alimenti con target settimanale e stock attuale. Indicatore visivo del livello di scorte.
- **Spese extra** — lista di articoli non legati alla dieta (es. detersivi, prodotti per la casa).
- **Lista della spesa** — generata automaticamente dalla differenza tra target settimanale e stock attuale, raggruppata per categoria e ordinata per priorità. Include anche le spese extra non ancora acquistate.
- **Importa / Esporta** — backup e ripristino completo dei dati in formato JSON.
- **Tema** — Light, Dark o System.
- **Lingua** — Italiano, English, Español, Français, Deutsch.

---

## Stack tecnico

| Libreria | Scopo |
|---|---|
| `flutter_riverpod` | State management (AsyncNotifier + Provider) |
| `go_router` | Navigazione dichiarativa |
| `shared_preferences` | Persistenza locale dei dati |
| `flutter_localizations` + `intl` | Internazionalizzazione (i18n) |
| `file_picker` + `share_plus` | Import/export JSON |
| `path_provider` | Accesso al filesystem |
| `flutter_launcher_icons` | Generazione icone |
| `flutter_native_splash` | Splash screen nativa |

---

## Prerequisiti

- [Flutter SDK](https://flutter.dev/docs/get-started/install) — canale **stable**
- `flutter` disponibile nel PATH
- Per Android: Android SDK e un dispositivo/emulatore connesso
- Per iOS: Xcode e un simulatore o dispositivo fisico

---

## Installazione e setup

### 1. Dipendenze

```bash
flutter pub get
```

### 2. Generazione del codice i18n

I file `lib/l10n/app_localizations*.dart` sono **generati** a partire dai file ARB in `lib/l10n/` e sono esclusi dal repository (`.gitignore`). Vanno rigenerati dopo ogni `pub get` o modifica agli ARB:

```bash
flutter gen-l10n
```

> Questo comando legge `l10n.yaml` alla radice del progetto e produce `lib/l10n/app_localizations.dart` e i file per ogni lingua (`app_localizations_it.dart`, `app_localizations_en.dart`, ecc.).
>
> **Non modificare questi file a mano** — vengono sovrascritti ad ogni esecuzione.

### 3. Avvio

```bash
flutter run
```

Per il browser:

```bash
flutter run -d chrome
```

---

## Internazionalizzazione (i18n)

Le traduzioni si trovano in `lib/l10n/` come file ARB:

| File | Lingua |
|---|---|
| `app_en.arb` | English (template) |
| `app_it.arb` | Italiano |
| `app_es.arb` | Español |
| `app_fr.arb` | Français |
| `app_de.arb` | Deutsch |

`app_en.arb` è il template: contiene le chiavi con metadati (`@chiave`). Gli altri file contengono solo le traduzioni.

Per aggiungere una lingua:
1. Crea `lib/l10n/app_XX.arb` (dove `XX` è il codice BCP 47, es. `pt`)
2. Aggiungi `Locale('XX')` alla lista `supportedLocales` in `lib/main.dart`
3. Aggiungi l'opzione nel selettore lingua in `lib/pages/settings.dart`
4. Esegui `flutter gen-l10n`

---

## Build

### Android (AAB per Play Store)

```bash
flutter build appbundle
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Android (APK)

```bash
flutter build apk --release
```

### iOS (richiede Xcode su macOS)

```bash
flutter build ipa
```

---

## Icone e splash screen

Le icone sono gestite tramite `flutter_launcher_icons`. Dopo aver modificato `assets/icon/app_icon.png`:

```bash
dart run flutter_launcher_icons
```

Per rigenerare la splash screen nativa:

```bash
dart run flutter_native_splash:create
```

---

## Analisi statica

```bash
flutter analyze
```

Il progetto usa `flutter_lints`. Non ci sono errori; eventuali warning residui (`constant_identifier_names`, API deprecate) sono pre-esistenti nei modelli e nelle dipendenze.

---

## Testing

Il progetto dipende da `flutter_test` ma non ha ancora una suite di test. Per eseguire i test quando presenti:

```bash
flutter test
```
