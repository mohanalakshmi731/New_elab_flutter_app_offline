# eLabs / MathZoro — Flutter app

Flutter port of the `new-elab-web-app` (Vue 3) for **Windows, macOS, Android and iOS**.
One codebase, two flavors — exactly like the web app's `VITE_IS_MATHZORO` switch:

| Flavor | Run with | Who uses it | Entry route |
|---|---|---|---|
| **eLabs** | `--dart-define-from-file=.env` | admin, institute, instructor, student | `/login` → `/dashboard` |
| **MathZoro** | `--dart-define-from-file=.env --dart-define=IS_MATHZORO=true` | MathZoro students | `/mathzorostudentlogin` → `/newlayout/studentdashboard` |

Porting progress and conventions: see **[PORTING.md](PORTING.md)**.

## Status

All screens of the web app are ported (see `PORTING.md` for the phase table, the web bugs
that were deliberately kept, and follow-ups). Not yet exercised end-to-end against the live
API; macOS/iOS have not been built (they need a Mac with Xcode).

Release builds made on the dev machine are copied to `build/dist/windows-elabs/`,
`build/dist/windows-mathzoro/` (copy the whole folder to another PC) and
`build/apk/eLabs-release.apk`, `build/apk/MathZoro-release.apk` (signed with the debug key —
fine for testing, not for the Play Store).

## Prerequisites

