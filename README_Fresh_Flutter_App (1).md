# Virtual Pharmaceutical Laboratory --- Fresh Flutter App Master README

> **Project:** Fresh Flutter implementation of an interactive 3D virtual
> pharmaceutical laboratory. **Initial practicals:** Limit Test of
> Chloride; Benzocaine Synthesis. **Primary objective:** A clean,
> modular app in which adding a practical does not break another
> practical's catalogue order, materials, UI, 3D scene, procedure,
> simulation, or report. **Build rule:** Inspect the machine and
> supported Flutter toolchain before choosing packages or claiming
> compatibility.

------------------------------------------------------------------------

## 1. Product vision

Build a responsive Flutter application for pharmacy students to learn
pharmaceutical practicals through an interactive virtual laboratory.

Student flow:

1.  Select semester.
2.  Select subject.
3.  Select practical.
4.  Complete the practical-specific pre-lab MCQ assessment.
5.  Enter the interactive lab.
6.  Select allowed chemicals/materials and equipment.
7.  Enter quantities with explicit units.
8.  Follow validated, ordered procedure steps.
9.  Receive simulated observations, results, calculations, and
    explanations for mistakes.
10. Review and export a practical report.

Initial content: - Pharmaceutical Inorganic Chemistry --- Limit Test of
Chloride. - Medicinal Chemistry --- Benzocaine Synthesis.

The architecture must support additional medicinal chemistry practicals
without adding special cases across unrelated UI files.

This is an educational simulation, not a substitute for supervised
physical laboratory work. All generated results must be labelled as
simulated. Scientific content must be reviewed by a qualified educator.

## 2. Product requirements

### Student-facing features

-   Semester/subject/practical catalogue with stable ordering.
-   Practical overview, learning objectives, and prerequisites.
-   Practical-specific MCQ assessment, score, feedback, and retry
    policy.
-   Interactive 3D lab scene, equipment selection, and visual
    interaction feedback.
-   Practical-specific material inventory and validated
    quantities/units.
-   Step-by-step procedure with progress, prerequisites, and validation.
-   Simulated consequences and explanations for incorrect steps.
-   Observations/results panel.
-   Report preview and supported export.
-   Clear loading, empty, invalid-configuration, and recoverable-error
    states.
-   Responsive UI and accessible textual explanations for key 3D
    interactions.

### Quality requirements

-   No cross-practical state or material leakage.
-   No unstable ordering when a practical is added.
-   No silent navigation to an unrelated ordinary page.
-   No fabricated chemistry or measurements.
-   No unverified claims that the app is production-ready.
-   Tests for catalogue, navigation, isolation, simulation, and reports.

## 3. Mandatory first step: inspect the development environment

Before scaffolding or selecting dependencies, inspect: - Flutter and
Dart versions. - Available desktop/web/mobile targets. - Git status and
current directory. - Whether a project already exists in the target
directory. - Available emulator/device targets. - Current package
constraints and any supplied designs/assets.

Never overwrite an existing project or user files without explicit
approval. If this is a truly new, empty directory, create a standard
Flutter app. Record the selected target platforms and any 3D capability
limitations.

Do not choose a 3D package just because it is popular. Check current
compatibility with the installed Flutter/Dart version, target platforms,
licensing, asset format, and lifecycle support. Use the simplest
supported rendering approach that meets the actual requirements; isolate
it behind an adapter so it can be changed later.

## 4. Architecture

Prefer a lightweight, feature-first structure with a clear separation of
domain logic, UI, and data. Adapt naming to the project's conventions
without adding layers that have no purpose.

Suggested structure:

``` text
lib/
  main.dart
  app/
    app.dart
    router.dart
    theme/
  core/
    errors/
    validation/
    ids/
    units/
  features/
    catalogue/
      data/
      domain/
      presentation/
    assessment/
      data/
      domain/
      presentation/
    laboratory/
      data/
      domain/
      presentation/
      rendering/
    procedure/
      domain/
    simulation/
      domain/
    reports/
      data/
      domain/
      presentation/
  shared/
    widgets/
    models/
assets/
  practicals/
  models/
  textures/
  icons/
test/
  unit/
  widget/
  integration/
docs/
  ARCHITECTURE.md
  CONTENT_AUTHORING.md
  TEST_PLAN.md
```

