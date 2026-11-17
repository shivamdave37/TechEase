import 'package:material_ui/material_ui.dart';

class AnalyticsEvent {
  final String eventName;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.eventName,
    required this.parameters,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'eventName': eventName,
    'parameters': parameters,
    'timestamp': timestamp.toIso8601String(),
  };
}

class AnalyticsService extends ChangeNotifier {
  final List<AnalyticsEvent> _events = [];

  int _lessonsStarted = 0;
  int _lessonsCompleted = 0;
  int _practiceCompleted = 0;
  int _videosWatched = 0;
  int _voiceMessagesSent = 0;
  int _searchQueriesPerformed = 0;

  int get lessonsStarted => _lessonsStarted;
  int get lessonsCompleted => _lessonsCompleted;
  int get practiceCompleted => _practiceCompleted;
  int get videosWatched => _videosWatched;
  int get voiceMessagesSent => _voiceMessagesSent;
  int get searchQueriesPerformed => _searchQueriesPerformed;
  List<AnalyticsEvent> get recentEvents => List.unmodifiable(_events.reversed.take(15));

  void logEvent(String name, [Map<String, dynamic>? params]) {
    final event = AnalyticsEvent(
      eventName: name,
      parameters: params ?? {},
      timestamp: DateTime.now(),
    );
    _events.add(event);

    switch (name) {
      case 'lesson_started':
        _lessonsStarted++;
        break;
      case 'lesson_completed':
        _lessonsCompleted++;
        break;
      case 'practice_completed':
        _practiceCompleted++;
        break;
      case 'video_watched':
        _videosWatched++;
        break;
      case 'voice_message_sent':
        _voiceMessagesSent++;
        break;
      case 'search_performed':
        _searchQueriesPerformed++;
        break;
    }
    notifyListeners();
  }
}
