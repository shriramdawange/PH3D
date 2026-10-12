import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_3d_lab/features/catalogue/data/practicals_catalogue.dart';
import 'package:pharmacy_3d_lab/features/catalogue/domain/practical_definition.dart';
import 'package:pharmacy_3d_lab/features/catalogue/domain/practical_registry.dart';
import 'package:pharmacy_3d_lab/features/assessment/domain/assessment_engine.dart';
import 'package:pharmacy_3d_lab/features/laboratory/domain/lab_session.dart';
import 'package:pharmacy_3d_lab/features/procedure/domain/procedure_engine.dart';
import 'package:pharmacy_3d_lab/features/reports/domain/report_builder.dart';
import 'package:pharmacy_3d_lab/features/simulation/domain/simulation_engine.dart';
import 'package:pharmacy_3d_lab/core/ids.dart';

PracticalDefinition cloneWithId(
  PracticalDefinition src,
  String newId,
  int order,
) {
  return PracticalDefinition(
    id: newId,
    contentVersion: src.contentVersion,
    title: '${src.title} copy',
    semesterId: src.semesterId,
    semesterLabel: src.semesterLabel,
    subjectId: src.subjectId,
    subjectLabel: src.subjectLabel,
    practicalType: src.practicalType,
    description: src.description,
    learningObjectives: src.learningObjectives,
    sortOrder: order,
    assessment: AssessmentDefinition(
      practicalId: newId,
      questions: src.assessment.questions,
      passThreshold: src.assessment.passThreshold,
    ),
    materials: src.materials,
    equipment: src.equipment,
    steps: src.steps,
    simulation: SimulationConfig(practicalId: newId, kind: src.simulation.kind),
    scene: SceneConfig(
      practicalId: newId,
      rendererKind: src.scene.rendererKind,
      sceneAsset: 'scenes/extra',
    ),
    reportSchema: ReportSchema(
      practicalId: newId,
      fields: src.reportSchema.fields,
    ),
    reviewStatus: src.reviewStatus,
  );
}

void main() {
  test('registry validates and orders deterministically', () {
    final r = buildRegistry();
    expect(r.all.length, 2);
    expect(r.all[0].id, StableIds.chlorideTestId);
    expect(r.all[1].id, StableIds.benzocaineSynthesisId);
  });

  test('duplicate IDs throw', () {
    final r = buildRegistry();
    expect(
      () => PracticalRegistry([...r.all, ...r.all]),
      throwsA(isA<RegistryValidationException>()),
    );
  });

  test('unknown ID throws explicit failure', () {
    final r = buildRegistry();
    expect(
      () => r.resolve('nope.missing'),
      throwsA(isA<UnknownPracticalException>()),
    );
  });

  test('assessment scoring + empty assessment', () {
    final r = buildRegistry();
    final def = r.resolve(StableIds.chlorideTestId);
    final ok = {
      for (final q in def.assessment.questions) q.id: q.correctOptionId,
    };
    final pass = AssessmentEngine.evaluate(def.assessment, ok);
    expect(pass.passed, true);
    final fail = AssessmentEngine.evaluate(def.assessment, {});
    expect(fail.passed, false);
    expect(fail.score, 0.0);
  });

  test('unit validation rejects incompatible units', () {
    final r = buildRegistry();
    final def = r.resolve(StableIds.chlorideTestId);
    final bad = ProcedureEngine.setQuantity(def, 'cl_sample', 5, 'g');
    expect(bad.accepted, false);
    expect(bad.code, 'unit_invalid');
    final foreign = ProcedureEngine.setQuantity(def, 'bz_paba', 5, 'g');
    expect(foreign.accepted, false);
    expect(foreign.code, 'material_not_allowed');
  });

  test('procedure prerequisites enforced', () {
    final r = buildRegistry();
    final def = r.resolve(StableIds.chlorideTestId);
    var s = LabSession(
      sessionId: 't',
      practicalId: def.id,
      startedAt: DateTime.now(),
    );
    final locked = ProcedureEngine.completeStep(def, s, 'cl_s3');
    expect(locked.accepted, false);
    s = s.copyWith(completedStepIds: {'cl_s1', 'cl_s2'});
    final missing = ProcedureEngine.completeStep(def, s, 'cl_s3');
    expect(missing.accepted, false);
  });

  test('simulation is deterministic', () {
    final r = buildRegistry();
    final def = r.resolve(StableIds.chlorideTestId);
    final s = LabSession(
      sessionId: 't',
      practicalId: def.id,
      startedAt: DateTime.now(),
    );
    final a = SimulationEngine.observationsFor(def, s);
    final b = SimulationEngine.observationsFor(def, s);
    expect(a.join(), b.join());
  });

  test('report built from own snapshot; does not mutate session', () {
    final r = buildRegistry();
    final cl = r.resolve(StableIds.chlorideTestId);
    final s = LabSession(
      sessionId: 's1',
      practicalId: cl.id,
      startedAt: DateTime.now(),
      observations: const ['x'],
    );
    final rep = ReportBuilder.build(cl, s);
    expect(rep.practicalId, cl.id);
    expect(rep.sections.containsKey('sample_vs_standard_observation'), true);
    expect(rep.sections.containsKey('simulated_yield'), false);
    expect(s.observations.length, 1);
  });

  test('CROSS-PRACTICAL ISOLATION: sessions do not leak', () {
    final r = buildRegistry();
    final cl = r.resolve(StableIds.chlorideTestId);
    final bz = r.resolve(StableIds.benzocaineSynthesisId);

    var clSession = LabSession(
      sessionId: 'cl1',
      practicalId: cl.id,
      startedAt: DateTime.now(),
    );
    clSession = clSession.copyWith(
      quantities: {'cl_sample': 5.0},
      quantityUnits: {'cl_sample': 'mL'},
      selectedEquipmentIds: {'cl_nessler_a'},
      completedStepIds: {'cl_s1'},
      observations: const ['cl obs'],
    );

    var bzSession = LabSession(
      sessionId: 'bz1',
      practicalId: bz.id,
      startedAt: DateTime.now(),
    );
    expect(bzSession.quantities.containsKey('cl_sample'), false);
    expect(bzSession.selectedEquipmentIds.contains('cl_nessler_a'), false);
    expect(bzSession.completedStepIds.contains('cl_s1'), false);
    expect(bzSession.observations, isEmpty);

    bzSession = bzSession.copyWith(
      quantities: {'bz_paba': 2.0},
      selectedEquipmentIds: {'bz_reflux'},
      completedStepIds: {'bz_s1'},
    );
    var clSession2 = LabSession(
      sessionId: 'cl2',
      practicalId: cl.id,
      startedAt: DateTime.now(),
    );
    expect(clSession2.quantities.containsKey('bz_paba'), false);
    expect(clSession2.selectedEquipmentIds.contains('bz_reflux'), false);

    final clRep = ReportBuilder.build(cl, clSession);
    final bzRep = ReportBuilder.build(bz, bzSession);
    expect(
      clRep.sections.keys.toSet().intersection(bzRep.sections.keys.toSet()),
      contains('aim'),
    );
    expect(clRep.sections.containsKey('simulated_yield'), false);
    expect(bzRep.sections.containsKey('sample_vs_standard_observation'), false);
  });

  test('adding a third practical does not reorder existing', () {
    final r = buildRegistry();
    final before = r.all.map((d) => d.id).toList();
    final r2 = PracticalRegistry([
      ...r.all,
      cloneWithId(r.all.first, 'test.extra_practical', 99),
    ]);
    final after = r2.all.take(before.length).map((d) => d.id).toList();
    expect(after, before);
  });
}