This is a proposed layout, not a requirement to create empty folders.
Keep the project small and purposeful. Add dependencies only when
justified.

## 5. Core domain contracts

### Stable IDs

Each practical must have a unique stable ID independent of its display
name or catalogue position. Suggested examples:

``` dart
const chlorideTestId =
    'pharm_inorganic.limit_test_chloride';

const benzocaineSynthesisId =
    'medicinal_chemistry.benzocaine_synthesis';
```

Check for existing IDs before adoption. Do not use list indices or
display titles as identity. Do not generate new IDs at runtime.

### PracticalDefinition

Create an immutable, validated definition containing or referencing: -
ID and content version - title, semester, subject, practical type -
description and learning objectives - assessment definition - allowed
material/chemical IDs, units, and reviewed constraints - equipment IDs -
ordered procedure steps with stable step IDs - simulation
configuration - scene/renderer configuration - report schema/template -
content review status

Use typed Dart models. JSON assets can be used for content where that is
helpful, but validate and parse them into typed models. Keep executable
business rules in code rather than arbitrary strings. Avoid complex code
generation unless there is a demonstrated need.

### PracticalRegistry

Use one authoritative registry/repository to resolve definitions by
stable ID. Validate: - unique IDs - non-empty required fields - valid
subject/semester references - valid
assessment/material/equipment/step/scene/report references - unique step
IDs and deterministic step ordering - supported practical/renderer types

Invalid configuration must produce a descriptive error with the
practical ID and field. It must never silently use another practical's
definition.

### LabSession

Every attempt creates a new session with: - session ID - immutable
practical ID - start time and status - assessment attempt/result -
current step ID - selected material IDs and quantities - equipment
state - observations and simulation events/results - warnings and
validation errors - completion state - report snapshot/version

No global mutable lists for active materials, steps, results,
observations, or report fields. Session reset and disposal must affect
only that session. Every action must validate against the session's
definition. Saved sessions, if implemented, must validate schema version
and practical identity on resume.

## 6. State management and routing

First choose one state-management and routing approach appropriate to
the installed Flutter version and the project's size. Use existing
Flutter primitives or a well-supported package; do not combine multiple
competing state-management systems.

Requirements: - A single validated lab-launch service/path. - Explicit
practical ID passed through navigation. - No route resolution by
display-name substring or parallel-list index. - Fresh session per
attempt. - Stable back/exit/reset behavior. - Prevent duplicate launch
taps. - Keep unrelated catalogue, assessment, and 3D scene state from
rebuilding unnecessarily. - Dispose controllers, streams, and scene
resources at the correct lifecycle boundary. - Handle unknown practical
IDs and failed scene loads with visible error/retry UI.

Expected launch sequence:

``` text
Catalogue selection
  -> Resolve practical ID
  -> Validate definition
  -> Complete required MCQ gate
  -> Create session for that practical
  -> Resolve explicit renderer and scene
  -> Open shared LabShell
  -> Execute validated actions and simulation
  -> Build report from session snapshot
```

Never silently replace a failed 3D scene with an unrelated standard
page. If a deliberate non-3D fallback is approved, make it an explicit
configuration and label it to the student.

## 7. UI and visual direction

Create a clean, modern educational interface with: - Clear
semester/subject/practical navigation. - Readable typography and
consistent spacing. - A prominent 3D viewport on the lab screen. - A
practical-specific instruction/progress panel. - A material/equipment
interaction panel. - A results/feedback area. - Clear MCQ states and
report preview. - Useful loading, empty, retry, and validation states. -
Responsive layouts for the agreed targets.

Use a shared LabShell for common controls, but keep practical-specific
configuration separate. Do not create one huge widget with many
`if (practicalName == ...)` branches. Use typed configuration and a
small explicit renderer/interaction strategy registry for differences
that truly need custom behavior.

Do not spend the stabilization budget on elaborate animation or
decorative UI before the core journey and isolation tests work.

