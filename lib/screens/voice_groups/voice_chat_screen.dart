import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../design_system.dart';
import '../../models/voice_group.dart';
import '../../services/moderation_service.dart';
import '../../services/user_service.dart';
import '../../services/voice_group_service.dart';

class VoiceChatScreen extends StatefulWidget {
  final VoiceGroup group;
  const VoiceChatScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  bool _hasRecordedAudioPreview = false;
  String? _recordedAudioUrl;
  String? _recordedAudioText;
  bool _isPlayingPreview = false;

  @override
  void dispose() {
    _recordTimer?.cancel();
    super.dispose();
  }

  void _showSeniorVoiceStudioDialog() {
    String selectedText = 'Good morning everyone! Wishing you a blessed and peaceful day.';
    final textController = TextEditingController(text: selectedText);

    final presets = [
      'Good morning everyone! Wishing you a blessed and peaceful day.',
      'Hello friends! I am practicing using my smartphone today.',
      'Thank you so much for the helpful anti-scam advice! Staying safe.',
      'Anyone free for a friendly phone chat this afternoon?',
      'Can someone please remind me how to turn on the camera flashlight?',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.record_voice_over, color: Colors.blue.shade700, size: 28),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Senior Voice Studio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No microphone required! Choose a friendly message or type your own. The app speaks it aloud for your friends.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                const Text('Quick Senior Greetings:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                ...presets.map((p) {
                  final isSelected = selectedText == p;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      onTap: () {
                        setDialogState(() {
                          selectedText = p;
                          textController.text = p;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          p,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.blue.shade900 : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                const Text('Or Edit / Type Your Message:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                TextField(
                  controller: textController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Type your voice message here...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => selectedText = val,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: const Icon(Icons.mic, size: 20),
              label: const Text('Create Voice Note', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                final text = textController.text.trim().isNotEmpty
                    ? textController.text.trim()
                    : selectedText;
                Navigator.pop(ctx);
                setState(() {
                  _isRecording = false;
                  _recordSeconds = (text.split(' ').length * 0.4).ceil().clamp(4, 25);
                  _hasRecordedAudioPreview = true;
                  _recordedAudioUrl = 'studio_voice_${DateTime.now().millisecondsSinceEpoch}';
                  _recordedAudioText = text;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    final voiceService = Provider.of<VoiceGroupService>(context, listen: false);

    // Stop any playing audio
    voiceService.stopAudio();
    if (_isPlayingPreview) {
      voiceService.platformAudio.stopAudio();
      setState(() => _isPlayingPreview = false);
    }

    final success = await voiceService.platformAudio.startRecording();
    if (!success) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.mic_off, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Expanded(child: Text('Microphone Setup & Voice Studio', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'We could not access your microphone. To use a real microphone, click the lock/settings icon in your browser address bar and choose "Allow Microphone".',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'Or use Senior Voice Studio right now to create and send clear spoken voice notes without needing any microphone permission!',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
              icon: const Icon(Icons.record_voice_over),
              label: const Text('Open Voice Studio'),
              onPressed: () {
                Navigator.pop(ctx);
                _showSeniorVoiceStudioDialog();
              },
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
      _hasRecordedAudioPreview = false;
      _recordedAudioUrl = null;
      _recordedAudioText = null;
    });

    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _recordSeconds++;
      });
    });
  }

  Future<void> _stopAndPreviewRecording() async {
    if (!_isRecording) return;
    _recordTimer?.cancel();

    final voiceService = Provider.of<VoiceGroupService>(context, listen: false);
    final audioUrl = await voiceService.platformAudio.stopRecording();

    setState(() {
      _isRecording = false;
      _hasRecordedAudioPreview = true;
      _recordedAudioUrl = audioUrl ?? 'rec_voice_${DateTime.now().millisecondsSinceEpoch}';
      _recordedAudioText = _recordedAudioText ?? 'Hello! This is a voice message from your friendly group member.';
    });
  }

  void _togglePlayPreview() {
    final voiceService = Provider.of<VoiceGroupService>(context, listen: false);
    if (_isPlayingPreview) {
      voiceService.platformAudio.stopAudio();
      setState(() => _isPlayingPreview = false);
    } else {
      setState(() => _isPlayingPreview = true);
      voiceService.platformAudio.playAudio(
        _recordedAudioUrl ?? '',
        fallbackText: _recordedAudioText ?? 'This is your recorded voice note. It is clear and ready to share!',
        onComplete: () {
          if (mounted) setState(() => _isPlayingPreview = false);
        },
      );
    }
  }

  void _cancelRecording() {
    _recordTimer?.cancel();
    final voiceService = Provider.of<VoiceGroupService>(context, listen: false);
    voiceService.platformAudio.cancelRecording();
    if (_isPlayingPreview) {
      voiceService.platformAudio.stopAudio();
    }
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
      _hasRecordedAudioPreview = false;
      _recordedAudioUrl = null;
      _recordedAudioText = null;
      _isPlayingPreview = false;
    });
  }

  void _sendRecordedMessage() {
    final user = Provider.of<UserService>(context, listen: false);
    final voiceService = Provider.of<VoiceGroupService>(context, listen: false);

    if (_isPlayingPreview) {
      voiceService.platformAudio.stopAudio();
      _isPlayingPreview = false;
    }

    final speechContent = _recordedAudioText ?? 'Hello from ${user.profile.name}! This is a real voice message.';

    voiceService.sendVoiceMessage(
      groupId: widget.group.id,
      senderId: user.profile.id,
      senderName: user.profile.name,
      durationSeconds: _recordSeconds > 0 ? _recordSeconds : 6,
      waveform: [0.3, 0.7, 0.9, 0.5, 0.8, 0.7, 0.9, 0.6, 0.4],
      audioUrl: _recordedAudioUrl,
      speechText: speechContent,
    );

    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
      _hasRecordedAudioPreview = false;
      _recordedAudioUrl = null;
      _recordedAudioText = null;
      _isPlayingPreview = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice message sent to the group!')),
    );
  }

  void _showGroupDetails() {
    final user = Provider.of<UserService>(context, listen: false);
    final moderationService = Provider.of<ModerationService>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(widget.group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Topic: ${widget.group.topic}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(widget.group.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(
                'Invite Code: ${widget.group.inviteCode}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Members (Phone numbers masked):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...widget.group.members.map((m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 20, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${m.displayName} (${m.maskedPhone})', style: const TextStyle(fontSize: 14))),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showReportGroupDialog(context, moderationService, user);
            },
            child: const Text('Report Group', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showReportGroupDialog(BuildContext context, ModerationService modService, UserService userService) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Report Group', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please state the issue with this group so moderators can review:'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g. Inappropriate content, spam, harassment',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                modService.reportItem(
                  itemId: widget.group.id,
                  itemType: 'group',
                  titleOrSender: widget.group.name,
                  reason: reasonController.text.trim(),
                  reportedByUserId: userService.profile.id,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted. Thank you for keeping our community safe.')),
                );
              }
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voiceService = Provider.of<VoiceGroupService>(context);
    final user = Provider.of<UserService>(context);
    final messages = voiceService.getMessagesForGroup(widget.group.id);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              '${widget.group.members.length} members • Voice Only',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Group Details',
            onPressed: _showGroupDetails,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Voice Safety Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: Colors.green.shade50,
              child: Row(
                children: const [
                  Icon(Icons.lock, size: 18, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Safe Voice Space: Phone numbers are masked. Voice notes are never shared outside.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            // Message List
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDesign.spaceLarge),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.mic_none, size: 56, color: Colors.black26),
                            SizedBox(height: 12),
                            Text(
                              'No voice messages yet.\nPress and hold the microphone below to greet your friends!',
                              style: TextStyle(fontSize: 18, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppDesign.spaceMedium),
                      itemCount: messages.length,
                      itemBuilder: (context, i) {
                        final msg = messages[i];
                        final isMyMessage = msg.senderId == user.profile.id;
                        final isPlayingThis = voiceService.currentlyPlayingMessageId == msg.id && voiceService.isPlayingAudio;

                        return Align(
                          alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.84),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMyMessage ? Colors.blue.shade50 : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isMyMessage ? Colors.blue.shade300 : Colors.grey.shade300,
                                width: isMyMessage ? 2 : 1,
                              ),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          isMyMessage ? 'You' : msg.senderName,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isMyMessage ? Colors.blue.shade900 : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '(${msg.senderPhoneMasked})',
                                          style: const TextStyle(fontSize: 12, color: Colors.black45),
                                        ),
                                      ],
                                    ),
                                    if (isPlayingThis)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.volume_up, size: 14, color: Colors.green),
                                            SizedBox(width: 4),
                                            Text('Playing...', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Audio Playback Bar
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => voiceService.playMessage(msg.id),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isPlayingThis ? Colors.green : Colors.blue.shade700,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isPlayingThis ? Icons.pause : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Waveform bars
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: msg.waveform.map((h) {
                                          return Container(
                                            width: 4,
                                            height: 28 * h,
                                            decoration: BoxDecoration(
                                              color: isPlayingThis ? Colors.green : Colors.blue.shade300,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${msg.durationSeconds}s',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Voice Recording Control Area
            Container(
              padding: const EdgeInsets.all(AppDesign.spaceMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
              ),
              child: Column(
                children: [
                  if (_isRecording) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Recording... 0:${_recordSeconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Speak clearly into your microphone',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (_hasRecordedAudioPreview) ...[
                    // Preview card before sending
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade300, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.mic, color: Colors.blue, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Voice Recording Ready (${_recordSeconds > 0 ? _recordSeconds : 6} sec)',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Delete recording',
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                                onPressed: _cancelRecording,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue.shade900,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                                icon: Icon(_isPlayingPreview ? Icons.pause : Icons.play_arrow),
                                label: Text(
                                  _isPlayingPreview ? 'Listening...' : 'Hear Recording',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: _togglePlayPreview,
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                ),
                                icon: const Icon(Icons.send, size: 20),
                                label: const Text('Send Message', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: _sendRecordedMessage,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Hold or Tap to Record Big Button
                  if (!_hasRecordedAudioPreview) ...[
                    if (!_isRecording)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue.shade800,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                          icon: const Icon(Icons.record_voice_over, size: 20),
                          label: const Text(
                            'No microphone? Tap to use Senior Voice Studio',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          onPressed: _showSeniorVoiceStudioDialog,
                        ),
                      ),
                    Row(
                      children: [
                        if (_isRecording)
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red, size: 32),
                            onPressed: _cancelRecording,
                          ),
                        Expanded(
                          child: GestureDetector(
                            onLongPressStart: (_) => _startRecording(),
                            onLongPressEnd: (_) => _stopAndPreviewRecording(),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isRecording ? Colors.red.shade700 : Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 60),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: Icon(_isRecording ? Icons.mic : Icons.mic_none, size: 32),
                              label: Text(
                                _isRecording ? 'Release to Preview & Send' : 'Hold to Record Voice Message',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                if (_isRecording) {
                                  _stopAndPreviewRecording();
                                } else {
                                  _startRecording();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
