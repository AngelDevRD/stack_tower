import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/audio_service.dart';
import '../data/daily_challenge_repository.dart';
import '../data/progress_repository.dart';
import '../data/settings_repository.dart';
import '../data/stats_repository.dart';
import '../domain/block_math.dart';
import 'game_models.dart';

/// Fixed game world width (logical pixels); the widget layer scales this to the screen.
const double kWorldWidth = 360;
const double kBlockHeight = 32;
const double kInitialBlockWidth = 100;

/// Optional daily-challenge target height; null means infinite mode (no target).
class GameController extends StateNotifier<GameState> {
  final SettingsRepository settingsRepo;
  final ProgressRepository progressRepo;
  final StatsRepository statsRepo;
  final DailyChallengeRepository dailyRepo;
  final AudioService audio;
  final int? dailyTarget;

  late final Ticker _ticker;
  double _elapsed = 0;
  double _blockSpawnTime = 0;
  double _oscMinX = 0;
  double _oscMaxX = 0;
  double _oscSpeed = 1.0;
  int _fallingIdCounter = 0;
  final Stopwatch _playTime = Stopwatch();

  /// Public read of the current state; `state` itself is protected by
  /// StateNotifier for use only within subclasses.
  GameState get value => state;
  bool _dailyCompletedThisRun = false;

  GameController({
    required this.settingsRepo,
    required this.progressRepo,
    required this.statsRepo,
    required this.dailyRepo,
    required this.audio,
    required TickerProvider vsync,
    this.dailyTarget,
  }) : super(
         GameState(
           phase: GamePhase.playing,
           blocks: const [
             PlacedBlock(
               left: (kWorldWidth - kInitialBlockWidth) / 2,
               width: kInitialBlockWidth,
               height: 0,
               wasPerfect: false,
             ),
           ],
           fallingPieces: const [],
           currentLeft: 0,
           currentWidth: kInitialBlockWidth,
           score: 0,
           perfectStreak: 0,
           lastWasPerfect: false,
           cameraOffset: 0,
         ),
       ) {
    _playTime.start();
    _spawnNextBlock();
    _ticker = vsync.createTicker(_onTick);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (state.phase != GamePhase.playing) return;
    _elapsed = elapsed.inMicroseconds / 1e6;
    final t = _elapsed - _blockSpawnTime;
    final x = oscillatingX(
      t: t,
      minX: _oscMinX,
      maxX: _oscMaxX,
      speed: _oscSpeed,
    );
    state = state.copyWith(currentLeft: x);
  }

  void _spawnNextBlock() {
    final lastBlock = state.blocks.last;
    final width = lastBlock.width;
    _oscMinX = 0;
    _oscMaxX = (kWorldWidth - width).clamp(0, kWorldWidth).toDouble();
    _oscSpeed = speedForHeight(state.height);
    _blockSpawnTime = _elapsed;
    state = state.copyWith(currentWidth: width, currentLeft: _oscMinX);
  }

  /// Drops the currently oscillating block. Call on tap.
  Future<void> drop() async {
    if (state.phase != GamePhase.playing) return;

    final below = state.blocks.last;
    final result = computeOverlap(
      fallingLeft: state.currentLeft,
      fallingWidth: state.currentWidth,
      belowLeft: below.left,
      belowWidth: below.width,
    );

    if (result.isMiss) {
      await _endGame();
      return;
    }

    final newHeight = state.height;
    final placed = PlacedBlock(
      left: result.left,
      width: result.width,
      height: newHeight,
      wasPerfect: result.isPerfect,
    );

    final newFalling = <FallingPiece>[...state.fallingPieces];
    if (result.cutLeft != null &&
        result.cutWidth != null &&
        result.cutWidth! > 0) {
      newFalling.add(
        FallingPiece(
          left: result.cutLeft!,
          width: result.cutWidth!,
          top: newHeight * kBlockHeight,
          id: _fallingIdCounter++,
        ),
      );
    }

    final newStreak = result.isPerfect ? state.perfectStreak + 1 : 0;
    final bonus = scoreBonusForRatio(result.ratio);

    state = state.copyWith(
      blocks: [...state.blocks, placed],
      fallingPieces: newFalling,
      score: state.score + 1 + bonus,
      perfectStreak: newStreak,
      lastWasPerfect: result.isPerfect,
      cameraOffset: _cameraOffsetForHeight(state.height + 1),
    );

    unawaited(audio.playPlace());
    if (result.isPerfect) {
      unawaited(audio.playPerfect());
      unawaited(statsRepo.addPerfectPlacement());
      if (newStreak >= 5) {
        unawaited(progressRepo.unlockAchievement('perfect_streak_5'));
      }
    }
    unawaited(progressRepo.unlockThemesForScore(state.score));
    await _checkHeightAchievements(newHeight + 1);
    await _checkDailyChallenge(newHeight + 1);

    _spawnNextBlock();
  }

  double _cameraOffsetForHeight(int height) {
    const visibleBlocks = 8;
    final overflow = height - visibleBlocks;
    return overflow > 0 ? overflow * kBlockHeight.toDouble() : 0;
  }

  Future<void> _checkHeightAchievements(int height) async {
    if (height >= 10) await progressRepo.unlockAchievement('height_10');
    if (height >= 25) await progressRepo.unlockAchievement('height_25');
    if (height >= 50) await progressRepo.unlockAchievement('height_50');
  }

  Future<void> _checkDailyChallenge(int height) async {
    if (dailyTarget == null || _dailyCompletedThisRun) return;
    if (height >= dailyTarget!) {
      _dailyCompletedThisRun = true;
      await dailyRepo.markTodayCompleted();
    }
  }

  Future<void> _endGame() async {
    _playTime.stop();
    _ticker.stop();
    unawaited(audio.playGameOver());
    state = state.copyWith(phase: GamePhase.gameOver);
    await statsRepo.recordGameEnd(
      heightReached: state.height,
      score: state.score,
      playTime: _playTime.elapsed,
    );
    final gamesPlayed = await statsRepo.getGamesPlayed();
    if (gamesPlayed >= 20) await progressRepo.unlockAchievement('games_20');
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
