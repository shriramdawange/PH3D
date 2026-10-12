import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

import '../../catalogue/domain/practical_definition.dart';
import '../../laboratory/domain/lab_session.dart';

/// Renderer boundary. The rest of the app must not depend on
/// renderer-specific classes.
///
/// Two honest states exist:
/// - `temporary`: clearly labelled stand-in used by tests and as an
///   explicit fallback. Never presented as a working 3D lab.
/// - `model_viewer`: genuine interactive 3D via Google `<model-viewer>`,
///   only on verified platforms (Android, iOS, macOS, Web). Other
///   platforms get an explicit unsupported state, never a silent fallback.
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
          EquipmentChips(
            definition: definition,
            session: session,
            onEquipmentTap: onEquipmentTap,
          ),
        ],
      ),
    );
  }
}

/// Genuine interactive 3D viewport (orbit/zoom via `<model-viewer>`).
/// Equipment selection stays as typed actions below the viewport until
/// scene hotspots are wired to the procedure/session engine — the UI
/// says so explicitly and claims nothing more.
class ModelViewerAdapter extends RendererAdapter {
  final PracticalDefinition definition;
  final LabSession session;
  final void Function(String equipmentId) onEquipmentTap;

  const ModelViewerAdapter({
    super.key,
    required this.definition,
    required this.session,
    required this.onEquipmentTap,
  });

  @override
  String get rendererKind => 'model_viewer';

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
            'INTERACTIVE 3D — orbit/zoom the scene below.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Scene: ${definition.scene.sceneAsset}'),
          Text('Practical: ${definition.id}'),
          const Text(
            'Placeholder geometry — NOT a laboratory bench. '
            'REQUIRES_EDUCATOR_REVIEW for real bench scenes.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 320,
            child: _ModelViewerViewport(
              sceneAsset: definition.scene.sceneAsset,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Equipment selection is not yet connected to the 3D scene; '
            'use the typed actions below (procedure/session engine).',
          ),
          EquipmentChips(
            definition: definition,
            session: session,
            onEquipmentTap: onEquipmentTap,
          ),
        ],
      ),
    );
  }
}

/// Owns the WebView-backed viewer lifecycle: one controller per viewport
/// instance, created in [initState], never shared, never reused.
class _ModelViewerViewport extends StatefulWidget {
  final String sceneAsset;
  const _ModelViewerViewport({required this.sceneAsset});

  @override
  State<_ModelViewerViewport> createState() => _ModelViewerViewportState();
}

class _ModelViewerViewportState extends State<_ModelViewerViewport> {
  late final Flutter3DController _controller;
  double? _progress;
  bool _loaded = false;
  String? _error;
  int _reloadCount = 0;

  @override
  void initState() {
    super.initState();
    // NOTE: do NOT dispose _controller.onModelLoaded here. Flutter3DViewer's
    // own State.dispose() disposes it (verified in flutter_3d_controller
    // 2.3.0 source); manual disposal would double-dispose, and sharing this
    // controller would be use-after-dispose.
    _controller = Flutter3DController();
  }

  void _retry() {
    setState(() {
      _error = null;
      _loaded = false;
      _progress = null;
      _reloadCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Flutter3DViewer(
          key: ValueKey('model-view-$_reloadCount'),
          src: widget.sceneAsset,
          controller: _controller,
          onProgress: (p) {
            if (mounted) setState(() => _progress = p);
          },
          onLoad: (_) {
            if (mounted) {
              setState(() {
                _loaded = true;
                _error = null;
              });
            }
          },
          onError: (e) {
            if (mounted) setState(() => _error = e);
          },
        ),
        if (!_loaded && _error == null)
          Positioned.fill(
            child: Container(
              color: Colors.black12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    _progress == null
                        ? 'Loading 3D scene…'
                        : 'Loading 3D scene… '
                              '${(_progress! * 100).toStringAsFixed(0)}%',
                  ),
                ],
              ),
            ),
          ),
        if (_error != null)
          Positioned.fill(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '3D scene failed to load.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_error!),
                  const SizedBox(height: 8),
                  FilledButton(onPressed: _retry, child: const Text('Retry')),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Explicit, visible state for platforms with no verified 3D renderer.
/// Never substituted silently; never claims 3D works here.
class UnsupportedPlatformAdapter extends RendererAdapter {
  final PracticalDefinition definition;
  final TargetPlatform platform;

  const UnsupportedPlatformAdapter({
    super.key,
    required this.definition,
    required this.platform,
  });

  @override
  String get rendererKind => 'unsupported_platform';

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
            '3D NOT SUPPORTED ON THIS PLATFORM.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Platform: ${platform.name}'),
          Text('Practical: ${definition.id}'),
          const Text(
            'Interactive 3D is verified for Android and Web. Use one of '
            'those targets for the 3D scene. Catalogue, MCQ, procedure, '
            'simulation, and reports remain fully usable here.',
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.maybePop(context),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}

/// Shared typed equipment actions. Emits equipment IDs only; the caller
/// (LabShell) validates against the active session's own definition, so a
/// renderer callback can never change the practical ID or leak state.
class EquipmentChips extends StatelessWidget {
  final PracticalDefinition definition;
  final LabSession session;
  final void Function(String equipmentId) onEquipmentTap;

  const EquipmentChips({
    super.key,
    required this.definition,
    required this.session,
    required this.onEquipmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
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
    );
  }
}

/// Explicit renderer strategy registry: practical scene + platform ->
/// adapter. Unknown renderer kinds throw; unsupported platforms get an
/// explicit state. Nothing resolves silently.
class RendererRegistry {
  static const supported3DPlatforms = {
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  };

  static RendererAdapter resolve({
    required PracticalDefinition definition,
    required LabSession session,
    required void Function(String equipmentId) onEquipmentTap,
    TargetPlatform? platformOverride,
  }) {
    switch (definition.scene.rendererKind) {
      case 'temporary':
        return TemporaryRendererAdapter(
          definition: definition,
          session: session,
          onEquipmentTap: onEquipmentTap,
        );
      case 'model_viewer':
        if (kIsWeb) {
          return ModelViewerAdapter(
            definition: definition,
            session: session,
            onEquipmentTap: onEquipmentTap,
          );
        }
        final platform = platformOverride ?? defaultTargetPlatform;
        if (supported3DPlatforms.contains(platform)) {
          return ModelViewerAdapter(
            definition: definition,
            session: session,
            onEquipmentTap: onEquipmentTap,
          );
        }
        return UnsupportedPlatformAdapter(
          definition: definition,
          platform: platform,
        );
      default:
        throw UnsupportedError(
          'Renderer "${definition.scene.rendererKind}" for ${definition.id} is not implemented.',
        );
    }
  }
}
