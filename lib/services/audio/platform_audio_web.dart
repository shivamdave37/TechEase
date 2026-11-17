import 'dart:async';
import 'dart:js_interop';
import 'package:material_ui/material_ui.dart';
import 'package:web/web.dart' as web;
import 'platform_audio_interface.dart';

class PlatformAudioImpl implements PlatformAudio {
  web.MediaStream? _mediaStream;
  web.MediaRecorder? _recorder;
  final List<web.Blob> _recordedChunks = [];
  bool _isRecording = false;
  bool _isPlaying = false;
  web.HTMLAudioElement? _currentAudio;
  Completer<String?>? _stopCompleter;

  @override
  bool get isRecording => _isRecording;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<bool> requestMicPermission() async {
    try {
      final stream = await web.window.navigator.mediaDevices.getUserMedia(
        web.MediaStreamConstraints(audio: true.toJS),
      ).toDart;
      // Close immediate test tracks to not keep mic indicator stuck on
      final tracks = stream.getAudioTracks().toDart;
      for (final t in tracks) {
        t.stop();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> startRecording() async {
    try {
      _recordedChunks.clear();
      _mediaStream = await web.window.navigator.mediaDevices.getUserMedia(
        web.MediaStreamConstraints(audio: true.toJS),
      ).toDart;

      _recorder = web.MediaRecorder(_mediaStream!);
      _recorder!.ondataavailable = (web.BlobEvent event) {
        if (event.data.size > 0) {
          _recordedChunks.add(event.data);
        }
      }.toJS;

      _recorder!.onstop = (web.Event e) {
        if (_recordedChunks.isNotEmpty) {
          final blob = web.Blob(_recordedChunks.toJS, web.BlobPropertyBag(type: 'audio/webm'));
          final url = web.URL.createObjectURL(blob);
          _stopCompleter?.complete(url);
        } else {
          _stopCompleter?.complete(null);
        }
      }.toJS;

      _recorder!.start();
      _isRecording = true;
      return true;
    } catch (e) {
      _isRecording = false;
      return false;
    }
  }

  @override
  Future<String?> stopRecording() async {
    if (!_isRecording || _recorder == null) return null;
    _stopCompleter = Completer<String?>();
    _isRecording = false;

    try {
      _recorder!.stop();
      // Stop media tracks
      if (_mediaStream != null) {
        final tracks = _mediaStream!.getAudioTracks().toDart;
        for (final t in tracks) {
          t.stop();
        }
        _mediaStream = null;
      }
      return await _stopCompleter!.future;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cancelRecording() async {
    _isRecording = false;
    _recordedChunks.clear();
    try {
      if (_recorder != null && _recorder!.state != 'inactive') {
        _recorder!.stop();
      }
      if (_mediaStream != null) {
        final tracks = _mediaStream!.getAudioTracks().toDart;
        for (final t in tracks) {
          t.stop();
        }
        _mediaStream = null;
      }
    } catch (_) {}
  }

  @override
  Future<void> playAudio(String audioUrl, {String? fallbackText, VoidCallback? onComplete}) async {
    stopAudio();
    _isPlaying = true;

    // 1. If audioUrl is a real recorded blob or audio source, play via HTML5 Audio
    if (audioUrl.startsWith('blob:') || audioUrl.startsWith('data:audio') || audioUrl.startsWith('http')) {
      try {
        final audio = web.HTMLAudioElement();
        audio.src = audioUrl;
        audio.volume = 1.0;
        _currentAudio = audio;

        audio.onended = (web.Event e) {
          _isPlaying = false;
          _currentAudio = null;
          onComplete?.call();
        }.toJS;

        audio.onerror = (web.Event e) {
          _isPlaying = false;
          _currentAudio = null;
          // Fallback to speech synthesis if audio format playback failed
          if (fallbackText != null && fallbackText.isNotEmpty) {
            _speakText(fallbackText, onComplete);
          } else {
            onComplete?.call();
          }
        }.toJS;

        await audio.play().toDart;
        return;
      } catch (e) {
        _isPlaying = false;
      }
    }

    // 2. Play clear spoken voice via Web Speech Synthesis (for seed/sample messages and elderly accessibility)
    final textToSpeak = fallbackText ?? 'Hello! This is a voice message from your group.';
    _speakText(textToSpeak, onComplete);
  }

  void _speakText(String text, VoidCallback? onComplete) {
    try {
      web.window.speechSynthesis.cancel();
      final utt = web.SpeechSynthesisUtterance(text);
      // Gentle, clear pace for elderly listeners
      utt.rate = 0.9;
      utt.pitch = 1.0;
      utt.volume = 1.0;

      utt.onend = (web.Event e) {
        _isPlaying = false;
        onComplete?.call();
      }.toJS;

      utt.onerror = (web.Event e) {
        _isPlaying = false;
        onComplete?.call();
      }.toJS;

      _isPlaying = true;
      web.window.speechSynthesis.speak(utt);
    } catch (_) {
      _isPlaying = false;
      onComplete?.call();
    }
  }

  @override
  void stopAudio() {
    _isPlaying = false;
    if (_currentAudio != null) {
      try {
        _currentAudio!.pause();
        _currentAudio!.currentTime = 0;
      } catch (_) {}
      _currentAudio = null;
    }
    try {
      web.window.speechSynthesis.cancel();
    } catch (_) {}
  }

  @override
  List<double> getLiveWaveform() {
    return [0.3, 0.7, 0.9, 0.6, 0.8, 0.9, 0.5, 0.4];
  }
}

PlatformAudio createPlatformAudio() => PlatformAudioImpl();
