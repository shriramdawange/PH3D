# Phase 1.5 report — baseline protection, CI coverage, 3D evaluation

No app rewrite. Temporary renderer untouched. All 13 tests preserved.

## 1. Git baseline

- `191d4f9` — Phase 1 baseline (73 files, incl. preserved
  `README_Fresh_Flutter_App (1).md`).
- `13d76fa` — `dart format lib test` output (18 files, layout only).
- `15781bb` — CI rework (`.github/workflows/web.yml`).
- Excluded from tracking by `.gitignore`: `build/`, `.dart_tool/`,
  `.idea/`, `*.iml`. `pubspec.lock` is tracked (standard for apps).

## 2. Formatting + regression verification (actual runs)

- `dart format lib test` — 18 files changed.
- `flutter analyze` — No issues found.
- `flutter test` — All 13 tests passed (10 isolation/unit +
  3 widget-flow).
- Diff inspection (`simulation_engine.dart`, `main.dart`, spot checks):
  trailing commas, import grouping, line wraps only. No string, logic,
  or API change. Behavior preservation evidenced by clean analyze +
  13/13 pass.
- No local `flutter build` run, per owner instruction.

## 3. CI changes (`.github/workflows/web.yml`, workflow `ci`)

Preserved: Flutter 3.47.1 via `subosito/flutter-action@v2`,
`flutter --version` stamp, analyze + test gates, web build with
`--no-tree-shake-icons`, no deployment.

- `verify` job: format check (`dart format --output=none
  --set-exit-if-changed lib test`), `flutter analyze`, `flutter test`.
- `build-android` job (needs `verify`, `ubuntu-latest`,
  Temurin JDK 17 to match Gradle 9.3.1 / JVM 17 target):
  `flutter build apk --debug`, uploads `android-debug-apk`
  (`build/app/outputs/flutter-apk/app-debug.apk`).
- `build-web` job (needs `verify`): `flutter build web --release
  --no-tree-shake-icons` (release, was profile), uploads `web-release`
  (`build/web/`).
- No release publishing or deployment configured.

## 4. Verified 3D renderer comparison (pub.dev API + package pages)

| Option | Latest (verified) | License | Platforms | Flutter/Dart compat | Notes |
|---|---|---|---|---|---|
| `flutter_3d_controller` 2.3.0 (verified publisher `mobilesoft98.dev`, 378 likes, 140 pts) | Sep 2025 | MIT | Android, iOS, macOS (beta), Web. Windows: "Coming Soon" (unsupported) | `flutter >=3.27.0`, `sdk >=3.6.0 <4.0.0` — compatible with 3.47.1 / 3.13.1 | Google `<model-viewer>` core; `Flutter3DViewer` + `Flutter3DController`; `onProgress`/`onLoad`/`onError`, camera/animation/texture APIs, gesture interceptor; GLB + glTF (+OBJ); needs `web/index.html` script tag, Android INTERNET permission, minSdk 21 |
| `model_viewer_plus` 1.10.0 (unverified uploader, 338 likes, 150 pts, 31.5k/wk) | Nov 2025 | Apache-2.0 | Android, iOS, Web only | `flutter >=3.38.0`, `sdk ^3.10.0` — compatible | Same `<model-viewer>` core, glTF/GLB; **no controller API** (no loading-state callbacks/disposal hooks for our boundary); fallback candidate |
| `o3d` 3.1.3 | Dec 2024 (~22 mo stale) | — | Android, iOS, Web | Broad, but stale | Rejected: unmaintained |
| Native Windows path (e.g. Filament-based) | No package verified this phase | — | — | — | Windows has **no** verified webview-based option; needs separate spike |

## 5. Recommendation

**`flutter_3d_controller` 2.3.0 for Android (primary) + Web**,
behind the existing `RendererAdapter` boundary, keeping
`TemporaryRendererAdapter` for **Windows** via platform-conditional
resolution in `RendererRegistry` (explicit config, never silent
fallback). Evidence: only maintained option with a controller API that
maps onto our contract (loading progress/errors, typed actions,
session updates, disposal); MIT license; verified publisher;
compatible SDK constraints; platform coverage matches CI targets
(Android + Web).

## 6. Phase 2 file plan (no code changed this phase)

1. `pubspec.yaml` (+ `pubspec.lock`): add `flutter_3d_controller: ^2.3.0`.
2. `lib/features/laboratory/rendering/model_viewer_adapter.dart` (new):
   `ModelViewerAdapter extends RendererAdapter` (`rendererKind:
   'model_viewer'`), owns `Flutter3DController`, dispose in
   `State.dispose`, surfaces `onProgress`/`onError` as retry UI.
3. `lib/features/laboratory/rendering/renderer_adapter.dart`:
   `RendererRegistry.resolve` gains platform check
   (`kIsWeb` / `defaultTargetPlatform`) + new `rendererKind` branch.
4. `lib/features/catalogue/data/practicals_catalogue.dart`: scene configs
   gain real `sceneAsset` GLB keys per practical (assets still required).
5. `assets/models/` (new) + `pubspec.yaml` assets block: educator-approved
   GLB bench scenes (not yet sourced).
6. `web/index.html`: `<model-viewer>` script tag.
7. `android/app/src/main/AndroidManifest.xml`: INTERNET permission
   (verify at build time).
8. `test/`: keep all 13 green (webview widget stays out of widget tests;
   temporary adapter remains the test renderer); add adapter-resolution
   unit tests (platform-conditional branches, unknown-kind errors).
9. `.github/workflows/web.yml`: unchanged expected (Android APK exercises
   the real adapter compile path).

## 7. Blockers / unverified claims

- `Flutter3DController` dispose semantics and widget-test behavior
  (webview in `flutter test`) unverified — Phase 2 spike required.
- `flutter_inappwebview ^6.1.5` transitive resolution against Flutter
  3.47.1 unverified until `flutter pub add` runs.
- No GLB bench assets exist (`assets/` directory absent); educator review
  + asset licensing still open. No chemistry content changes proposed.
- CI workflow not yet executed on GitHub-hosted runners (no remote/push
  performed this phase); first green run must confirm JDK 17 + Gradle
  9.3.1 + `flutter build apk --debug`.
- Windows real-3D path has no verified package; temporary renderer on
  Windows is the honest interim state, not a gap to hide.
