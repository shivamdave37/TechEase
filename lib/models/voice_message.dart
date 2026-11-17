class VoiceMessage {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String senderPhoneMasked;
  final int durationSeconds;
  final String audioUrl;
  final String speechText;
  final List<double> waveform;
  final DateTime timestamp;
  bool isListened;

  VoiceMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.senderPhoneMasked,
    required this.durationSeconds,
    required this.audioUrl,
    this.speechText = '',
    required this.waveform,
    required this.timestamp,
    this.isListened = false,
  });

  factory VoiceMessage.fromJson(Map<String, dynamic> json) {
    var rawWaveform = json['waveform'] as List<dynamic>? ?? [0.4, 0.7, 0.5, 0.9, 0.6, 0.3, 0.8];
    List<double> wave = rawWaveform.map((e) => (e as num).toDouble()).toList();
    return VoiceMessage(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      senderId: json['senderId'] as String? ?? 'user_1',
      senderName: json['senderName'] as String? ?? 'Friend',
      senderPhoneMasked: json['senderPhoneMasked'] as String? ?? '***-***-8888',
      durationSeconds: json['durationSeconds'] as int? ?? 12,
      audioUrl: json['audioUrl'] as String? ?? '',
      speechText: json['speechText'] as String? ?? '',
      waveform: wave,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isListened: json['isListened'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'groupId': groupId,
    'senderId': senderId,
    'senderName': senderName,
    'senderPhoneMasked': senderPhoneMasked,
    'durationSeconds': durationSeconds,
    'audioUrl': audioUrl,
    'speechText': speechText,
    'waveform': waveform,
    'timestamp': timestamp.toIso8601String(),
    'isListened': isListened,
  };
}
