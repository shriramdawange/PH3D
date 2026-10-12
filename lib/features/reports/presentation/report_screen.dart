import 'package:flutter/material.dart';
import '../../catalogue/domain/practical_registry.dart';
import '../../laboratory/domain/lab_session.dart';
import '../domain/report_builder.dart';

class ReportScreen extends StatelessWidget {
  final PracticalRegistry registry;
  final LabSessionManager sessionManager;
  final String practicalId;
  const ReportScreen(
      {super.key,
      required this.registry,
      required this.sessionManager,
      required this.practicalId});

  @override
  Widget build(BuildContext context) {
    final def = registry.resolve(practicalId);
    final session = sessionManager.active;
    if (session == null || session.practicalId != practicalId) {
      return Scaffold(
          appBar: AppBar(title: const Text('Report')),
          body: const Center(
              child: Text(
                  'No active session for this practical. Report needs its own session snapshot.')));
    }
    final report = ReportBuilder.build(def, session);
    return Scaffold(
      appBar: AppBar(title: Text('Report — ${def.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
                'Practical: ${report.practicalTitle} (${report.practicalId})'),
            Text('Session: ${report.sessionId}'),
            Text('Generated: ${report.generatedAt.toIso8601String()}'),
            const Text(
                'All measurements below are SIMULATED for education — not a substitute for supervised lab work.'),
            const Divider(),
            for (final e in report.sections.entries) ...[
              Text(e.key,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(e.value),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
