import 'package:flutter/material.dart';

import '../features/catalogue/domain/practical_registry.dart';
import '../features/laboratory/domain/lab_session.dart';
import 'lab_launcher.dart';
import '../features/catalogue/presentation/catalogue_screen.dart';
import '../features/catalogue/presentation/practical_overview_screen.dart';
import '../features/assessment/presentation/mcq_screen.dart';
import '../features/laboratory/presentation/lab_shell_screen.dart';
import '../features/reports/presentation/report_screen.dart';

class PharmacyLabApp extends StatelessWidget {
  final PracticalRegistry registry;
  final LabSessionManager sessionManager;
  final LabLauncher launcher;

  const PharmacyLabApp({
    super.key,
    required this.registry,
    required this.sessionManager,
    required this.launcher,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sessionManager,
      builder: (context, _) => MaterialApp(
        title: 'Virtual Pharmaceutical Lab',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (_) => CatalogueScreen(registry: registry),
              );
            case '/overview':
              final id = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => PracticalOverviewScreen(
                  registry: registry,
                  launcher: launcher,
                  practicalId: id,
                ),
              );
            case '/mcq':
              final id = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => McqScreen(
                  registry: registry,
                  sessionManager: sessionManager,
                  practicalId: id,
                ),
              );
            case '/lab':
              final id = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => LabShellScreen(
                  registry: registry,
                  sessionManager: sessionManager,
                  practicalId: id,
                ),
              );
            case '/report':
              final id = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => ReportScreen(
                  registry: registry,
                  sessionManager: sessionManager,
                  practicalId: id,
                ),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Center(
                    child: Text(
                      'Unknown route ${settings.name} (explicit failure, no silent fallback).',
                    ),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