## 8. 3D rendering boundary

Keep the selected 3D technology behind a small interface/controller
boundary. The rest of the app should not depend directly on
renderer-specific classes.

The renderer adapter should support, as appropriate: - load the scene
associated with the active practical - loading progress and errors -
selecting/highlighting equipment - emitting typed user actions -
receiving session state updates - clean controller/scene disposal

Requirements: - Load practical assets lazily where appropriate. - Do not
reload the whole scene for an ordinary instruction-panel update. -
Prevent duplicate initialization on widget rebuild. - Keep scene and
asset references practical-specific. - Provide a clear retry state if
loading fails. - Check target-platform and package support before
promising full 3D behavior. - Never claim a working 3D lab if only a
static illustration or placeholder exists.

If full interactive 3D cannot be implemented reliably in the available
two-hour window, build and test the complete app flow with a clearly
labelled temporary renderer boundary, document the missing
implementation, and do not misrepresent it as finished. Do not
substitute an image for interactive 3D without explicit approval.

## 9. Procedure and simulation

Keep deterministic, testable experiment logic outside Flutter widgets.

Each step has a stable ID and explicit order, with optional
prerequisites, allowed actions, required materials/equipment,
validation, and completion criteria.

An action should return a structured result: - accepted/rejected -
affected step/session fields - reason and educational explanation -
warning/error code when relevant

The simulation engine must only use the active practical's reviewed
configuration. Invalid actions must not corrupt state. Units must be
explicit and incompatible units must not be combined. Reset and retry
behavior must be documented.

Do not invent exact reagent quantities, concentrations, temperatures,
times, reaction conditions, yields, melting points, observations, or
acceptance limits. Use supplied content or mark fields
`REQUIRES_EDUCATOR_REVIEW`. A simulated measurement must be identified
as simulated.

## 10. Initial practical content

### Limit Test of Chloride

Configure as an analytical-test practical, with its own: - assessment -
permitted materials and equipment - ordered procedure - reviewed
simulation rules - observation/result fields - report schema

### Benzocaine Synthesis

Configure as a synthesis practical, with its own: - assessment -
permitted materials and equipment - ordered procedure - reviewed
simulation rules - observation/result fields - report schema

Do not assume both practicals use the same fields, scene interactions,
calculations, or outcomes. Share common UI and infrastructure only where
appropriate. Scientific content must be sourced from the provided
educational material and approved by a qualified educator.

## 11. Assessment system

-   Link every question set to a stable practical ID.
-   Give each question and option a stable ID.
-   Store correct answer IDs and explanations in validated data.
-   Configure pass threshold, attempt policy, and required-gate behavior
    explicitly.
-   Do not let an assessment result from one practical unlock another.
-   Do not mutate the source question list when randomizing.
-   Test passing, failing, retry, empty and malformed assessments, and
    practical mismatch.

## 12. Reports

Build reports from a typed, immutable snapshot of the active LabSession
and its PracticalDefinition.

Common sections may include: - practical identity and metadata - aim and
learning objectives - reviewed theory/background - materials/equipment
actually used - procedure progress - simulated observations and
results - relevant calculations with units - practical-specific
measurements where applicable - deviations, mistakes, and explanations -
conclusion/learning notes - simulation disclaimer and generation
timestamp

Requirements: - Each practical owns its report schema/template. - Do not
show irrelevant fields from a different practical. - Do not fabricate
missing results. - Report preview and exported output must agree. -
Report generation must not mutate session state. - Export only formats
supported by chosen dependencies and targets; do not claim PDF export
until implemented and tested.

## 13. Testing plan

Use Flutter/Dart tests appropriate to the installed toolchain.

### Unit tests

-   Registry validation and duplicate IDs.
-   Stable ordering and subject/semester filtering.
-   Assessment scoring and unlock rules.
-   Allowed materials and unit validation.
-   Procedure transitions and invalid actions.
-   Session reset and isolation.
-   Deterministic simulation behavior.
-   Report construction from a session snapshot.

### Widget tests

