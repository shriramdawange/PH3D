import 'package:flutter/material.dart';
import '../../catalogue/domain/practical_registry.dart';
import '../../laboratory/domain/lab_session.dart';
import '../../procedure/domain/procedure_engine.dart';
import '../../simulation/domain/simulation_engine.dart';
import '../../laboratory/rendering/renderer_adapter.dart';

/// Shared LabShell: common controls, practical-specific configuration.
/// No `if (practicalName == ...)` branches — all differences come from
/// the resolved PracticalDefinition + active LabSession.
class LabShellScreen extends StatelessWidget {
  final PracticalRegistry registry;
  final LabSessionManager sessionManager;
  final String practicalId;
  const LabShellScreen(
      {super.key,
      required this.registry,
      required this.sessionManager,
      required this.practicalId});

  @override
  Widget build(BuildContext context) {
    final def = registry.resolve(practicalId);
    return ListenableBuilder(
      listenable: sessionManager,
      builder: (context, _) {
        var session = sessionManager.active;
        if (session == null || session.practicalId != practicalId) {
          // Explicit failure, never silent navigation to unrelated page.
          return Scaffold(
            appBar: AppBar(title: const Text('Lab')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'No active session for "$practicalId". Complete the MCQ gate first.'),
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(context, '/mcq',
                        arguments: practicalId),
                    child: const Text('Go to MCQ gate'),
                  ),
                ],
              ),
            ),
          );
        }
        if (!session.assessmentPassed && def.assessment.requiredGate) {
          return Scaffold(
            appBar: AppBar(title: Text('Lab — ${def.title}')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('MCQ gate not passed for this practical.'),
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(context, '/mcq',
                        arguments: practicalId),
                    child: const Text('Go to MCQ gate'),
                  ),
                ],
              ),
            ),
          );
        }

        final observations =
            SimulationEngine.observationsFor(def, session);

        return Scaffold(
          appBar: AppBar(
            title: Text('Lab — ${def.title}'),
            actions: [
              IconButton(
                tooltip: 'Reset session',
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    sessionManager.createSession(practicalId),
              ),
            ],
          ),
          body: LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth > 800;
            final left = _LabMainPanel(
                registry: registry,
                sessionManager: sessionManager,
                practicalId: practicalId);
            final right = _LabSidePanel(
                registry: registry,
                sessionManager: sessionManager,
                practicalId: practicalId,
                observations: observations);
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: left),
                  Expanded(flex: 2, child: right),
                ],
              );
            }
            return ListView(children: [left, right]);
          }),
        );
      },
    );
  }
}

class _LabMainPanel extends StatelessWidget {
  final PracticalRegistry registry;
  final LabSessionManager sessionManager;
  final String practicalId;
  const _LabMainPanel(
      {required this.registry,
      required this.sessionManager,
      required this.practicalId});

  @override
  Widget build(BuildContext context) {
    final def = registry.resolve(practicalId);
    final session = sessionManager.active!;
    RendererAdapter scene;
    try {
      scene = RendererRegistry.resolve(
        definition: def,
        session: session,
        onEquipmentTap: (eq) {
          final next = Set<String>.from(session.selectedEquipmentIds);
          if (next.contains(eq)) {
            next.remove(eq);
          } else {
            next.add(eq);
          }
          sessionManager.update(
              session.copyWith(selectedEquipmentIds: next));
        },
      );
    } catch (e) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Scene failed to load: $e'))),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          scene,
          const SizedBox(height: 12),
          const Text('Procedure',
              style: TextStyle(fontWeight: FontWeight.bold)),
          for (final step in def.steps)
            Card(
              child: ListTile(
                title: Text('${step.order}. ${step.title}'),
                subtitle: Text(step.instruction),
                trailing: session.completedStepIds.contains(step.id)
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : FilledButton.tonal(
                        onPressed: () {
                          final r =
                              ProcedureEngine.completeStep(def, session, step.id);
                          if (r.accepted) {
                            final done = Set<String>.from(
                                session.completedStepIds)
                              ..add(step.id);
                            final completed =
                                done.length == def.steps.length;
                            sessionManager.update(session.copyWith(
                              completedStepIds: done,
                              currentStepId: step.id,
                              observations:
                                  List<String>.from(session.observations)
                                    ..add(
                                        'SIMULATED: ${step.title} done.'),
                              completed: completed,
                            ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        '${r.message} (${r.code})')));
                            sessionManager.update(session.copyWith(
                                warnings: List<String>.from(session.warnings)
                                  ..add('${r.code}: ${r.message}')));
                          }
                        },
                        child: const Text('Complete'),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LabSidePanel extends StatefulWidget {
  final PracticalRegistry registry;
  final LabSessionManager sessionManager;
  final String practicalId;
  final List<String> observations;
  const _LabSidePanel(
      {required this.registry,
      required this.sessionManager,
      required this.practicalId,
      required this.observations});

  @override
  State<_LabSidePanel> createState() => _LabSidePanelState();
}

class _LabSidePanelState extends State<_LabSidePanel> {
  final Map<String, String> qtyText = {};
  final Map<String, String> unitSel = {};

  @override
  Widget build(BuildContext context) {
    final def = widget.registry.resolve(widget.practicalId);
    final session = widget.sessionManager.active!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Materials & quantities (explicit units)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          for (final m in def.materials)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.label),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                                labelText: 'Quantity',
                                hintText: 'e.g. 5'),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            onChanged: (v) => qtyText[m.id] = v,
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: unitSel[m.id] ?? m.allowedUnits.first,
                          items: [
                            for (final u in m.allowedUnits)
                              DropdownMenuItem(
                                  value: u, child: Text(u)),
                          ],
                          onChanged: (v) =>
                              setState(() => unitSel[m.id] = v!),
                        ),
                        TextButton(
                          onPressed: () {
                            final unit =
                                unitSel[m.id] ?? m.allowedUnits.first;
                            final val = double.tryParse(
                                qtyText[m.id] ?? '');
                            if (val == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Enter a numeric quantity.')));
                              return;
                            }
                            final r =
                                ProcedureEngine.setQuantity(def, m.id, val, unit);
                            if (!r.accepted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(r.message)));
                              return;
                            }
                            widget.sessionManager.update(session.copyWith(
                              quantities: Map<String, double>.from(
                                  session.quantities)
                                ..[m.id] = val,
                              quantityUnits:
                                  Map<String, String>.from(
                                      session.quantityUnits)
                                    ..[m.id] = unit,
                            ));
                          },
                          child: const Text('Set'),
                        ),
                      ],
                    ),
                    if (session.quantities.containsKey(m.id))
                      Text(
                          'Set: ${session.quantities[m.id]} ${session.quantityUnits[m.id]}'),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Text('Observations / results (simulated)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final o in widget.observations) Text('• $o'),
                        for (final o in session.observations) Text('• $o'),
                      ]))),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, '/report',
                arguments: widget.practicalId),
            child: const Text('Preview practical report'),
          ),
        ],
      ),
    );
  }
}
