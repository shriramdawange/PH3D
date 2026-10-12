# Phase 1 status — smallest runnable vertical slice

Date: 2026-10-12. Toolchain: Flutter 3.47.1, Dart 3.13.1.
Targets available: Windows (desktop), Chrome/Edge (web). Android enabled via config.

## Implemented
- Fresh Flutter project `pharmacy_3d_lab` scaffolded in place; existing
  `README_Fresh_Flutter_App (1).md` preserved (flutter also wrote `README.md`).
- Stable IDs (`lib/core/ids.dart`), immutable `PracticalDefinition` with
  `validate()`, authoritative `PracticalRegistry` (unique IDs, deterministic
  sortOrder→id ordering, explicit `UnknownPracticalException`).
- Two practicals: `pharm_inorganic.limit_test_chloride` (sortOrder 10),
  `medicinal_chemistry.benzocaine_synthesis` (sortOrder 20).
- Per-attempt isolated `LabSession` + `LabSessionManager` (no global mutable
  material/step/result lists); `LabLauncher` single validated launch path with
  duplicate-tap guard.
- Journey: Catalogue (semester/subject filter) → Overview → MCQ gate
  (practical-specific, RadioGroup) → shared LabShell (renderer + materials with
  explicit units + ordered procedure + simulated observations) → Report preview
  from immutable snapshot.
- Renderer boundary: `RendererAdapter` + `RendererRegistry`; only
  `TemporaryRendererAdapter` registered, UI labels it
  "TEMPORARY RENDERER — real interactive 3D not yet implemented."
  Non-temporary `rendererKind` throws instead of silent fallback.
- Procedure/unit validation, deterministic simulation (qualitative only),
  practical-specific report schemas.
- Tests: `test/isolation_test.dart` (10 unit/isolation tests incl. reverse-order
  leakage + third-practical ordering) and `test/widget_flow_test.dart` (3 widget
  tests). GitHub Actions web pipeline in `.github/workflows/web.yml`.

## Incomplete / placeholders (explicit, not misrepresented)
- Real interactive 3D NOT implemented — temporary renderer only. Needs verified
  package selection (model_viewer_plus / flutter_3d_controller compatibility
  check vs Flutter 3.47 + web/Windows) + educator-approved glTF assets.
- Scientific content is structural only; quantitative chemistry marked
  `REQUIRES_EDUCATOR_REVIEW`. No concentrations/volumes/temps/yields invented.
- Report export (PDF/share) not implemented — preview only.
- No persistence/resume of sessions; reset = new session.
- No elaborate theming/animation (per README priority).

## Verification (actual)
- `flutter analyze`: No issues found (after fixing import paths, RadioGroup
  deprecation, typing).
- `flutter test`: All 13 tests passed.
- `dart format --output=none --set-exit-if-changed .`: reports 18 files would
  change (style only); left unformatted to avoid noisy diff.
- `flutter build` NOT run locally per owner instruction (build on GitHub
  Actions web pipeline instead).
