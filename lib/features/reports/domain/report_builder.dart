import '../../catalogue/domain/practical_definition.dart';
import '../../laboratory/domain/lab_session.dart';

/// Immutable snapshot report built from active session + its definition.
/// Never mutates session. Practical-specific fields only.
class ReportSnapshot {
  final String practicalId;
  final String practicalTitle;
  final String sessionId;
  final DateTime generatedAt;
  final Map<String, String> sections; // field -> text
  const ReportSnapshot({
    required this.practicalId,
    required this.practicalTitle,
    required this.sessionId,
    required this.generatedAt,
    required this.sections,
  });
}

class ReportBuilder {
  static ReportSnapshot build(PracticalDefinition def, LabSession session) {
    assert(
      def.id == session.practicalId,
      'Report must use the active session\u2019s own definition',
    );
    final sections = <String, String>{};
    for (final f in def.reportSchema.fields) {
      sections[f] = _fieldText(def, session, f);
    }
    return ReportSnapshot(
      practicalId: def.id,
      practicalTitle: def.title,
      sessionId: session.sessionId,
      generatedAt: DateTime.now(),
      sections: Map.unmodifiable(sections),
    );
  }

  static String _fieldText(
    PracticalDefinition def,
    LabSession session,
    String field,
  ) {
    switch (field) {
      case 'aim':
        return def.description;
      case 'principle':
        return 'Comparison against standard (simulated). REQUIRES_EDUCATOR_REVIEW.';
      case 'sample_vs_standard_observation':
        return session.observations.isEmpty
            ? 'No simulated observations yet.'
            : session.observations.join('\n');
      case 'inference':
        return session.completed
            ? 'SIMULATED inference recorded. REQUIRES_EDUCATOR_REVIEW.'
            : 'Practical not yet completed.';
      case 'reaction_scheme':
        return 'Esterification scheme (simulated). REQUIRES_EDUCATOR_REVIEW.';
      case 'simulated_yield':
        return 'SIMULATED: yield not measured — REQUIRES_EDUCATOR_REVIEW.';
      case 'simulated_melting_point':
        return 'SIMULATED: melting point not measured — REQUIRES_EDUCATOR_REVIEW.';
      default:
        return '—';
    }
  }
}
