import 'package:flutter/material.dart';

import '../../catalogue/domain/practical_definition.dart';
import '../../laboratory/domain/lab_session.dart';

/// Renderer boundary. The rest of the app must not depend on
/// renderer-specific classes. `rendererKind == 'temporary'` means real
/// interactive 3D is NOT yet wired — UI must label it as such and must
/// never claim it is a working 3D lab.
abstract class RendererAdapter extends StatelessWidget {
  const RendererAdapter({super.key});
  String get rendererKind;
}

class TemporaryRendererAdapter extends RendererAdapter {
  final PracticalDefinition definition;
  final LabSession session;
  final void Function(String equipmentId) onEquipmentTap;

  const TemporaryRendererAdapter({
    super.key,
    required this.definition,
    required this.session,
    required this.onEquipmentTap,
  });

  @override
  String get rendererKind => 'temporary';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'TEMPORARY RENDERER — real interactive 3D not yet implemented.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Scene: ${definition.scene.sceneAsset}'),
          Text('Practical: ${definition.id}'),
          const SizedBox(height: 8),
          const Text(
            'Tap equipment below to simulate selection (typed actions):',
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final e in definition.equipment)
                GestureDetector(
                  onTap: () => onEquipmentTap(e.id),
                  child: Chip(
                    label: Text(e.label),
                    backgroundColor: session.selectedEquipmentIds.contains(e.id)
                        ? Colors.green.shade100
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Explicit renderer strategy registry: practical scene -> adapter.
/// Currently only the temporary adapter; real 3D adapters register here
/// once a verified package + assets exist.
class RendererRegistry {
  static RendererAdapter resolve({
    required PracticalDefinition definition,
    required LabSession session,
    required void Function(String equipmentId) onEquipmentTap,
  }) {
    // Only temporary is supported in MVP slice. Any other rendererKind
    // in config is surfaced as an explicit error, never a silent fallback.
    if (definition.scene.rendererKind != 'temporary') {
      throw UnsupportedError(
        'Renderer "${definition.scene.rendererKind}" for ${definition.id} is not implemented.',
      );
    }
    return TemporaryRendererAdapter(
      definition: definition,
      session: session,
      onEquipmentTap: onEquipmentTap,
    );
  }
}
