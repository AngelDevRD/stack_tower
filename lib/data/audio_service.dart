import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around audioplayers. No copyrighted assets are bundled; playback
/// is a graceful no-op when the asset file is missing (see README).
class AudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  Future<void> playPlace() => _playSfx('sounds/place.mp3');
  Future<void> playPerfect() => _playSfx('sounds/perfect.mp3');
  Future<void> playGameOver() => _playSfx('sounds/game_over.mp3');

  Future<void> _playSfx(String assetPath) async {
    try {
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      // Asset missing or platform audio unavailable: no-op by design.
      debugPrint('AudioService: sfx "$assetPath" unavailable ($e)');
    }
  }

  Future<void> startMusic() async {
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('sounds/music.mp3'));
    } catch (e) {
      debugPrint('AudioService: music unavailable ($e)');
    }
  }

  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      debugPrint('AudioService: stop music failed ($e)');
    }
  }

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