- Flutter **3.41+** (Dart 3.11)
- Windows builds: Visual Studio 2022 with "Desktop development with C++". The embedded
  web activities use **WebView2** (built into Windows 11; on Windows 10 install the
  [Evergreen runtime](https://developer.microsoft.com/microsoft-edge/webview2/)).
  Keep the checkout in a **short path** (e.g. `D:\Tedlance\new-elab-flutter-app`): deep
  folders hit the Windows 260-character path limit during the native plugin build.
- Android builds: Android SDK (platform 36, build-tools 35, NDK 28.2) — `flutter doctor`
  must be green. The first build downloads Gradle and its dependencies (~2 GB); to keep
  them off a small system drive, set the user environment variables `GRADLE_USER_HOME`
  and `PUB_CACHE` to a folder on another drive (on the dev machine they point at
  `D:\DevCaches\gradle` and `D:\DevCaches\pub-cache`). `android/gradle.properties`
  caps the Gradle heap at 3 GB so builds fit on an 8 GB machine.
- iOS / macOS builds: a Mac with Xcode 16+ and CocoaPods.

## Configuration

All build-time values live in one `.env` file in the project root, passed to Flutter with
`--dart-define-from-file=.env`. Values are compiled in, so after editing `.env` stop the
app and start it again (hot reload/restart does not pick up changes).

```sh
# BASE_URL= 'https://new-elab-e4akcrhfetbfdkh0.centralindia-01.azurewebsites.net'   # dev
BASE_URL= https://new-elab-prod-dxbpendvg0athmdw.centralindia-01.azurewebsites.net   # production
REVERB_SCHEME= 'wss'
REVERB_HOST= 'reverb-fycabjfpaxana0b8.centralindia-01.azurewebsites.net'
REVERB_APP_KEY= '…'
REVERB_PORT= '443'
PROCTOR_AI_URL=https://proctorai-gph2b7fzh5bjhqe6.centralindia-01.azurewebsites.net
```

Switch servers by commenting/uncommenting the `BASE_URL` lines.

| Key | Web equivalent |
|---|---|
| `BASE_URL` | `VITE_API_BASE_URL`; the API root (`VITE_API_ENDPOINT`) is `BASE_URL` + `/api/v1` |
| `REVERB_APP_KEY`, `REVERB_HOST`, `REVERB_PORT`, `REVERB_SCHEME` | `VITE_REVERB_*` (`REVERB_SCHEME` accepts `wss`/`ws` or `https`/`http`) |
| `PROCTOR_AI_URL`, `PROCTOR_AI_ENABLED`, `PROCTOR_ANALYZE_INTERVAL_MS` | `VITE_PROCTOR_AI_*`, `VITE_PROCTOR_ANALYZE_INTERVAL_MS` (optional: proctoring is on unless `PROCTOR_AI_ENABLED` is 0/false/no/off; interval defaults to 2500 ms) |
| `WEB_APP_ORIGIN` | optional — `window.location.origin`, the web front-end's address used in invite links (`/signup?code=…`); falls back to `BASE_URL` |
| `IS_MATHZORO` | `VITE_IS_MATHZORO` — pass `--dart-define=IS_MATHZORO=true` on the command line for the MathZoro app |
| `CLASS_ID` | not read by the app (Math/Science Zone use the logged-in user's class) |

`.env` is git-ignored. Starting the app without it shows a "configuration missing" screen.

## Run

```sh
flutter pub get

# eLabs
flutter run -d windows --dart-define-from-file=.env
flutter run -d macos   --dart-define-from-file=.env
flutter run            --dart-define-from-file=.env      # Android / iOS device

# MathZoro
flutter run -d windows --dart-define-from-file=.env --dart-define=IS_MATHZORO=true
```

VS Code users: pick a configuration from `.vscode/launch.json` (eLabs / MathZoro).

## Build releases

```sh
flutter build windows   --release --dart-define-from-file=.env
flutter build apk       --release --dart-define-from-file=.env
flutter build appbundle --release --dart-define-from-file=.env
flutter build ios       --release --dart-define-from-file=.env   # on a Mac
flutter build macos     --release --dart-define-from-file=.env   # on a Mac
```

Add `--dart-define=IS_MATHZORO=true` for the MathZoro app. Both flavors write the APK to the same
`build/app/outputs/flutter-apk/app-release.apk`, so copy it away before building the other.

- **Android** reads the flavor from `IS_MATHZORO`: eLabs builds as `com.tedlance.elabs` ("eLabs"),
  MathZoro as `com.tedlance.mathzoro` ("MathZoro"), so both install side by side.
  Release builds are still signed with the debug key — add a signing config in
  `android/app/build.gradle.kts` before publishing.
- **Windows / macOS**: the window title follows the flavor. Bundle id / exe name are shared;
  if both apps must be installed on the same Mac, add per-flavor xcconfig files (Xcode).
- **iOS**: set the team and bundle id in Xcode before the first device build.

### App icons

The icons are made from the same logos the web app uses (`branding/elabs_logo.png` =
web `elabsLogo.png`, `branding/mathzoro_logo.png` = web `mathzorologo.png`). To change
one, replace the image and run `python tool/make_icons.py` (needs `pip install pillow`).

- **Android**: picked by `IS_MATHZORO`, like the app id: `android/app/src/elabs/res` or
  `src/mathzoro/res` (adaptive icon on Android 8+, plain icon on Android 7).
- **Windows**: picked by `IS_MATHZORO`: `windows/runner/CMakeLists.txt` spots
  `IS_MATHZORO=true` and `Runner.rc` embeds `app_icon_mathzoro.ico` instead of
  `app_icon.ico` (exe, window and taskbar icon; also the name shown in Task Manager).
- **iOS / macOS**: `AppIcon` is eLabs and is the one used. `AppIcon-MathZoro` is ready
  next to it; for a MathZoro build, set the target's *App Icon* build setting
  (`ASSETCATALOG_COMPILER_APPICON_NAME`) to `AppIcon-MathZoro` in Xcode, together with the
  MathZoro bundle id and name.

## Tests

```sh
flutter analyze
flutter test
```

## Project layout

```
lib/
  main.dart, app.dart          # main.ts / App.vue — session restore, theme, toasts, router
  core/
    config/env.dart            # .env (import.meta.env)
    network/api_client.dart    # src/service/Axios.ts (token, toasts, 401 → logout)
    network/upload_file.dart   # File + FormData replacement
    realtime/echo_client.dart  # Laravel Echo / Reverb (private, presence, public channels)
    storage/secure_store.dart  # encrypt-storage (Keychain / Keystore / DPAPI)
    theme/                     # style.css tokens + Tailwind palette (Tw.*)
    utils/                     # toast (vue-sonner), json helpers, external links (window.open, Zoom)
  data/
    models/session.dart        # userInfo, studentLoginData, roles
    services/                  # src/service/*.ts — 1:1, same method names (199 methods)
  state/                       # Pinia: session controller, color mode, providers
  router/app_router.dart       # src/router/index.ts + mathzoro.ts (+ route guard)
  features/                    # screens, one folder per area
  widgets/                     # loader.vue, cards, glass card, WebContentView (<iframe>)
test/
```

## Behaviour differences from the web app

- **Zoom**: meetings open in the installed Zoom app (or the browser) instead of the
  embedded Zoom Web SDK — no Flutter Zoom SDK supports all four platforms.
- **Session**: kept in OS secure storage, so users stay signed in after restarting the app
  (the web used sessionStorage, which ends with the tab). Logout or any HTTP 401 clears it.
- **Route guard**: unauthenticated users are sent to the login screen (the web relied on the
  API's 401). MathZoro students are kept inside `/newlayout`, as on the web.
- **Embedded content** (`<iframe>`): rendered with a native WebView
  (WKWebView / Android WebView / WebView2).
