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

  @override
  void dispose() {
    _recordTimer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
      _hasRecordedAudioPreview = false;
    });

    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _recordSeconds++;
      });
    });
  }

  void _stopAndPreviewRecording() {
    _recordTimer?.cancel();
    setState(() {
      _isRecording = false;
      _hasRecordedAudioPreview = true;
    });
  }

  void _cancelRecording() {
    _recordTimer?.cancel();
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
      _hasRecordedAudioPreview = false;
    });
  }

  void _sendRecordedMessage() {
    final user = Provider.of<UserService>(context, listen: false);
    final voiceService = Provider.of<VoiceGroupService>(context, listen: false);

    voiceService.sendVoiceMessage(
      groupId: widget.group.id,
      senderId: user.profile.id,
      senderName: user.profile.name,
      durationSeconds: _recordSeconds > 0 ? _recordSeconds : 8,
      waveform: [0.3, 0.7, 0.9, 0.4, 0.8, 0.6, 0.9, 0.5, 0.3],
    );

    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
      _hasRecordedAudioPreview = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice message sent to the group!')),
    );
  }

  void _showGroupDetails() {
    final user = Provider.of<UserService>(context, listen: false);
    final voiceService = Provider.of<VoiceGroupService>(context, listen: false);
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
              moderationService.reportItem(
                itemType: 'voice_group',
                itemId: widget.group.id,
                titleOrSender: widget.group.name,
                reason: 'Reported inappropriate voice group conduct',
                reportedByUserId: user.profile.id,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Group reported to moderation.')),
              );
            },
            child: const Text('Report Group', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () {
              voiceService.leaveGroup(widget.group.id, user.profile.id);
              Navigator.pop(ctx);
              Navigator.pop(context); // Go back to group list
            },
            child: const Text('Leave Group'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
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
            Text(widget.group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('${widget.group.members.length} members (Voice Only)', style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Group Information',
            icon: const Icon(Icons.info_outline, size: 28),
            onPressed: _showGroupDetails,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Consent & Privacy Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: Colors.amber.shade100,
              child: Row(
                children: const [
                  Icon(Icons.lock, size: 20, color: Colors.black87),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Privacy Notice: Voice recordings belong only to this group. Phone numbers are hidden.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
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
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isMyMessage ? 'You' : msg.senderName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isMyMessage ? Colors.blue.shade900 : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${msg.senderPhoneMasked})',
                                      style: const TextStyle(fontSize: 12, color: Colors.black45),
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
                                        padding: const EdgeInsets.all(8),
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
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recording... 0:${_recordSeconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (_hasRecordedAudioPreview) ...[
                    // Preview card before sending
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.audio_file, color: Colors.blue, size: 28),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Voice preview (${_recordSeconds > 0 ? _recordSeconds : 8} sec)',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton(
                            onPressed: _cancelRecording,
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                            icon: const Icon(Icons.send, size: 20),
                            label: const Text('Send'),
                            onPressed: _sendRecordedMessage,
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Hold or Tap to Record Big Button
                  if (!_hasRecordedAudioPreview)
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
