# Phase 2 report — controlled renderer integration

Source of truth: `docs/PHASE_1_5.md` + code at Phase 1.5 HEAD.
Original README preserved. No chemistry content touched.

## Compatibility gate (verified before adopting)

- `flutter pub add flutter_3d_controller:^2.3.0` resolved cleanly on
  Flutter 3.47.1 / Dart 3.13.1 — no SDK constraint conflict.
  Pinned: `flutter_3d_controller 2.3.0` (exact), transitive
  `flutter_inappwebview 6.1.5`, `http 1.6.0`, `web 1.1.1`.
- Installed-source review (2.3.0):
  - `Flutter3DViewer(src, controller, onProgress, onLoad, onError,
    enableTouch, activeGestureInterceptor)`; `src` supports Flutter
    asset pathnames (`assets/*.glb`); onLoad/onError channels on
    mobile + web.
  - `Flutter3DController` has NO `dispose()`; the viewer's own
    `State.dispose()` disposes `controller.onModelLoaded`. Adapter
    therefore creates one controller per viewport in `initState`,
    never shares it, never disposes it manually.
  - Declared platforms: Android, iOS, macOS, Web. Windows "Coming
    Soon" (package README). Transitive `flutter_inappwebview_windows`
    registers a native plugin, but the package has no Windows viewer
    branch, so Windows stays an explicit unsupported state.
- `flutter.minSdkVersion` default is 24 (FlutterExtension.kt) ≥ the
  package's minSdk 21 requirement — no `app/build.gradle` change.
- Local Windows note: `flutter pub` warns about missing symlink/
  Developer Mode (plugin symlinks); harmless — no local build is run,
  CI builds on hosted runners.

## What changed

- `lib/features/laboratory/rendering/renderer_adapter.dart`:
  `RendererAdapter` stays a `StatelessWidget` base; new stateful
  `_ModelViewerViewport` owns the viewer lifecycle inside
  `ModelViewerAdapter` (`rendererKind: 'model_viewer'`); new
  `UnsupportedPlatformAdapter` (`rendererKind: 'unsupported_platform'`);
  shared `EquipmentChips` typed actions; `RendererRegistry.resolve`
  gains optional `platformOverride` (Android/iOS/macOS/Web → real 3D;
  Windows/Linux → explicit unsupported; `temporary` preserved for
  tests; unknown kinds throw).
- `lib/features/catalogue/data/practicals_catalogue.dart`: both scenes
  → `rendererKind: 'model_viewer'` with practical-specific assets
  (`assets/models/chloride_bench_placeholder.glb`,
  `assets/models/benzocaine_bench_placeholder.glb`).
- `assets/models/`: two generated placeholder GLBs (732/736 bytes).
  Valid glTF 2.0 binaries (magic/version/length/JSON/BIN verified by
  re-parse); single-triangle geometry authored in-repo, treated as
  CC0. Labelled in-UI as placeholder geometry, NOT lab benches.
- `pubspec.yaml`: dep + `assets/models/` block. `pubspec.lock`: resolved.
- `web/index.html`: `<model-viewer>` script tag (path verified to exist
  in package assets: `model_viewer.min.js`, 931 KB).
- `android/.../AndroidManifest.xml`: INTERNET permission (per package
  README). `usesCleartextTraffic` deliberately NOT set — local-asset
  models need no cleartext HTTP.
- `windows/flutter/generated_*`: regenerated registrant (transitive
  webview plugin entry) — committed so the Windows build keeps working.
- `test/widget_flow_test.dart`: LabShell test forces
  `TargetPlatform.windows` (try/finally reset) and expects the explicit
  unsupported state (flutter_test defaults to Android, which would
  resolve the real WebView-backed adapter — unpumpable in tests).
- `test/renderer_registry_test.dart` (new, 7 tests, WebView-free):
  supported→real adapter, Windows/Linux→unsupported, temporary→labelled
  renderer, unknown kind→throws, cross-practical scene/identity
  isolation, unsupported-state pump, temporary tap-action pump.

## Verification (actual)

- `dart format lib test` — clean (1 file reformatted, re-verified).
- `flutter analyze` — No issues found.
- `flutter test` — 20/20 passed (10 isolation + 3 widget-flow + 7 new).
- GLB validity — structural re-parse checks passed (see above).
- No local `flutter build`; Android debug APK + web release covered by
  CI (`verify` → `build-android` / `build-web`).

## Exit criteria vs reality

- Real 3D model loads on ≥1 verified target: integration is code- and
  asset-complete for Android/Web, but NOT yet runtime-observed (no
  device run, no CI run yet). First green CI build + an Android/Web
  smoke check remain the proof.
- Unsupported targets fail visibly: yes (dedicated state, tested).
- Session isolation intact: yes (10 isolation tests + adapter identity
  tests green; renderer emits equipment IDs only).
- Existing tests pass: yes, 13/13 preserved (one expectation updated to
  the intended new desktop state), 7 added.

## Unresolved / do NOT claim

- Full interactive laboratory functionality is NOT claimed: equipment
  interaction is typed UI, not 3D hotspots; UI states this explicitly.
- Placeholder GLBs are geometry stand-ins, not bench scenes; real
  educator-approved bench models + asset licensing still open.
- First CI run on hosted runners still pending (no push this phase).
