import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'platform_audio_interface.dart';

class PlatformAudioImpl implements PlatformAudio {
  bool _isRecording = false;
  bool _isPlaying = false;
  Timer? _playTimer;

  @override
  bool get isRecording => _isRecording;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<bool> requestMicPermission() async => true;

  @override
  Future<bool> startRecording() async {
    _isRecording = true;
    return true;
  }

  @override
  Future<String?> stopRecording() async {
    _isRecording = false;
    return 'data:audio/mock_record_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> cancelRecording() async {
    _isRecording = false;
  }

  @override
  Future<void> playAudio(String audioUrl, {String? fallbackText, VoidCallback? onComplete}) async {
    stopAudio();
    _isPlaying = true;
    _playTimer = Timer(const Duration(milliseconds: 300), () {
      _isPlaying = false;
      onComplete?.call();
    });
  }

  @override
  void stopAudio() {
    _playTimer?.cancel();
    _playTimer = null;
    _isPlaying = false;
  }

  @override
  List<double> getLiveWaveform() => [0.3, 0.6, 0.8, 0.5, 0.9, 0.7, 0.4];
}

PlatformAudio createPlatformAudio() => PlatformAudioImpl();
