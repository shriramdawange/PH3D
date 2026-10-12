import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/lab_launcher.dart';
import 'features/catalogue/data/practicals_catalogue.dart';
import 'features/laboratory/domain/lab_session.dart';

void main() {
  final registry = buildRegistry();
  final sessionManager = LabSessionManager();
  final launcher = LabLauncher(registry);
  runApp(PharmacyLabApp(
      registry: registry,
      sessionManager: sessionManager,
      launcher: launcher));
}
