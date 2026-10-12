import 'package:flutter/material.dart';

import '../../catalogue/domain/practical_registry.dart';
import '../../laboratory/domain/lab_session.dart';
import '../domain/assessment_engine.dart';

/// Practical-specific MCQ gate. Result unlocks ONLY its own practical.
class McqScreen extends StatefulWidget {
  final PracticalRegistry registry;
  final LabSessionManager sessionManager;
  final String practicalId;
  const McqScreen({
    super.key,
    required this.registry,
    required this.sessionManager,
    required this.practicalId,
  });

  @override
  State<McqScreen> createState() => _McqScreenState();
}

class _McqScreenState extends State<McqScreen> {
  final Map<String, String> answers = {};
  AssessmentResult? result;

  @override
  void initState() {
    super.initState();
    // Fresh session per attempt for this practical.
    final active = widget.sessionManager.active;
    if (active == null || active.practicalId != widget.practicalId) {
      widget.sessionManager.createSession(widget.practicalId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final def = widget.registry.resolve(widget.practicalId);
    final a = def.assessment;
    return Scaffold(
      appBar: AppBar(title: Text('Pre-lab: ${def.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            for (final q in a.questions) ...[
              Text(q.text, style: const TextStyle(fontWeight: FontWeight.bold)),
              RadioGroup<String>(
                groupValue: answers[q.id],
                onChanged: (v) => setState(() => answers[q.id] = v ?? ''),
                child: Column(
                  children: [
                    for (final o in q.options)
                      RadioListTile<String>(title: Text(o.text), value: o.id),
                  ],
                ),
              ),
              if (result != null)
                Text(
                  'Explanation: ${q.explanation}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              const Divider(),
            ],
            FilledButton(
              onPressed: () {
                final r = AssessmentEngine.evaluate(a, answers);
                setState(() => result = r);
                final s = widget.sessionManager.active!;
                widget.sessionManager.update(
                  s.copyWith(
                    assessmentAnswers: Map.from(answers),
                    assessmentPassed: r.passed,
                  ),
                );
              },
              child: const Text('Submit'),
            ),
            if (result != null) ...[
              const SizedBox(height: 8),
              Text(
                'Score: ${result!.correct}/${result!.total} (${(result!.score * 100).toStringAsFixed(0)}%) — ${result!.passed ? 'PASSED' : 'NOT PASSED'}',
              ),
              if (result!.passed)
                FilledButton.tonal(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/lab',
                    arguments: widget.practicalId,
                  ),
                  child: const Text('Enter interactive lab'),
                )
              else
                const Text('Retry: change answers and resubmit.'),
            ],
          ],
        ),
      ),
    );
  }
}
