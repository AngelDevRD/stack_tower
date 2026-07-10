import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/audio_service.dart';
import '../data/daily_challenge_repository.dart';
import '../data/progress_repository.dart';
import '../data/settings_repository.dart';
import '../data/stats_repository.dart';

final settingsRepositoryProvider = Provider((ref) => SettingsRepository());
final progressRepositoryProvider = Provider((ref) => ProgressRepository());
final statsRepositoryProvider = Provider((ref) => StatsRepository());
final dailyChallengeRepositoryProvider = Provider(
  (ref) => DailyChallengeRepository(),
);
final audioServiceProvider = Provider((ref) => AudioService());

/// Settings loaded once at app start and kept in memory; screens update via repo + refresh.
class SettingsState {
  final bool sound;
  final bool music;
  final bool vibration;
  final bool? darkMode;
  final bool tutorialSeen;

  const SettingsState({
    required this.sound,
    required this.music,
    required this.vibration,
    required this.darkMode,
    required this.tutorialSeen,
  });

  SettingsState copyWith({
    bool? sound,
    bool? music,
    bool? vibration,
    bool? darkMode,
    bool? tutorialSeen,
  }) {
    return SettingsState(
      sound: sound ?? this.sound,
      music: music ?? this.music,
      vibration: vibration ?? this.vibration,
      darkMode: darkMode ?? this.darkMode,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository repo;
  SettingsNotifier(this.repo)
    : super(
        const SettingsState(
          sound: true,
          music: true,
          vibration: true,
          darkMode: null,
          tutorialSeen: false,
        ),
      ) {
    _load();
  }

  Future<void> _load() async {
    state = SettingsState(
      sound: await repo.getSoundEnabled(),
      music: await repo.getMusicEnabled(),
      vibration: await repo.getVibrationEnabled(),
      darkMode: await repo.getDarkMode(),
      tutorialSeen: await repo.getTutorialSeen(),
    );
  }

  Future<void> setSound(bool value) async {
    state = state.copyWith(sound: value);
    await repo.setSoundEnabled(value);
  }

  Future<void> setMusic(bool value) async {
    state = state.copyWith(music: value);
    await repo.setMusicEnabled(value);
  }

  Future<void> setVibration(bool value) async {
    state = state.copyWith(vibration: value);
    await repo.setVibrationEnabled(value);
  }

  Future<void> setDarkMode(bool value) async {
    state = state.copyWith(darkMode: value);
    await repo.setDarkMode(value);
  }

  Future<void> setTutorialSeen(bool value) async {
    state = state.copyWith(tutorialSeen: value);
    await repo.setTutorialSeen(value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(ref.read(settingsRepositoryProvider)),
);

/// Per-game-session controller. `dailyTarget` (null = infinite mode) is passed via
/// [gameArgsProvider] before this provider is first read for a given game screen.
final gameArgsProvider = StateProvider<int?>((ref) => null);
