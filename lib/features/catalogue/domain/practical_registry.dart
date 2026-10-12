import 'practical_definition.dart';

/// Single authoritative registry. Validates unique IDs, required fields,
/// deterministic ordering. Never silently substitutes another practical.
class PracticalRegistry {
  final List<PracticalDefinition> _defs;
  final Map<String, PracticalDefinition> _byId;

  PracticalRegistry._(this._defs, this._byId);

  factory PracticalRegistry(List<PracticalDefinition> defs) {
    final errors = <String>[];
    final byId = <String, PracticalDefinition>{};
    for (final d in defs) {
      if (byId.containsKey(d.id)) {
        errors.add('[${d.id}] registry: duplicate practical ID');
      } else {
        byId[d.id] = d;
      }
      errors.addAll(d.validate());
    }
    if (errors.isNotEmpty) {
      throw RegistryValidationException(errors);
    }
    // Deterministic catalogue ordering: sortOrder, then id.
    final ordered = List<PracticalDefinition>.from(defs)
      ..sort((a, b) {
        final c = a.sortOrder.compareTo(b.sortOrder);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
    return PracticalRegistry._(
        List.unmodifiable(ordered), Map.unmodifiable(byId));
  }

  List<PracticalDefinition> get all => _defs;

  PracticalDefinition resolve(String id) {
    final d = _byId[id];
    if (d == null) {
      throw UnknownPracticalException(id);
    }
    return d;
  }

  List<String> get semesterIds {
    final seen = <String>[];
    for (final d in _defs) {
      if (!seen.contains(d.semesterId)) seen.add(d.semesterId);
    }
    return seen;
  }

  List<PracticalDefinition> bySemester(String semesterId) =>
      _defs.where((d) => d.semesterId == semesterId).toList();

  List<PracticalDefinition> bySubject(String subjectId) =>
      _defs.where((d) => d.subjectId == subjectId).toList();
}

class RegistryValidationException implements Exception {
  final List<String> errors;
  RegistryValidationException(this.errors);
  @override
  String toString() => 'RegistryValidationException:\n${errors.join('\n')}';
}

class UnknownPracticalException implements Exception {
  final String id;
  UnknownPracticalException(this.id);
  @override
  String toString() => 'UnknownPracticalException: $id';
}
