import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_3d_lab/app/app.dart';
import 'package:pharmacy_3d_lab/app/lab_launcher.dart';
import 'package:pharmacy_3d_lab/features/catalogue/data/practicals_catalogue.dart';
import 'package:pharmacy_3d_lab/features/laboratory/domain/lab_session.dart';

void main() {
  testWidgets('catalogue selection routes to expected practical', (
    tester,
  ) async {
    final registry = buildRegistry();
    final sessions = LabSessionManager();
    final launcher = LabLauncher(registry);
    await tester.pumpWidget(
      PharmacyLabApp(
        registry: registry,
        sessionManager: sessions,
        launcher: launcher,
      ),
    );
    expect(find.text('Limit Test of Chloride'), findsOneWidget);
    expect(find.text('Benzocaine Synthesis'), findsOneWidget);
    await tester.tap(find.text('Limit Test of Chloride'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Start pre-lab MCQ'), findsOneWidget);
  });

  testWidgets('LabShell shows selected practical identity', (tester) async {
    // Widget tests cannot host a real WebView: force the desktop path so
    // LabShell must show the explicit unsupported-platform state — never a
    // WebView, never a silent fallback.
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final registry = buildRegistry();
      final sessions = LabSessionManager();
      final launcher = LabLauncher(registry);
      sessions.createSession('pharm_inorganic.limit_test_chloride');
      sessions.update(
        sessions.active!.copyWith(
          assessmentPassed: true,
          assessmentAnswers: const {},
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return const SizedBox();
            },
          ),
        ),
      );
      // Build full app and navigate directly to lab route.
      await tester.pumpWidget(
        PharmacyLabApp(
          registry: registry,
          sessionManager: sessions,
          launcher: launcher,
        ),
      );
      // Navigate via named route with explicit ID.
      final ctx = tester.element(find.text('Limit Test of Chloride'));
      Navigator.pushNamed(
        ctx,
        '/lab',
        arguments: 'pharm_inorganic.limit_test_chloride',
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Limit Test of Chloride'), findsWidgets);
      // Widget tests run on desktop hosts (no verified 3D renderer there),
      // so LabShell must show the explicit unsupported-platform state —
      // never a WebView, never a silent fallback.
      expect(
        find.textContaining('3D NOT SUPPORTED ON THIS PLATFORM'),
        findsOneWidget,
      );
      expect(
        find.textContaining('pharm_inorganic.limit_test_chloride'),
        findsWidgets,
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('report preview contains correct practical fields', (
    tester,
  ) async {
    final registry = buildRegistry();
    final sessions = LabSessionManager();
    final launcher = LabLauncher(registry);
    sessions.createSession('medicinal_chemistry.benzocaine_synthesis');
    sessions.update(sessions.active!.copyWith(assessmentPassed: true));
    await tester.pumpWidget(
      PharmacyLabApp(
        registry: registry,
        sessionManager: sessions,
        launcher: launcher,
      ),
    );
    final ctx = tester.element(find.text('Benzocaine Synthesis'));
    Navigator.pushNamed(
      ctx,
      '/report',
      arguments: 'medicinal_chemistry.benzocaine_synthesis',
    );
    await tester.pumpAndSettle();
    expect(find.text('simulated_yield'), findsOneWidget);
    expect(find.text('sample_vs_standard_observation'), findsNothing);
  });
}
