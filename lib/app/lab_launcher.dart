import '../features/catalogue/domain/practical_registry.dart';

/// Single validated lab-launch path. All navigation passes explicit
/// practical IDs; never display-name substrings or parallel-list indices.
class LabLauncher {
  final PracticalRegistry registry;
  final Set<String> _inFlight = {};

  LabLauncher(this.registry);

  /// Validates definition before launch. Throws UnknownPracticalException
  /// or RegistryValidationException details on failure.
  void validateLaunch(String practicalId) {
    registry.resolve(practicalId);
  }

  /// Guards against duplicate launch taps.
  bool tryBeginLaunch(String practicalId) {
    if (_inFlight.contains(practicalId)) return false;
    validateLaunch(practicalId);
    _inFlight.add(practicalId);
    return true;
  }

  void endLaunch(String practicalId) => _inFlight.remove(practicalId);
}
