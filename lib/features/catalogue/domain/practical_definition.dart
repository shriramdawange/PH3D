// Core domain contracts: immutable, validated practical definitions.
enum PracticalType { analyticalTest, synthesis }

enum ContentReviewStatus { reviewed, requiresEducatorReview }

class McqOption {
  final String id;
  final String text;
  const McqOption({required this.id, required this.text});
}

class McqQuestion {
  final String id;
  final String text;
  final List<McqOption> options;
  final String correctOptionId;
  final String explanation;
  const McqQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionId,
    required this.explanation,
  });
}

class AssessmentDefinition {
  final String practicalId;
  final List<McqQuestion> questions;
  final double passThreshold; // 0..1
  final int maxAttempts; // -1 = unlimited
  final bool requiredGate;
  const AssessmentDefinition({
    required this.practicalId,
    required this.questions,
    this.passThreshold = 0.6,
    this.maxAttempts = -1,
    this.requiredGate = true,
  });
}

class MaterialDefinition {
  final String id;
  final String label;
  final List<String> allowedUnits;
  final String? reviewedConstraintNote;
  const MaterialDefinition({
    required this.id,
    required this.label,
    required this.allowedUnits,
    this.reviewedConstraintNote,
  });
}

class EquipmentDefinition {
  final String id;
  final String label;
  const EquipmentDefinition({required this.id, required this.label});
}

class ProcedureStep {
  final String id;
  final int order;
  final String title;
  final String instruction;
  final List<String> requiredMaterialIds;
  final List<String> requiredEquipmentIds;
  final List<String> prerequisites; // step ids
  const ProcedureStep({
    required this.id,
    required this.order,
    required this.title,
    required this.instruction,
    this.requiredMaterialIds = const [],
    this.requiredEquipmentIds = const [],
    this.prerequisites = const [],
  });
}

class SimulationConfig {
  final String practicalId;
  final String kind; // e.g. 'limit_test' | 'synthesis'
  const SimulationConfig({required this.practicalId, required this.kind});
}

class SceneConfig {
  final String practicalId;
  final String rendererKind; // explicit: 'temporary' until real 3D wired
  final String sceneAsset; // logical asset key, practical-specific
  const SceneConfig({
    required this.practicalId,
    required this.rendererKind,
    required this.sceneAsset,
  });
}

class ReportSchema {
  final String practicalId;
  final List<String> fields;
  const ReportSchema({required this.practicalId, required this.fields});
}

class PracticalDefinition {
  final String id;
  final String contentVersion;
  final String title;
  final String semesterId;
  final String semesterLabel;
  final String subjectId;
  final String subjectLabel;
  final PracticalType practicalType;
  final String description;
  final List<String> learningObjectives;
  final int sortOrder; // deterministic catalogue ordering
  final AssessmentDefinition assessment;
  final List<MaterialDefinition> materials;
  final List<EquipmentDefinition> equipment;
  final List<ProcedureStep> steps;
  final SimulationConfig simulation;
  final SceneConfig scene;
  final ReportSchema reportSchema;
  final ContentReviewStatus reviewStatus;

  const PracticalDefinition({
    required this.id,
    required this.contentVersion,
    required this.title,
    required this.semesterId,
    required this.semesterLabel,
    required this.subjectId,
    required this.subjectLabel,
    required this.practicalType,
    required this.description,
    required this.learningObjectives,
    required this.sortOrder,
    required this.assessment,
    required this.materials,
    required this.equipment,
    required this.steps,
    required this.simulation,
    required this.scene,
    required this.reportSchema,
    required this.reviewStatus,
  });

  /// Returns a list of human-readable validation errors (empty = valid).
  List<String> validate() {
    final errors = <String>[];
    void err(String field, String msg) =>
        errors.add('[$id] $field: $msg');
    if (id.isEmpty) err('id', 'must be non-empty');
    if (contentVersion.isEmpty) err('contentVersion', 'must be non-empty');
    if (title.isEmpty) err('title', 'must be non-empty');
    if (semesterId.isEmpty) err('semesterId', 'must be non-empty');
    if (subjectId.isEmpty) err('subjectId', 'must be non-empty');
    if (description.isEmpty) err('description', 'must be non-empty');
    if (learningObjectives.isEmpty) {
      err('learningObjectives', 'must be non-empty');
    }
    if (assessment.practicalId != id) {
      err('assessment.practicalId',
          'mismatch ${assessment.practicalId} != $id');
    }
    if (simulation.practicalId != id) {
      err('simulation.practicalId', 'mismatch');
    }
    if (scene.practicalId != id) {
      err('scene.practicalId', 'mismatch');
    }
    if (reportSchema.practicalId != id) {
      err('reportSchema.practicalId', 'mismatch');
    }
    final stepIds = steps.map((s) => s.id).toSet();
    if (stepIds.length != steps.length) {
      err('steps', 'duplicate step IDs');
    }
    final orders = steps.map((s) => s.order).toList()..sort();
    for (var i = 0; i < orders.length; i++) {
      if (orders[i] != i + 1) {
        err('steps', 'orders must be 1..N deterministic; got $orders');
        break;
      }
    }
    for (final s in steps) {
      for (final p in s.prerequisites) {
        if (!stepIds.contains(p)) {
          err('steps.${s.id}', 'unknown prerequisite $p');
        }
      }
      for (final m in s.requiredMaterialIds) {
        if (!materials.any((e) => e.id == m)) {
          err('steps.${s.id}', 'unknown material $m');
        }
      }
      for (final e in s.requiredEquipmentIds) {
        if (!equipment.any((x) => x.id == e)) {
          err('steps.${s.id}', 'unknown equipment $e');
        }
      }
    }
    final matIds = materials.map((m) => m.id).toSet();
    if (matIds.length != materials.length) {
      err('materials', 'duplicate material IDs');
    }
    for (final m in materials) {
      if (m.allowedUnits.isEmpty) {
        err('materials.${m.id}', 'must declare allowedUnits');
      }
    }
    return errors;
  }
}
