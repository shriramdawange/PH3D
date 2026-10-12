# Runtime smoke-test checklist — 3D renderer checkpoint

Goal: confirm the Phase 2 integration renders at runtime. Do NOT claim
rendering is verified until a human (or device lab) completes the
rendering rows below. CI build success ≠ rendering success.

Targets: Chrome + Edge (Web release or `flutter run -d chrome/edge`),
physical Android device (debug APK from CI artifact `android-debug-apk`).
Windows is expected to show the explicit unsupported-platform state.

## A. Web (Chrome, then repeat on Edge)

- [ ] A1. Open the app. Catalogue lists Limit Test of Chloride and
      Benzocaine Synthesis with correct semester/subject labels.
- [ ] A2. Chloride → Start pre-lab MCQ → answer all correctly → PASSED →
      Enter interactive lab.
- [ ] A3. Lab shows `INTERACTIVE 3D — orbit/zoom the scene below`,
      the chloride scene path, and a `Loading 3D scene…` indicator that
      disappears (progress % may flash first).
- [ ] A4. A rendered 3D shape is visible (placeholder triangle geometry —
      NOT a bench; that is expected). Drag to orbit, scroll/pinch to zoom.
- [ ] A5. No `3D scene failed to load` card. If it appears: record the
      exact error text, use Retry once, record whether it recovers.
- [ ] A6. Typed equipment chips work (tap Nessler cylinder A → highlighted).
- [ ] A7. Complete procedure steps 1→2→3 in order; observations panel gains
      SIMULATED entries; Preview practical report shows chloride-only fields
      (`sample_vs_standard_observation`, no `simulated_yield`).
- [ ] A8. Leaving test (disposal): from the lab, Back to catalogue, reopen
      the SAME practical (fresh MCQ → new session), confirm the 3D scene
      loads again with no stale overlay, duplicate viewports, or console
      errors (DevTools console open during all steps; record any red text).

## B. Android device (CI debug APK)

- [ ] B1–B7. Repeat A2–A8 on the physical device (Chrome DevTools
      unavailable; record visible behavior + any crash/ANR).
- [ ] B8. Rotate the device / background-foreground the app on the lab
      screen; reopen the practical; scene must reload cleanly.

## C. Cross-practical isolation, both orders

- [ ] C1. Order 1: Chloride (set quantities, select equipment, complete a
      step) → Back → Benzocaine (fresh MCQ/session) → assert: no chloride
      materials/equipment/steps/observations; scene path is the benzocaine
      GLB; report shows `simulated_yield`, NOT
      `sample_vs_standard_observation`.
- [ ] C2. Order 2: reverse of C1; assert the mirror image.
- [ ] C3. Open an invalid practical route (e.g. deep-link `/lab` with a bogus
      ID if applicable): explicit failure, no silent fallback page.

## D. Negative / platform states

- [ ] D1. Windows build: lab shows `3D NOT SUPPORTED ON THIS PLATFORM`
      with platform + practical ID, Back works, rest of journey usable.
- [ ] D2. Airplane-mode load (Android or Web offline after first install):
      record the exact error card text and Retry behavior.

## Recording results

For each row: pass/fail, target + version (e.g. `Chrome 154`), app source
(CI run id / artifact), and verbatim error text for failures. File defects
with: reproduction order, console/logcat excerpt, and whether Retry or
session reset recovered. A defect fix must add a regression test and keep
all 20 existing tests green.
