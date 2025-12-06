import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  AudioService() {
    // Preload sounds to reduce latency
    _preloadSounds();
  }

  Future<void> _preloadSounds() async {
    // We don't await this to not block initialization
    try {
      // AudioCache is now built-in to AudioPlayer in v4+ but we use source
      // For v6 (which we likely have), we use AssetSource
    } catch (e) {
      debugPrint('[AudioService] Error preloading sounds: $e');
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    debugPrint('[AudioService] Muted: $_isMuted');
  }

  Future<void> playPop() async {
    if (_isMuted) return;
    try {
      await _player.play(AssetSource('audio/pop.mp3'), mode: PlayerMode.lowLatency);
    } catch (e) {
      // Fail silently - asset might be missing
      debugPrint('[AudioService] Failed to play pop: $e');
    }
  }

  Future<void> playGrow() async {
    if (_isMuted) return;
    try {
      await _player.play(AssetSource('audio/grow.mp3'));
    } catch (e) {
      debugPrint('[AudioService] Failed to play grow: $e');
    }
  }

  Future<void> playLevelUp() async {
    if (_isMuted) return;
    try {
      await _player.play(AssetSource('audio/level_up.mp3'));
    } catch (e) {
      debugPrint('[AudioService] Failed to play level_up: $e');
    }
  }
}
