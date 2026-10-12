// REAL-BROWSER runtime test for the model_viewer integration.
//
// Run ONLY as: flutter test --platform chrome test/model_viewer_chrome_test.dart
// On the VM (`flutter test`) this file self-skips: no WebView exists there.
// This test pumps the real Flutter3DViewer in headless Chrome, loads the
// bundled placeholder GLB through the full stack (Flutter assets ->
// model-viewer JS -> onLoad), and fails with the verbatim error text if
// the viewer's onError fires. It is intentionally NOT part of CI.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_3d_lab/app/app.dart';
import 'package:pharmacy_3d_lab/app/lab_launcher.dart';
import 'package:pharmacy_3d_lab/core/ids.dart';
import 'package:pharmacy_3d_lab/features/catalogue/data/practicals_catalogue.dart';
import 'package:pharmacy_3d_lab/features/laboratory/domain/lab_session.dart';

void main() {
  testWidgets('placeholder GLB loads in the shared LabShell', (tester) async {
    final registry = buildRegistry();
    final sessions = LabSessionManager();
    final launcher = LabLauncher(registry);
    sessions.createSession(StableIds.chlorideTestId);
    sessions.update(
      sessions.active!.copyWith(
        assessmentPassed: true,
        assessmentAnswers: const {},
      ),
    );
    await tester.pumpWidget(
      PharmacyLabApp(
        registry: registry,
        sessionManager: sessions,
        launcher: launcher,
      ),
    );
    final ctx = tester.element(find.text('Limit Test of Chloride'));
    Navigator.pushNamed(ctx, '/lab', arguments: StableIds.chlorideTestId);
    await tester.pump(const Duration(seconds: 2));

    expect(
      find.textContaining('INTERACTIVE 3D'),
      findsOneWidget,
      reason: 'LabShell must resolve the real 3D adapter on web',
    );

    bool settled = false;
    String? viewerError;
    for (var i = 0; i < 90; i++) {
      await tester.pump(const Duration(seconds: 1));
      final errors = find
          .textContaining('3D scene failed to load')
          .evaluate();
      if (errors.isNotEmpty) {
        viewerError = 'viewer onError fired within ~${i + 3}s';
        break;
      }
      if (find
          .byType(CircularProgressIndicator)
          .evaluate()
          .isEmpty) {
        settled = true;
        break;
      }
    }
    if (viewerError != null) fail(viewerError);
    expect(
      settled,
      isTrue,
      reason: 'GLB did not finish loading (overlay still visible after ~93s)',
    );
  }, skip: !kIsWeb);
}
