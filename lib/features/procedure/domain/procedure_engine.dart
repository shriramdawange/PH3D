import '../../catalogue/domain/practical_definition.dart';
import '../../laboratory/domain/lab_session.dart';

class ActionResult {
  final bool accepted;
  final String message;
  final String? code;
  const ActionResult(
      {required this.accepted, required this.message, this.code});
}

class ProcedureEngine {
  /// Validates against the session's own definition only.
  static ActionResult completeStep(
      PracticalDefinition def, LabSession session, String stepId) {
    final step = def.steps.where((s) => s.id == stepId).toList();
    if (step.isEmpty) {
      return const ActionResult(
          accepted: false,
          message: 'Unknown step for this practical.',
          code: 'unknown_step');
    }
    final s = step.first;
    for (final p in s.prerequisites) {
      if (!session.completedStepIds.contains(p)) {
        return ActionResult(
            accepted: false,
            message:
                'Complete prerequisite step first: $p. ${s.title} is locked.',
            code: 'prerequisite_missing');
      }
    }
    for (final m in s.requiredMaterialIds) {
      if (!session.quantities.containsKey(m)) {
        return ActionResult(
            accepted: false,
            message: 'Enter quantity for material $m before this step.',
            code: 'material_missing');
      }
    }
    for (final e in s.requiredEquipmentIds) {
      if (!session.selectedEquipmentIds.contains(e)) {
        return ActionResult(
            accepted: false,
            message: 'Select equipment $e before this step.',
            code: 'equipment_missing');
      }
    }
    return ActionResult(
        accepted: true, message: 'Step "${s.title}" completed (simulated).');
  }

  static ActionResult setQuantity(PracticalDefinition def, String materialId,
      double value, String unit) {
    final mat = def.materials.where((m) => m.id == materialId).toList();
    if (mat.isEmpty) {
      return const ActionResult(
          accepted: false,
          message: 'Material not allowed in this practical.',
          code: 'material_not_allowed');
    }
    if (!mat.first.allowedUnits.contains(unit)) {
      return ActionResult(
          accepted: false,
          message:
              'Unit "$unit" not allowed for ${mat.first.label}. Allowed: ${mat.first.allowedUnits.join(', ')}.',
          code: 'unit_invalid');
    }
    if (value <= 0) {
      return const ActionResult(
          accepted: false,
          message: 'Quantity must be positive.',
          code: 'quantity_invalid');
    }
    return const ActionResult(accepted: true, message: 'Quantity accepted.');
  }
}
