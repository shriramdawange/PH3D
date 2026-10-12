// Renderer boundary tests. Deliberately WebView-free: the real
// ModelViewerAdapter (flutter_3d_controller) is asserted by type/wiring
// only and is never pumped. Widget pumps cover only pure-Flutter states.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_3d_lab/core/ids.dart';
import 'package:pharmacy_3d_lab/features/catalogue/data/practicals_catalogue.dart';
import 'package:pharmacy_3d_lab/features/catalogue/domain/practical_definition.dart';
import 'package:pharmacy_3d_lab/features/laboratory/domain/lab_session.dart';
import 'package:pharmacy_3d_lab/features/laboratory/rendering/renderer_adapter.dart';

PracticalDefinition cloneWithScene(
  PracticalDefinition src,
  String rendererKind,
  String sceneAsset,
) {
  return PracticalDefinition(
    id: src.id,
    contentVersion: src.contentVersion,
    title: src.title,
    semesterId: src.semesterId,
    semesterLabel: src.semesterLabel,
    subjectId: src.subjectId,
    subjectLabel: src.subjectLabel,
    practicalType: src.practicalType,
    description: src.description,
    learningObjectives: src.learningObjectives,
    sortOrder: src.sortOrder,
    assessment: src.assessment,
    materials: src.materials,
    equipment: src.equipment,
    steps: src.steps,
    simulation: src.simulation,
    scene: SceneConfig(
      practicalId: src.id,
      rendererKind: rendererKind,
      sceneAsset: sceneAsset,
    ),
    reportSchema: src.reportSchema,
    reviewStatus: src.reviewStatus,
  );
}

LabSession freshSession(String practicalId) => LabSession(
  sessionId: 'test-session',
  practicalId: practicalId,
  startedAt: DateTime(2026, 1, 1),
);

void main() {
  group('RendererRegistry.resolve', () {
    test('supported mobile/desktop platforms get the real 3D adapter', () {
      final registry = buildRegistry();
      final def = registry.resolve(StableIds.chlorideTestId);
      for (final platform in [
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ]) {
        final adapter = RendererRegistry.resolve(
          definition: def,
          session: freshSession(def.id),
          onEquipmentTap: (_) {},
          platformOverride: platform,
        );
        expect(adapter, isA<ModelViewerAdapter>());
        expect(adapter.rendererKind, 'model_viewer');
        expect(
          (adapter as ModelViewerAdapter).definition.scene.sceneAsset,
          def.scene.sceneAsset,
        );
      }
    });

    test('windows and linux get an explicit unsupported state', () {
      final registry = buildRegistry();
      final def = registry.resolve(StableIds.chlorideTestId);
      for (final platform in [TargetPlatform.windows, TargetPlatform.linux]) {
        final adapter = RendererRegistry.resolve(
          definition: def,
          session: freshSession(def.id),
          onEquipmentTap: (_) {},
          platformOverride: platform,
        );
        expect(adapter, isA<UnsupportedPlatformAdapter>());
        expect(adapter.rendererKind, 'unsupported_platform');
      }
    });

    test('temporary kind still resolves to the labelled test renderer', () {
      final registry = buildRegistry();
      final src = registry.resolve(StableIds.chlorideTestId);
      final def = cloneWithScene(src, 'temporary', 'scenes/test');
      final adapter = RendererRegistry.resolve(
        definition: def,
        session: freshSession(def.id),
        onEquipmentTap: (_) {},
      );
      expect(adapter, isA<TemporaryRendererAdapter>());
      expect(adapter.rendererKind, 'temporary');
    });

    test('unknown renderer kind throws instead of silent fallback', () {
      final registry = buildRegistry();
      final src = registry.resolve(StableIds.chlorideTestId);
      final def = cloneWithScene(src, 'hologram', 'scenes/test');
      expect(
        () => RendererRegistry.resolve(
          definition: def,
          session: freshSession(def.id),
          onEquipmentTap: (_) {},
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('adapters bind their own practical identity and scene', () {
      final registry = buildRegistry();
      final cl = registry.resolve(StableIds.chlorideTestId);
      final bz = registry.resolve(StableIds.benzocaineSynthesisId);
      final clAdapter = RendererRegistry.resolve(
        definition: cl,
        session: freshSession(cl.id),
        onEquipmentTap: (_) {},
        platformOverride: TargetPlatform.android,
      ) as ModelViewerAdapter;
      final bzAdapter = RendererRegistry.resolve(
        definition: bz,
        session: freshSession(bz.id),
        onEquipmentTap: (_) {},
        platformOverride: TargetPlatform.android,
      ) as ModelViewerAdapter;
      // Practical-specific scene configuration is isolated.
      expect(clAdapter.definition.id, StableIds.chlorideTestId);
      expect(bzAdapter.definition.id, StableIds.benzocaineSynthesisId);
      expect(
        clAdapter.definition.scene.sceneAsset,
        isNot(bzAdapter.definition.scene.sceneAsset),
      );
      expect(clAdapter.session.practicalId, clAdapter.definition.id);
      expect(bzAdapter.session.practicalId, bzAdapter.definition.id);
    });
  });

  group('pure-Flutter renderer states (safe to pump)', () {
    testWidgets('unsupported state names platform and practical', (
      tester,
    ) async {
      final registry = buildRegistry();
      final def = registry.resolve(StableIds.benzocaineSynthesisId);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnsupportedPlatformAdapter(
              definition: def,
              platform: TargetPlatform.windows,
            ),
          ),
        ),
      );
      expect(
        find.textContaining('3D NOT SUPPORTED ON THIS PLATFORM'),
        findsOneWidget,
      );
      expect(find.textContaining(def.id), findsWidgets);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('temporary renderer emits typed equipment actions', (
      tester,
    ) async {
      final registry = buildRegistry();
      final def = registry.resolve(StableIds.chlorideTestId);
      final tapped = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TemporaryRendererAdapter(
              definition: def,
              session: freshSession(def.id),
              onEquipmentTap: tapped.add,
            ),
          ),
        ),
      );
      expect(find.textContaining('TEMPORARY RENDERER'), findsOneWidget);
      await tester.tap(find.text('Nessler cylinder A'));
      expect(tapped, ['cl_nessler_a']);
    });
  });
}
