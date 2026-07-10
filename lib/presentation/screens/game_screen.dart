import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/app_providers.dart';
import '../../providers/game_controller.dart';
import '../../providers/game_models.dart';
import '../theme_palettes.dart';
import '../widgets/camera_viewport.dart';
import '../widgets/particle_burst.dart';
import '../widgets/tower_block_widget.dart';
import '../widgets/tutorial_overlay.dart';

/// Route extra: pass `dailyTarget` (int) for daily-challenge mode, or null for infinite.
class GameScreen extends ConsumerStatefulWidget {
  final int? dailyTarget;

  const GameScreen({super.key, this.dailyTarget});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  GameController? _controller;
  final List<_ActiveBurst> _bursts = [];
  int _burstId = 0;
  bool _showTutorial = false;
  bool _tutorialChecked = false;
  int _paletteId = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      _controller = GameController(
        settingsRepo: ref.read(settingsRepositoryProvider),
        progressRepo: ref.read(progressRepositoryProvider),
        statsRepo: ref.read(statsRepositoryProvider),
        dailyRepo: ref.read(dailyChallengeRepositoryProvider),
        audio: ref.read(audioServiceProvider),
        vsync: this,
        dailyTarget: widget.dailyTarget,
      );
      _controller!.addListener((_) {
        if (mounted) setState(() {});
      });
    }
    if (!_tutorialChecked) {
      _tutorialChecked = true;
      _maybeShowTutorial();
    }
    ref.read(progressRepositoryProvider).getSelectedTheme().then((id) {
      if (mounted) setState(() => _paletteId = id);
    });
  }

  Future<void> _maybeShowTutorial() async {
    final seen = ref.read(settingsProvider).tutorialSeen;
    if (!seen) {
      setState(() => _showTutorial = true);
    }
  }

  void _dismissTutorial() {
    setState(() => _showTutorial = false);
    ref.read(settingsProvider.notifier).setTutorialSeen(true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _handleTap(GameState before) async {
    if (before.phase != GamePhase.playing) return;
    final settings = ref.read(settingsProvider);
    await _controller!.drop();
    final after = _controller!.value;

    if (after.phase == GamePhase.gameOver) {
      if (settings.vibration) unawaited(HapticFeedback.heavyImpact());
      return;
    }

    if (after.blocks.length > before.blocks.length) {
      final placed = after.blocks.last;
      final palette = kBlockPalettes[_paletteId];
      setState(() {
        _bursts.add(
          _ActiveBurst(
            id: _burstId++,
            center: Offset(
              placed.left + placed.width / 2,
              placed.height * kBlockHeight.toDouble(),
            ),
            color: palette.colorForHeight(placed.height),
            big: placed.wasPerfect,
          ),
        );
      });
      if (settings.vibration) {
        unawaited(
          placed.wasPerfect
              ? HapticFeedback.mediumImpact()
              : HapticFeedback.lightImpact(),
        );
      }
    }
  }

  void _removeBurst(int id) {
    setState(() => _bursts.removeWhere((b) => b.id == id));
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller!.value;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B2E),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final scale = constraints.maxWidth / kWorldWidth;
                return Stack(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _handleTap(state),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: Transform.scale(
                          scale: scale,
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: kWorldWidth,
                            height: constraints.maxHeight / scale,
                            child: CameraViewport(
                              targetOffset: state.cameraOffset,
                              child: Stack(
                                children: [
                                  for (final block in state.blocks)
                                    TowerBlockWidget(
                                      left: block.left,
                                      width: block.width,
                                      top: _blockTop(
                                        constraints.maxHeight / scale,
                                        block.height,
                                      ),
                                      blockHeight: kBlockHeight,
                                      color: kBlockPalettes[_paletteId]
                                          .colorForHeight(block.height),
                                      highlight: block.wasPerfect,
                                    ),
                                  for (final piece in state.fallingPieces)
                                    _FallingPieceWidget(
                                      key: ValueKey(piece.id),
                                      left: piece.left,
                                      width: piece.width,
                                      top: _blockTop(
                                        constraints.maxHeight / scale,
                                        piece.top ~/ kBlockHeight,
                                      ),
                                    ),
                                  if (state.phase == GamePhase.playing)
                                    TowerBlockWidget(
                                      left: state.currentLeft,
                                      width: state.currentWidth,
                                      top: _blockTop(
                                        constraints.maxHeight / scale,
                                        state.height,
                                      ),
                                      blockHeight: kBlockHeight,
                                      color: kBlockPalettes[_paletteId]
                                          .colorForHeight(state.height),
                                    ),
                                  for (final burst in _bursts)
                                    ParticleBurst(
                                      key: ValueKey(burst.id),
                                      center: burst.center,
                                      color: burst.color,
                                      big: burst.big,
                                      onComplete: () => _removeBurst(burst.id),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                            onPressed: () => context.go('/'),
                          ),
                          Text(
                            'Puntaje: ${state.score}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    if (widget.dailyTarget != null)
                      Positioned(
                        top: 56,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            'Meta diaria: altura ${widget.dailyTarget}',
                            style: const TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    if (state.phase == GamePhase.gameOver)
                      _GameOverOverlay(
                        state: state,
                        dailyTarget: widget.dailyTarget,
                      ),
                    if (_showTutorial)
                      TutorialOverlay(onDismiss: _dismissTutorial),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  double _blockTop(double viewportHeight, int height) {
    return viewportHeight - (height + 1) * kBlockHeight.toDouble();
  }
}

class _ActiveBurst {
  final int id;
  final Offset center;
  final Color color;
  final bool big;
  _ActiveBurst({
    required this.id,
    required this.center,
    required this.color,
    required this.big,
  });
}

class _FallingPieceWidget extends StatefulWidget {
  final double left;
  final double width;
  final double top;

  const _FallingPieceWidget({
    super.key,
    required this.left,
    required this.width,
    required this.top,
  });

  @override
  State<_FallingPieceWidget> createState() => _FallingPieceWidgetState();
}

class _FallingPieceWidgetState extends State<_FallingPieceWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final fall = Curves.easeIn.transform(_controller.value) * 150;
        final opacity = 1 - _controller.value;
        return Positioned(
          left: widget.left,
          top: widget.top + fall,
          width: widget.width,
          height: kBlockHeight,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final GameState state;
  final int? dailyTarget;

  const _GameOverOverlay({required this.state, required this.dailyTarget});

  @override
  Widget build(BuildContext context) {
    final reachedDaily = dailyTarget != null && state.height >= dailyTarget!;
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Fin del juego',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Puntaje: ${state.score}',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          Text(
            'Altura: ${state.height}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          if (dailyTarget != null) ...[
            const SizedBox(height: 8),
            Text(
              reachedDaily
                  ? 'Reto diario completado!'
                  : 'Reto diario no alcanzado',
              style: TextStyle(
                color: reachedDaily ? Colors.greenAccent : Colors.orangeAccent,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text('Volver al inicio'),
            ),
          ),
        ],
      ),
    );
  }
}
