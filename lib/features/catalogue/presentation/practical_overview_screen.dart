import 'package:flutter/material.dart';

import '../../catalogue/domain/practical_definition.dart';
import '../../catalogue/domain/practical_registry.dart';
import '../../../app/lab_launcher.dart';

class PracticalOverviewScreen extends StatelessWidget {
  final PracticalRegistry registry;
  final LabLauncher launcher;
  final String practicalId;
  const PracticalOverviewScreen({
    super.key,
    required this.registry,
    required this.launcher,
    required this.practicalId,
  });

  @override
  Widget build(BuildContext context) {
    late final PracticalDefinition def;
    try {
      def = registry.resolve(practicalId);
    } catch (e) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            'Invalid configuration for "$practicalId": $e. No silent fallback.',
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(def.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('${def.semesterLabel} • ${def.subjectLabel}'),
            const SizedBox(height: 8),
            Text(def.description),
            const SizedBox(height: 12),
            const Text(
              'Learning objectives',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            for (final o in def.learningObjectives) Text('• $o'),
            const SizedBox(height: 12),
            Text(
              'Content status: ${def.reviewStatus.name} — simulated results are labelled simulated.',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                // Fresh session per attempt is created at MCQ entry.
                Navigator.pushNamed(context, '/mcq', arguments: def.id);
              },
              child: const Text('Start pre-lab MCQ'),
            ),
          ],
        ),
      ),
    );
  }
}
