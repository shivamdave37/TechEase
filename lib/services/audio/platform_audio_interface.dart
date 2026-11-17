import 'dart:async';
import 'package:material_ui/material_ui.dart';

abstract class PlatformAudio {
  Future<bool> requestMicPermission();
  Future<bool> startRecording();
  Future<String?> stopRecording();
  Future<void> cancelRecording();
  Future<void> playAudio(String audioUrl, {String? fallbackText, VoidCallback? onComplete});
  void stopAudio();
  bool get isRecording;
  bool get isPlaying;
  List<double> getLiveWaveform();
}
