import 'package:shared_preferences/shared_preferences.dart';

/// Deterministic daily target height, rotating by date. Same day always yields the
/// same target; a new calendar day yields a new (and resets completion).
class DailyChallengeRepository {
  static const _kDate = 'daily.date';
  static const _kCompleted = 'daily.completed';

  /// Today's date as a stable key, e.g. "2026-07-06".
  String todayKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Target tower height for today, derived deterministically from the date key.
  int targetHeightFor(String dateKey) {
    final seed = dateKey.hashCode.abs();
    // Keep the daily target within a reasonable, always-reachable band.
    return 10 + (seed % 16); // 10..25
  }

  /// Returns whether today's challenge was already completed, resetting state
  /// (clearing completion) if the stored date differs from today.
  Future<bool> isTodayCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDate = prefs.getString(_kDate);
    final today = todayKey();
    if (storedDate != today) {
      await prefs.setString(_kDate, today);
      await prefs.setBool(_kCompleted, false);
      return false;
    }
    return prefs.getBool(_kCompleted) ?? false;
  }

  Future<void> markTodayCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDate, todayKey());
    await prefs.setBool(_kCompleted, true);
  }

  Future<int> getTodayTarget() async => targetHeightFor(todayKey());
}
