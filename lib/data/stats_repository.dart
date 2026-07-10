import 'package:shared_preferences/shared_preferences.dart';

/// Aggregate persisted stats and running per-session helpers (best score, perfect streak).
class StatsRepository {
  static const _kGamesPlayed = 'stats.gamesPlayed';
  static const _kBestHeight = 'stats.bestHeight';
  static const _kTotalPerfects = 'stats.totalPerfects';
  static const _kTotalPlayTimeMs = 'stats.totalPlayTimeMs';
  static const _kBestScore = 'stats.bestScore';

  Future<int> getGamesPlayed() async =>
      (await SharedPreferences.getInstance()).getInt(_kGamesPlayed) ?? 0;

  Future<int> getBestHeight() async =>
      (await SharedPreferences.getInstance()).getInt(_kBestHeight) ?? 0;

  Future<int> getTotalPerfects() async =>
      (await SharedPreferences.getInstance()).getInt(_kTotalPerfects) ?? 0;

  Future<Duration> getTotalPlayTime() async {
    final ms =
        (await SharedPreferences.getInstance()).getInt(_kTotalPlayTimeMs) ?? 0;
    return Duration(milliseconds: ms);
  }

  Future<int> getBestScore() async =>
      (await SharedPreferences.getInstance()).getInt(_kBestScore) ?? 0;

  Future<void> addPerfectPlacement() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTotalPerfects, (await getTotalPerfects()) + 1);
  }

  /// Records the end of a game: increments games played, updates best height/score,
  /// and accumulates play time.
  Future<void> recordGameEnd({
    required int heightReached,
    required int score,
    required Duration playTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kGamesPlayed, (await getGamesPlayed()) + 1);
    final bestHeight = await getBestHeight();
    if (heightReached > bestHeight) {
      await prefs.setInt(_kBestHeight, heightReached);
    }
    final bestScore = await getBestScore();
    if (score > bestScore) await prefs.setInt(_kBestScore, score);
    final totalMs = (await getTotalPlayTime()).inMilliseconds;
    await prefs.setInt(_kTotalPlayTimeMs, totalMs + playTime.inMilliseconds);
  }
}
