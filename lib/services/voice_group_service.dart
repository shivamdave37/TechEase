import 'package:material_ui/material_ui.dart';
import '../models/voice_group.dart';
import '../models/voice_message.dart';
import 'audio/platform_audio.dart';

class VoiceGroupService extends ChangeNotifier {
  final List<VoiceGroup> _groups = [];
  final Map<String, List<VoiceMessage>> _messagesByGroupId = {};
  String? _currentlyPlayingMessageId;
  bool _isPlayingAudio = false;
  final PlatformAudio _platformAudio = getPlatformAudio();

  List<VoiceGroup> get groups => List.unmodifiable(_groups);
  String? get currentlyPlayingMessageId => _currentlyPlayingMessageId;
  bool get isPlayingAudio => _isPlayingAudio;
  PlatformAudio get platformAudio => _platformAudio;

  VoiceGroupService() {
    _seedInitialGroups();
  }

  void _seedInitialGroups() {
    final group1 = VoiceGroup(
      id: 'grp_beginners',
      name: 'Senior Smartphone Beginners Club',
      topic: 'Asking questions, sharing daily phone tips & helping each other',
      description: 'A friendly voice-only space for elders to ask any smartphone questions without feeling rushed.',
      creatorId: 'user_mary',
      creatorName: 'Mary Higgins',
      iconCode: 'school',
      inviteCode: 'SENIOR-101',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      members: [
        GroupMember(
          userId: 'user_mary',
          displayName: 'Mary Higgins (Creator)',
          maskedPhone: '***-***-4321',
          role: 'creator',
          joinedAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
        GroupMember(
          userId: 'elder_user_1',
          displayName: 'You (Elder Learner)',
          maskedPhone: '***-***-7890',
          role: 'member',
          joinedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        GroupMember(
          userId: 'user_david',
          displayName: 'David Miller',
          maskedPhone: '***-***-1122',
          role: 'member',
          joinedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ],
    );

    final group2 = VoiceGroup(
      id: 'grp_family',
      name: 'Family Voice Circle',
      topic: 'Daily audio greetings, recipes & family voice notes',
      description: 'Stay close with loved ones by leaving warm voice messages they can listen to at any time.',
      creatorId: 'elder_user_1',
      creatorName: 'You (Elder Learner)',
      iconCode: 'favorite',
      inviteCode: 'FAMILY-202',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      members: [
        GroupMember(
          userId: 'elder_user_1',
          displayName: 'You (Elder Learner)',
          maskedPhone: '***-***-7890',
          role: 'creator',
          joinedAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        GroupMember(
          userId: 'user_grandkid',
          displayName: 'Sarah (Granddaughter)',
          maskedPhone: '***-***-9988',
          role: 'member',
          joinedAt: DateTime.now().subtract(const Duration(days: 19)),
        ),
      ],
    );

    _groups.addAll([group1, group2]);

    _messagesByGroupId['grp_beginners'] = [
      VoiceMessage(
        id: 'msg_1',
        groupId: 'grp_beginners',
        senderId: 'user_mary',
        senderName: 'Mary Higgins',
        senderPhoneMasked: '***-***-4321',
        durationSeconds: 15,
        audioUrl: 'sample_audio_1',
        speechText: 'Hello everyone! Welcome to our smartphone learning group. Today we practiced sending photos on WhatsApp. Please let us know if you need any help!',
        waveform: [0.3, 0.6, 0.8, 0.4, 0.9, 0.7, 0.5, 0.3],
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      VoiceMessage(
        id: 'msg_2',
        groupId: 'grp_beginners',
        senderId: 'user_david',
        senderName: 'David Miller',
        senderPhoneMasked: '***-***-1122',
        durationSeconds: 22,
        audioUrl: 'sample_audio_2',
        speechText: 'Good morning Mary! That photo tutorial was really helpful. I just sent a photo of my garden to my daughter this morning.',
        waveform: [0.2, 0.5, 0.9, 0.8, 0.6, 0.9, 0.4, 0.2],
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ];

    _messagesByGroupId['grp_family'] = [
      VoiceMessage(
        id: 'msg_3',
        groupId: 'grp_family',
        senderId: 'user_grandkid',
        senderName: 'Sarah (Granddaughter)',
        senderPhoneMasked: '***-***-9988',
        durationSeconds: 18,
        audioUrl: 'sample_audio_3',
        speechText: 'Hi Grandpa! I hope you are having a wonderful day. Give me a call whenever you have free time, love you!',
        waveform: [0.4, 0.8, 0.7, 0.9, 0.5, 0.8, 0.6, 0.4],
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }

  List<VoiceMessage> getMessagesForGroup(String groupId) {
    return List.unmodifiable(_messagesByGroupId[groupId] ?? []);
  }

  void createGroup({
    required String name,
    required String topic,
    required String description,
    required String creatorName,
    required String creatorId,
  }) {
    final groupId = 'grp_${DateTime.now().millisecondsSinceEpoch}';
    final inviteCode = 'GRP-${100 + _groups.length}';

    final newGroup = VoiceGroup(
      id: groupId,
      name: name.trim(),
      topic: topic.trim(),
      description: description.trim(),
      creatorId: creatorId,
      creatorName: creatorName,
      iconCode: 'record_voice_over',
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
      members: [
        GroupMember(
          userId: creatorId,
          displayName: '$creatorName (Creator)',
          maskedPhone: '***-***-7890',
          role: 'creator',
          joinedAt: DateTime.now(),
        ),
      ],
    );

    _groups.insert(0, newGroup);
    _messagesByGroupId[groupId] = [];
    notifyListeners();
  }

  bool joinGroupByCode(String code, String userId, String userName) {
    final cleanCode = code.trim().toUpperCase();
    final group = _groups.firstWhere(
      (g) => g.inviteCode.toUpperCase() == cleanCode,
      orElse: () => VoiceGroup(
        id: '',
        name: '',
        topic: '',
        description: '',
        creatorId: '',
        creatorName: '',
        iconCode: '',
        inviteCode: '',
        members: [],
        createdAt: DateTime.now(),
      ),
    );

    if (group.id.isEmpty) return false;

    // Check if already a member
    final alreadyMember = group.members.any((m) => m.userId == userId);
    if (!alreadyMember) {
      group.members.add(GroupMember(
        userId: userId,
        displayName: userName,
        maskedPhone: '***-***-7890',
        role: 'member',
        joinedAt: DateTime.now(),
      ));
      notifyListeners();
    }
    return true;
  }

  void sendVoiceMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required int durationSeconds,
    required List<double> waveform,
    String? audioUrl,
    String? speechText,
  }) {
    final msg = VoiceMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      groupId: groupId,
      senderId: senderId,
      senderName: senderName,
      senderPhoneMasked: '***-***-7890',
      durationSeconds: durationSeconds,
      audioUrl: audioUrl ?? 'local_record_${DateTime.now().millisecondsSinceEpoch}',
      speechText: speechText ?? 'Voice message sent by $senderName',
      waveform: waveform,
      timestamp: DateTime.now(),
    );

    _messagesByGroupId.putIfAbsent(groupId, () => []).add(msg);
    notifyListeners();
  }

  void playMessage(String messageId) {
    if (_currentlyPlayingMessageId == messageId && _isPlayingAudio) {
      _platformAudio.stopAudio();
      _isPlayingAudio = false;
      _currentlyPlayingMessageId = null;
      notifyListeners();
      return;
    }

    VoiceMessage? targetMsg;
    for (final list in _messagesByGroupId.values) {
      for (final m in list) {
        if (m.id == messageId) {
          targetMsg = m;
          break;
        }
      }
      if (targetMsg != null) break;
    }

    if (targetMsg == null) return;

    _currentlyPlayingMessageId = messageId;
    _isPlayingAudio = true;
    notifyListeners();

    _platformAudio.playAudio(
      targetMsg.audioUrl,
      fallbackText: targetMsg.speechText.isNotEmpty
          ? targetMsg.speechText
          : 'Voice message from ${targetMsg.senderName}',
      onComplete: () {
        _isPlayingAudio = false;
        _currentlyPlayingMessageId = null;
        notifyListeners();
      },
    );
  }

  void stopAudio() {
    _platformAudio.stopAudio();
    _isPlayingAudio = false;
    _currentlyPlayingMessageId = null;
    notifyListeners();
  }

  void leaveGroup(String groupId, String userId) {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex != -1) {
      _groups[groupIndex].members.removeWhere((m) => m.userId == userId);
      if (_groups[groupIndex].members.isEmpty) {
        _groups.removeAt(groupIndex);
        _messagesByGroupId.remove(groupId);
      }
      notifyListeners();
    }
  }
}
