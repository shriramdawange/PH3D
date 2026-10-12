import 'package:flutter/foundation.dart';

/// Per-attempt isolated session. No global mutable material/step/result lists.
@immutable
class LabSession {
  final String sessionId;
  final String practicalId;
  final DateTime startedAt;
  final Map<String, String> assessmentAnswers; // questionId -> optionId
  final bool assessmentPassed;
  final String? currentStepId;
  final Set<String> completedStepIds;
  final Map<String, double> quantities; // materialId -> value
  final Map<String, String> quantityUnits; // materialId -> unit
  final Set<String> selectedEquipmentIds;
  final List<String> observations; // simulated, labelled at render time
  final List<String> warnings;
  final bool completed;

  const LabSession({
    required this.sessionId,
    required this.practicalId,
    required this.startedAt,
    this.assessmentAnswers = const {},
    this.assessmentPassed = false,
    this.currentStepId,
    this.completedStepIds = const {},
    this.quantities = const {},
    this.quantityUnits = const {},
    this.selectedEquipmentIds = const {},
    this.observations = const [],
    this.warnings = const [],
    this.completed = false,
  });

  LabSession copyWith({
    Map<String, String>? assessmentAnswers,
    bool? assessmentPassed,
    String? currentStepId,
    Set<String>? completedStepIds,
    Map<String, double>? quantities,
    Map<String, String>? quantityUnits,
    Set<String>? selectedEquipmentIds,
    List<String>? observations,
    List<String>? warnings,
    bool? completed,
  }) {
    return LabSession(
      sessionId: sessionId,
      practicalId: practicalId,
      startedAt: startedAt,
      assessmentAnswers: assessmentAnswers ?? this.assessmentAnswers,
      assessmentPassed: assessmentPassed ?? this.assessmentPassed,
      currentStepId: currentStepId ?? this.currentStepId,
      completedStepIds: completedStepIds ?? this.completedStepIds,
      quantities: quantities ?? this.quantities,
      quantityUnits: quantityUnits ?? this.quantityUnits,
      selectedEquipmentIds: selectedEquipmentIds ?? this.selectedEquipmentIds,
      observations: observations ?? this.observations,
      warnings: warnings ?? this.warnings,
      completed: completed ?? this.completed,
    );
  }
}

/// Owns the active session only. Creating a new session discards the old
/// object's references (old session untouched) — guarantees isolation.
class LabSessionManager extends ChangeNotifier {
  LabSession? _active;
  int _counter = 0;

  LabSession? get active => _active;

  LabSession createSession(String practicalId) {
    _counter++;
    _active = LabSession(
      sessionId: 'sess_${DateTime.now().microsecondsSinceEpoch}_$_counter',
      practicalId: practicalId,
      startedAt: DateTime.now(),
    );
    notifyListeners();
    return _active!;
  }

  void update(LabSession next) {
    assert(
      next.practicalId == _active?.practicalId,
      'Must not swap practical identity of a session',
    );
    _active = next;
    notifyListeners();
  }

  void disposeSession() {
    _active = null;
    notifyListeners();
  }
}
