import 'package:flutter/foundation.dart';

/// A placed (landed) block in the tower.
@immutable
class PlacedBlock {
  final double left;
  final double width;
  final int height; // 0-based index in the tower
  final bool wasPerfect;

  const PlacedBlock({
    required this.left,
    required this.width,
    required this.height,
    required this.wasPerfect,
  });
}

/// A discarded cut-off piece currently falling/fading out.
@immutable
class FallingPiece {
  final double left;
  final double width;
  final double top; // world Y at spawn
  final int id;

  const FallingPiece({
    required this.left,
    required this.width,
    required this.top,
    required this.id,
  });
}

enum GamePhase { playing, gameOver }

@immutable
class GameState {
  final GamePhase phase;
  final List<PlacedBlock> blocks;
  final List<FallingPiece> fallingPieces;
  final double currentLeft;
  final double currentWidth;
  final int score;
  final int perfectStreak;
  final bool lastWasPerfect;
  final double cameraOffset;

  const GameState({
    required this.phase,
    required this.blocks,
    required this.fallingPieces,
    required this.currentLeft,
    required this.currentWidth,
    required this.score,
    required this.perfectStreak,
    required this.lastWasPerfect,
    required this.cameraOffset,
  });

  int get height => blocks.length;

  GameState copyWith({
    GamePhase? phase,
    List<PlacedBlock>? blocks,
    List<FallingPiece>? fallingPieces,
    double? currentLeft,
    double? currentWidth,
    int? score,
    int? perfectStreak,
    bool? lastWasPerfect,
    double? cameraOffset,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      blocks: blocks ?? this.blocks,
      fallingPieces: fallingPieces ?? this.fallingPieces,
      currentLeft: currentLeft ?? this.currentLeft,
      currentWidth: currentWidth ?? this.currentWidth,
      score: score ?? this.score,
      perfectStreak: perfectStreak ?? this.perfectStreak,
      lastWasPerfect: lastWasPerfect ?? this.lastWasPerfect,
      cameraOffset: cameraOffset ?? this.cameraOffset,
    );
  }
}
