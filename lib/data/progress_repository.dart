import 'package:shared_preferences/shared_preferences.dart';

/// Score milestones required to unlock each theme (index = theme id).
const List<int> kThemeUnlockScores = [0, 10, 25, 50];

/// Achievement ids used as keys and shown in the Achievements screen.
const List<String> kAchievementIds = [
  'height_10',
  'height_25',
  'height_50',
  'perfect_streak_5',
  'games_20',
];

const Map<String, String> kAchievementLabels = {
  'height_10': 'Alcanza altura 10',
  'height_25': 'Alcanza altura 25',
  'height_50': 'Alcanza altura 50',
  'perfect_streak_5': '5 colocaciones perfectas seguidas',
  'games_20': 'Juega 20 partidas',
};

/// Persisted unlocked themes and unlocked achievements, plus current theme choice.
class ProgressRepository {
  static const _kUnlockedThemes = 'progress.unlockedThemes';
  static const _kSelectedTheme = 'progress.selectedTheme';
  static const _kAchievements = 'progress.achievements';

  Future<Set<int>> getUnlockedThemes() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kUnlockedThemes) ?? ['0'];
    return list.map(int.parse).toSet();
  }

  Future<void> unlockThemesForScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = await getUnlockedThemes();
    for (var i = 0; i < kThemeUnlockScores.length; i++) {
      if (score >= kThemeUnlockScores[i]) unlocked.add(i);
    }
    await prefs.setStringList(
      _kUnlockedThemes,
      unlocked.map((e) => e.toString()).toList(),
    );
  }

  Future<int> getSelectedTheme() async =>
      (await SharedPreferences.getInstance()).getInt(_kSelectedTheme) ?? 0;

  Future<void> setSelectedTheme(int themeId) async =>
      (await SharedPreferences.getInstance()).setInt(_kSelectedTheme, themeId);

  Future<Set<String>> getUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kAchievements) ?? []).toSet();
  }

  /// Unlocks [id] if not already unlocked. Returns true if newly unlocked.
  Future<bool> unlockAchievement(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = await getUnlockedAchievements();
    if (unlocked.contains(id)) return false;
    unlocked.add(id);
    await prefs.setStringList(_kAchievements, unlocked.toList());
    return true;
  }
}
