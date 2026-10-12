import '../../catalogue/domain/practical_definition.dart';
import '../../laboratory/domain/lab_session.dart';

/// Deterministic simulation using ONLY the active practical's config.
/// No fabricated measurements: outputs are qualitative + labelled simulated.
class SimulationEngine {
  static List<String> observationsFor(
      PracticalDefinition def, LabSession session) {
    if (def.simulation.kind == 'limit_test') {
      final done = session.completedStepIds.length;
      if (done >= 3) {
        return const [
          'SIMULATED: sample opalescence compared with standard (simulated). REQUIRES_EDUCATOR_REVIEW for acceptance limits.'
        ];
      }
      return const ['SIMULATED: no comparison yet — complete all steps.'];
    } else {
      final done = session.completedStepIds.length;
      if (done >= 3) {
        return const [
          'SIMULATED: product isolated (simulated). REQUIRES_EDUCATOR_REVIEW: yield, melting point.'
        ];
      }
      return const ['SIMULATED: reaction in progress (simulated).'];
    }
  }
}
