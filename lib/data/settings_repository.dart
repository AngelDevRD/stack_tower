import 'package:shared_preferences/shared_preferences.dart';

/// Persisted user settings. All flags default to sensible "on" values.
class SettingsRepository {
  static const _kSound = 'settings.sound';
  static const _kMusic = 'settings.music';
  static const _kVibration = 'settings.vibration';
  static const _kDarkMode = 'settings.darkMode';
  static const _kTutorialSeen = 'settings.tutorialSeen';

  Future<bool> getSoundEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_kSound) ?? true;
  Future<void> setSoundEnabled(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_kSound, value);

  Future<bool> getMusicEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_kMusic) ?? true;
  Future<void> setMusicEnabled(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_kMusic, value);

  Future<bool> getVibrationEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_kVibration) ?? true;
  Future<void> setVibrationEnabled(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_kVibration, value);

  /// Null means "system default" (not yet chosen by the user).
  Future<bool?> getDarkMode() async =>
      (await SharedPreferences.getInstance()).getBool(_kDarkMode);
  Future<void> setDarkMode(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_kDarkMode, value);

  Future<bool> getTutorialSeen() async =>
      (await SharedPreferences.getInstance()).getBool(_kTutorialSeen) ?? false;
  Future<void> setTutorialSeen(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_kTutorialSeen, value);
}