-   Catalogue selection routes to the expected practical.
-   MCQ gate blocks/allows entry correctly.
-   LabShell shows the selected practical identity.
-   Missing scene/configuration shows a clear error.
-   Report preview contains the correct practical's fields.

### Critical cross-practical regression tests

1.  Open Limit Test of Chloride and change its session.
2.  Exit and open Benzocaine Synthesis.
3.  Assert no material, step, scene, result, or report leakage.
4.  Repeat in reverse order.
5.  Register an additional test practical and confirm existing order and
    definitions remain unchanged.
6.  Launch an invalid ID and confirm explicit failure.
7.  Dispose and reopen a scene; confirm no duplicate
    controller/resources.
8.  Generate both reports and compare their practical-specific fields.

Run, where supported:

``` bash
flutter --version
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

Only run commands appropriate to the supported target platforms and
installed environment. Record actual outputs and failures. Do not create
a noisy whole-repository formatting diff unnecessarily.

## 14. Two-hour MVP plan

**0--15 min:** Verify toolchain, project state, targets, and 3D package
options.

**15--30 min:** Create the minimum app structure, navigation, typed IDs,
registry, and core models.

**30--50 min:** Build semester → subject → practical catalogue and
practical overview/MCQ flow.

**50--75 min:** Build the shared lab shell and session isolation. Wire
the 3D renderer boundary; implement genuine 3D interaction only if the
selected package and assets make it feasible.

**75--95 min:** Add the two practical definitions with educator-reviewed
content or clearly marked content placeholders. Do not invent chemistry.

**95--110 min:** Build report preview from session snapshots and add
cross-practical tests.

**110--120 min:** Run analysis/tests/build as supported, inspect the
diff, document working features and gaps.

This is a prioritization plan, not a guarantee that full 3D assets,
scientifically validated content, export, and production quality can all
be delivered in two hours. Keep the build runnable and the remaining
work explicit.

## 15. OpenCode / coding-agent instruction

Build a fresh Flutter application based on this README, not a repair of
the separate Google AI Studio project.

First inspect the installed Flutter/Dart toolchain and working
directory. Preserve any existing files. If the directory is not empty,
stop before overwriting it and report the conflict.

Then implement in small vertical slices: 1. App shell, theme, and
navigation. 2. Stable practical definitions and registry. 3. Catalogue
and MCQ gate. 4. Session-scoped lab state and shared LabShell. 5.
Isolated practical configuration for the two initial practicals. 6.
Renderer adapter and actual 3D interaction where supported. 7.
Procedure/simulation rules based on verified educational content. 8.
Session-snapshot report preview/export. 9. Regression tests and docs.

Use this README as the requirements contract. Do not silently omit a
feature; identify implemented, partial, placeholder, and unimplemented
features separately. Do not claim interactive 3D is complete if only a
placeholder is present. Do not invent chemistry. Avoid unnecessary
dependencies, backend services, authentication, or cloud costs unless
the product owner asks for them.

After each slice, run relevant tests, inspect the diff, and report exact
verification results. If blocked, preserve the working state and explain
the blocker.

## 16. Definition of done

-   [ ] Fresh Flutter project runs on at least one agreed target.
-   [ ] Semester → subject → practical flow works.
-   [ ] Practical registry uses stable IDs and validated references.
-   [ ] Adding a practical does not reorder existing entries
    unexpectedly.
-   [ ] Each attempt gets isolated session state.
-   [ ] Both initial practicals use the correct configuration.
-   [ ] MCQ gating is practical-specific.
-   [ ] The lab screen clearly reports scene loading/errors; no silent
    unrelated fallback.
-   [ ] The supported 3D renderer is genuinely interactive or its
    incomplete status is explicit.
-   [ ] Procedure and simulation use reviewed practical configuration.
-   [ ] Reports are built from the correct session snapshot.
-   [ ] Cross-practical isolation tests pass.
-   [ ] Analysis, tests, build status, and known limitations are
    recorded.

## Final principle

Build one reliable laboratory engine and give each practical its own
stable definition and session. Reuse infrastructure, not experiment
state. A new practical should be added by defining and validating its
content---not by patching unrelated screens until they happen to work.
