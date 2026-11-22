import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../design_system.dart';
import '../../models/community_video.dart';
import '../../services/audio/platform_audio.dart';
import '../../services/community_video_service.dart';
import '../../services/localization_service.dart';
import '../../services/moderation_service.dart';
import '../../services/user_service.dart';
import 'video_upload_screen.dart';

class VideosScreen extends StatelessWidget {
  const VideosScreen({Key? key}) : super(key: key);

  void _showVideoPlayer(BuildContext context, CommunityVideo video) {
    showDialog(
      context: context,
      builder: (ctx) => _VideoPlayerModal(video: video),
    );
  }

  void _showReportDialog(BuildContext context, CommunityVideo video) {
    String selectedReason = '🚨 Fake or misleading guide (Bad advice for seniors)';
    final reasons = [
      '🚨 Fake or misleading guide (Bad advice for seniors)',
      '🚨 Suspected scam, lottery, or phishing link',
      'Shows private or financial information',
      'Inappropriate content or bad language',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.report_problem, color: Colors.red, size: 30),
              SizedBox(width: 8),
              Text('Report This Video'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Why should this video be reviewed?', style: AppDesign.body.copyWith(fontSize: 16)),
              const SizedBox(height: 12),
              ...reasons.map((r) {
                final isSelected = selectedReason == r;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    r,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.red : Colors.black38,
                    size: 24,
                  ),
                  onTap: () => setState(() => selectedReason = r),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
              onPressed: () {
                final videoService = Provider.of<CommunityVideoService>(context, listen: false);
                final moderationService = Provider.of<ModerationService>(context, listen: false);
                final user = Provider.of<UserService>(context, listen: false);

                videoService.reportVideo(video.id, selectedReason);
                moderationService.reportItem(
                  itemType: 'video',
                  itemId: video.id,
                  titleOrSender: video.title,
                  reason: selectedReason,
                  reportedByUserId: user.profile.id,
                );

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you. This video has been reported to our moderation board for review.')),
                );
              },
              child: const Text('Submit Report', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoService = Provider.of<CommunityVideoService>(context);
    final loc = Provider.of<LocalizationService>(context);

    final videos = videoService.approvedVideos;
    final categories = ['All', 'WhatsApp', 'QR Codes', 'Smartphone Basics', 'Google Maps', 'Photos & Gallery'];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tr('video_library'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDesign.spaceMedium, vertical: 10),
              color: Colors.white,
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final catName = categories[i];
                    final isSelected = videoService.selectedCategory == catName;
                    return ChoiceChip(
                      label: Text(
                        catName == 'All' ? loc.tr('filter_all') : catName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.blue.shade700,
                      backgroundColor: Colors.grey.shade100,
                      onSelected: (_) => videoService.setCategoryFilter(catName),
                    );
                  },
                ),
              ),
            ),
            const Divider(height: 1),

            // Senior Anti-Fake Guide Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppDesign.spaceMedium, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade600, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user, color: Colors.green.shade800, size: 28),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Senior Safe Guide Hub — Anti-Fake Shield',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Fake videos with misleading advice or scams are strictly blocked. Anyone can upload a verified, safe guide video below to help other seniors!',
                    style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 22),
                      label: const Text(
                        'Upload a Helpful Guide Video',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VideoUploadScreen()),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Video List
            Expanded(
              child: videos.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDesign.spaceLarge),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.video_library_outlined, size: 64, color: Colors.black38),
                            SizedBox(height: 12),
                            Text(
                              'No videos found in this topic.',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppDesign.spaceMedium),
                      itemCount: videos.length,
                      itemBuilder: (context, i) {
                        final video = videos[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppDesign.spaceMedium),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _showVideoPlayer(context, video),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Video Thumbnail Simulation
                                  Container(
                                    height: 160,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade900,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Center(
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.play_arrow, size: 36, color: Colors.blue),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black87,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${video.durationSeconds ~/ 60}:${(video.durationSeconds % 60).toString().padLeft(2, '0')}',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade700,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              video.category,
                                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Verified Guide Badge
                                  if (video.isVerifiedGuide)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.green.shade600, width: 1.5),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.shield, size: 16, color: Colors.green.shade800),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              '🛡️ Verified Safe Guide • ${video.guideType}',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green.shade900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Video Title and Description
                                  Text(
                                    video.title,
                                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    video.description,
                                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 10),

                                  // Uploader and Action Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'By ${video.uploaderName}',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton.icon(
                                            icon: Icon(
                                              video.isMarkedHelpful ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                              color: video.isMarkedHelpful ? Colors.blue.shade700 : Colors.black54,
                                              size: 20,
                                            ),
                                            label: Text(
                                              '${video.helpfulCount}',
                                              style: TextStyle(
                                                color: video.isMarkedHelpful ? Colors.blue.shade700 : Colors.black87,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            onPressed: () => videoService.toggleHelpful(video.id),
                                          ),
                                          IconButton(
                                            tooltip: 'Report',
                                            icon: const Icon(Icons.flag_outlined, size: 20, color: Colors.black45),
                                            onPressed: () => _showReportDialog(context, video),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.video_call, size: 28),
        label: Text(loc.tr('upload_video'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VideoUploadScreen()),
          );
        },
      ),
    );
  }
}

class _GuideStep {
  final int stepNumber;
  final int startSecond;
  final int endSecond;
  final String title;
  final String narration;
  final String caption;
  final String tip;
  final IconData icon;

  const _GuideStep({
    required this.stepNumber,
    required this.startSecond,
    required this.endSecond,
    required this.title,
    required this.narration,
    required this.caption,
    required this.tip,
    required this.icon,
  });
}

class _VideoPlayerModal extends StatefulWidget {
  final CommunityVideo video;
  const _VideoPlayerModal({Key? key, required this.video}) : super(key: key);

  @override
  State<_VideoPlayerModal> createState() => _VideoPlayerModalState();
}

class _VideoPlayerModalState extends State<_VideoPlayerModal>
    with SingleTickerProviderStateMixin {
  late int _totalSeconds;
  int _currentSeconds = 0;
  bool _isPlaying = true;
  bool _isMuted = false;
  double _playbackSpeed = 1.0; // 0.75 or 1.0
  Timer? _playbackTimer;
  int _subSecondCounter = 0;
  int _lastSpokenStepNumber = -1;
  late final PlatformAudio _platformAudio;
  late final AnimationController _animController;
  late final List<_GuideStep> _steps;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.video.durationSeconds > 0 ? widget.video.durationSeconds : 60;
    _steps = _buildStepsForVideo(widget.video, _totalSeconds);
    _platformAudio = getPlatformAudio();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _startPlaybackTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndSpeakStepNarration();
    });
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _animController.dispose();
    _platformAudio.stopAudio();
    super.dispose();
  }

  List<_GuideStep> _buildStepsForVideo(CommunityVideo video, int total) {
    final title = video.title.toLowerCase();
    final cat = video.category.toLowerCase();

    if (title.contains('whatsapp') || cat.contains('whatsapp')) {
      final s1 = (total * 0.24).round();
      final s2 = (total * 0.48).round();
      final s3 = (total * 0.76).round();
      return [
        _GuideStep(
          stepNumber: 1,
          startSecond: 0,
          endSecond: s1,
          title: 'Step 1: Open Your Family Chat',
          caption: 'Open WhatsApp and tap the name of your child or grandchild from your chat list.',
          narration: 'Step one. Open WhatsApp and tap on your family member from the chat list.',
          tip: '💡 Look for their smiling photo on the left side of the chat.',
          icon: Icons.chat_bubble_outline,
        ),
        _GuideStep(
          stepNumber: 2,
          startSecond: s1,
          endSecond: s2,
          title: 'Step 2: Tap the Video Camera Icon',
          caption: 'Look at the top-right corner of the chat and tap the Video Camera button.',
          narration: 'Step two. In the top right corner, tap the green video camera button.',
          tip: '💡 The camera icon starts a live face-to-face video call.',
          icon: Icons.videocam,
        ),
        _GuideStep(
          stepNumber: 3,
          startSecond: s2,
          endSecond: s3,
          title: 'Step 3: Ringing & Connecting',
          caption: 'Wait a few seconds while your phone rings and connects you to your family.',
          narration: 'Step three. Your phone will ring while your family member answers.',
          tip: '💡 Hold your phone upright facing your face.',
          icon: Icons.ring_volume,
        ),
        _GuideStep(
          stepNumber: 4,
          startSecond: s3,
          endSecond: total,
          title: 'Step 4: You Are Connected Face-to-Face!',
          caption: 'Smile! You can now see and hear your family. Tap the red button when done.',
          narration: 'Step four. Congratulations! You are connected. Tap the red button when you are ready to hang up.',
          tip: '💡 Tap the red phone button when you are finished talking.',
          icon: Icons.sentiment_very_satisfied,
        ),
      ];
    }

    if (title.contains('qr') || cat.contains('qr')) {
      final s1 = (total * 0.23).round();
      final s2 = (total * 0.54).round();
      final s3 = (total * 0.77).round();
      return [
        _GuideStep(
          stepNumber: 1,
          startSecond: 0,
          endSecond: s1,
          title: 'Step 1: Open Your Camera App',
          caption: 'Tap the Camera icon on your phone home screen. Do not take a photo yet.',
          narration: 'Step one. Open your smartphone camera app. You do not need to press the photo button.',
          tip: '💡 Hold your phone steady with both hands.',
          icon: Icons.camera_alt,
        ),
        _GuideStep(
          stepNumber: 2,
          startSecond: s1,
          endSecond: s2,
          title: 'Step 2: Point Steady at the QR Code',
          caption: 'Hold your camera 6 inches above the QR code on the table until it focuses.',
          narration: 'Step two. Hold your phone steady right above the square QR code.',
          tip: '💡 The camera scanner reads the code automatically.',
          icon: Icons.qr_code_scanner,
        ),
        _GuideStep(
          stepNumber: 3,
          startSecond: s2,
          endSecond: s3,
          title: 'Step 3: Tap the Yellow Web Link',
          caption: 'A yellow link pops up on your screen. Tap it once with your finger.',
          narration: 'Step three. Tap the yellow website link that pops up on your screen.',
          tip: '💡 Tapping the yellow link opens the restaurant menu safely.',
          icon: Icons.touch_app,
        ),
        _GuideStep(
          stepNumber: 4,
          startSecond: s3,
          endSecond: total,
          title: 'Step 4: Browse the Food Menu',
          caption: 'The restaurant menu is now on your screen with large prices and photos!',
          narration: 'Step four. The food menu is open. You can scroll up and down to see all the meals.',
          tip: '💡 Pinch with two fingers to make text even larger.',
          icon: Icons.restaurant_menu,
        ),
      ];
    }

    if (title.contains('text') || title.contains('bigger') || title.contains('clearer')) {
      final s1 = (total * 0.24).round();
      final s2 = (total * 0.50).round();
      final s3 = (total * 0.76).round();
      return [
        _GuideStep(
          stepNumber: 1,
          startSecond: 0,
          endSecond: s1,
          title: 'Step 1: Open Phone Settings',
          caption: 'Tap the gear icon on your home screen to open Settings.',
          narration: 'Step one. Open your smartphone Settings by tapping the gear icon.',
          tip: '💡 Settings lets you customize screen text size comfortably.',
          icon: Icons.settings,
        ),
        _GuideStep(
          stepNumber: 2,
          startSecond: s1,
          endSecond: s2,
          title: 'Step 2: Tap Display & Brightness',
          caption: 'Scroll down slightly and tap on "Display & Brightness".',
          narration: 'Step two. Scroll down and tap on Display and Brightness.',
          tip: '💡 Look for the sun or screen brightness icon.',
          icon: Icons.brightness_medium,
        ),
        _GuideStep(
          stepNumber: 3,
          startSecond: s2,
          endSecond: s3,
          title: 'Step 3: Drag Font Size Slider to the Right',
          caption: 'Tap "Font Size" and drag the circle slider to the right to enlarge letters.',
          narration: 'Step three. Tap font size and slide the circle to the right to make all letters larger.',
          tip: '💡 Watch the sample letters grow bigger immediately!',
          icon: Icons.format_size,
        ),
        _GuideStep(
          stepNumber: 4,
          startSecond: s3,
          endSecond: total,
          title: 'Step 4: Enjoy Reading Comfortably',
          caption: 'All your messages, news, and phone menus are now large, clear, and easy on the eyes!',
          narration: 'Step four. Great job! Your phone is now comfortable to read without straining your eyes.',
          tip: '💡 You can adjust this size anytime you need.',
          icon: Icons.check_circle_outline,
        ),
      ];
    }

    if (title.contains('maps') || title.contains('clinic') || cat.contains('maps')) {
      final s1 = (total * 0.23).round();
      final s2 = (total * 0.51).round();
      final s3 = (total * 0.76).round();
      return [
        _GuideStep(
          stepNumber: 1,
          startSecond: 0,
          endSecond: s1,
          title: 'Step 1: Search for Clinic or Pharmacy',
          caption: 'Open Google Maps and type "Pharmacy" or "Clinic" into the top search bar.',
          narration: 'Step one. Open Google Maps and type pharmacy or clinic in the search bar.',
          tip: '💡 You can also tap the microphone icon to speak the name.',
          icon: Icons.search,
        ),
        _GuideStep(
          stepNumber: 2,
          startSecond: s1,
          endSecond: s2,
          title: 'Step 2: Tap the Blue Directions Button',
          caption: 'Select the nearest clinic from the list and tap the blue "Directions" button.',
          narration: 'Step two. Choose the closest clinic from the list and tap the blue Directions button.',
          tip: '💡 It shows walking distance, bus stops, or car routes.',
          icon: Icons.directions,
        ),
        _GuideStep(
          stepNumber: 3,
          startSecond: s2,
          endSecond: s3,
          title: 'Step 3: Tap Green Start Button',
          caption: 'Tap the green "Start" button for step-by-step spoken navigation.',
          narration: 'Step three. Tap the green Start button. Maps will speak instructions like "turn right in 50 meters".',
          tip: '💡 Turn up phone volume to hear the clear voice directions.',
          icon: Icons.navigation,
        ),
        _GuideStep(
          stepNumber: 4,
          startSecond: s3,
          endSecond: total,
          title: 'Step 4: You Have Arrived Safely',
          caption: 'Follow the blue route line until you reach the clinic entrance safely.',
          narration: 'Step four. You have arrived at the clinic. Tap the red X button to finish navigation.',
          tip: '💡 You can always call your family helper if you need assistance.',
          icon: Icons.local_hospital,
        ),
      ];
    }

    if (title.contains('scam') || title.contains('fake') || title.contains('safety')) {
      final s1 = (total * 0.23).round();
      final s2 = (total * 0.50).round();
      final s3 = (total * 0.73).round();
      return [
        _GuideStep(
          stepNumber: 1,
          startSecond: 0,
          endSecond: s1,
          title: 'Step 1: Spot Scam Warning Signs',
          caption: 'Scammers create false panic: claiming your bank account or electricity is suspended.',
          narration: 'Step one. Scammers try to frighten you by claiming your bank or card is blocked. Stay calm.',
          tip: '💡 Real banks never threaten or rush you.',
          icon: Icons.warning_amber,
        ),
        _GuideStep(
          stepNumber: 2,
          startSecond: s1,
          endSecond: s2,
          title: 'Step 2: NEVER Share Your OTP or Password',
          caption: '🛑 GOLDEN RULE: Never read aloud any SMS code, OTP, or PIN to anyone on the phone!',
          narration: 'Step two. This is the golden rule. Never read aloud any OTP code or password to anyone on a call.',
          tip: '💡 Legitimate bank staff will NEVER ask for your secret verification code.',
          icon: Icons.security,
        ),
        _GuideStep(
          stepNumber: 3,
          startSecond: s2,
          endSecond: s3,
          title: 'Step 3: Hang Up & Block the Number',
          caption: 'Tap the red Hang Up button immediately. It is always safe and polite to hang up.',
          narration: 'Step three. Tap the red button to hang up right away. Then tap block number so they cannot call again.',
          tip: '💡 You never have to explain or apologize for hanging up on a suspicious caller.',
          icon: Icons.call_end,
        ),
        _GuideStep(
          stepNumber: 4,
          startSecond: s3,
          endSecond: total,
          title: 'Step 4: Call Your Trusted Family Helper',
          caption: 'Call your son, daughter, or trusted friend directly to verify any suspicious call.',
          narration: 'Step four. Call your trusted family helper to double check. You are safe and protected.',
          tip: '💡 Always verify with someone you know and trust.',
          icon: Icons.verified_user,
        ),
      ];
    }

    // Generic fallback chapters
    final quarter = (total / 4).round();
    return [
      _GuideStep(
        stepNumber: 1,
        startSecond: 0,
        endSecond: quarter,
        title: 'Step 1: Getting Started',
        caption: 'Review the setup and open the required application on your smartphone.',
        narration: 'Step one. Review the setup and prepare your phone.',
        tip: '💡 Hold phone comfortably with screen facing you.',
        icon: Icons.play_circle_outline,
      ),
      _GuideStep(
        stepNumber: 2,
        startSecond: quarter,
        endSecond: quarter * 2,
        title: 'Step 2: Following the Guide Action',
        caption: 'Look closely at the highlighted button and tap gently once.',
        narration: 'Step two. Follow the highlighted action on your screen.',
        tip: '💡 A single gentle tap is all you need.',
        icon: Icons.touch_app,
      ),
      _GuideStep(
        stepNumber: 3,
        startSecond: quarter * 2,
        endSecond: quarter * 3,
        title: 'Step 3: Confirming the Screen Result',
        caption: 'Confirm that your screen matches the example shown in this video.',
        narration: 'Step three. Check your screen to confirm the step worked.',
        tip: '💡 If you made a mistake, you can always tap the Back button.',
        icon: Icons.check_circle_outline,
      ),
      _GuideStep(
        stepNumber: 4,
        startSecond: quarter * 3,
        endSecond: total,
        title: 'Step 4: Practice & Completion',
        caption: 'Great work! You have mastered this lesson. Practice again anytime.',
        narration: 'Step four. Congratulations! You completed this lesson.',
        tip: '💡 Practice makes technology simple and familiar.',
        icon: Icons.verified,
      ),
    ];
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    final intervalMs = (_playbackSpeed == 0.75) ? 133 : 100;
    _playbackTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!_isPlaying) return;

      _subSecondCounter += 100;
      if (_subSecondCounter >= 1000) {
        _subSecondCounter = 0;
        if (_currentSeconds < _totalSeconds) {
          setState(() {
            _currentSeconds++;
          });
          _checkAndSpeakStepNarration();
        } else {
          setState(() {
            _isPlaying = false;
          });
          timer.cancel();
        }
      }
    });
  }

  _GuideStep _getCurrentStep() {
    for (final s in _steps) {
      if (_currentSeconds >= s.startSecond && _currentSeconds < s.endSecond) {
        return s;
      }
    }
    return _steps.last;
  }

  void _checkAndSpeakStepNarration() {
    final currentStep = _getCurrentStep();
    if (currentStep.stepNumber != _lastSpokenStepNumber) {
      _lastSpokenStepNumber = currentStep.stepNumber;
      if (!_isMuted && _isPlaying) {
        _platformAudio.playAudio(
          '',
          fallbackText: '${currentStep.title}. ${currentStep.narration}',
        );
      }
    }
  }

  void _togglePlayPause() {
    if (_currentSeconds >= _totalSeconds) {
      setState(() {
        _currentSeconds = 0;
        _isPlaying = true;
        _lastSpokenStepNumber = -1;
      });
      _animController.repeat(reverse: true);
      _startPlaybackTimer();
      _checkAndSpeakStepNarration();
      return;
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _animController.repeat(reverse: true);
      _startPlaybackTimer();
      if (!_isMuted) {
        final currentStep = _getCurrentStep();
        _platformAudio.playAudio('', fallbackText: '${currentStep.title}. ${currentStep.narration}');
      }
    } else {
      _animController.stop();
      _platformAudio.stopAudio();
    }
  }

  void _replay() {
    setState(() {
      _currentSeconds = 0;
      _lastSpokenStepNumber = -1;
      _isPlaying = true;
      _subSecondCounter = 0;
    });
    _animController.repeat(reverse: true);
    _startPlaybackTimer();
    _checkAndSpeakStepNarration();
  }

  void _seekTo(int seconds) {
    setState(() {
      _currentSeconds = seconds.clamp(0, _totalSeconds);
      _subSecondCounter = 0;
      _lastSpokenStepNumber = -1;
    });
    _checkAndSpeakStepNarration();
  }

  void _toggleSpeed() {
    setState(() {
      _playbackSpeed = (_playbackSpeed == 1.0) ? 0.75 : 1.0;
    });
    if (_isPlaying) {
      _startPlaybackTimer();
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    if (_isMuted) {
      _platformAudio.stopAudio();
    } else {
      final currentStep = _getCurrentStep();
      _platformAudio.playAudio('', fallbackText: '${currentStep.title}. ${currentStep.narration}');
    }
  }

  // --- Visual Stage Mockups ---

  Widget _buildWhatsAppStage(int stepIndex, double anim) {
    if (stepIndex == 0) {
      // Step 1: Open chat
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: const Color(0xFF075E54),
            child: Row(
              children: const [
                Text('WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Spacer(),
                Icon(Icons.search, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Icon(Icons.more_vert, color: Colors.white, size: 18),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade700, width: 2),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green.shade700,
                          radius: 20,
                          child: const Icon(Icons.person, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Granddaughter Emma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                              Text('Hi Grandma! Looking forward to seeing you!', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 0.9 + 0.2 * anim,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(12)),
                            child: const Text('TAP HERE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (stepIndex == 1) {
      // Step 2: Tap video camera icon
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: const Color(0xFF075E54),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                const CircleAvatar(radius: 14, backgroundColor: Colors.white, child: Icon(Icons.person, size: 16, color: Colors.green)),
                const SizedBox(width: 8),
                const Text('Emma', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const Spacer(),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: 1.0 + 0.4 * anim,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amberAccent, width: 2),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                      child: const Icon(Icons.videocam, color: Colors.black, size: 20),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                const Icon(Icons.phone, color: Colors.white, size: 18),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFECE5DD),
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.green, size: 20),
                      const SizedBox(width: 6),
                      Text('Tap the green camera button above!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (stepIndex == 2) {
      // Step 3: Ringing screen
      return Container(
        color: const Color(0xFF0B2E2B),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: 1.0 + 0.3 * anim,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x6669F0AE), width: 3)),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.face, size: 48, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Granddaughter Emma', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.ring_volume, color: Colors.greenAccent, size: 16),
                  SizedBox(width: 6),
                  Text('Ringing...', style: TextStyle(color: Colors.greenAccent, fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      // Step 4: Live video call connected!
      return Container(
        color: Colors.black87,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.face, size: 70, color: Colors.amberAccent),
                  SizedBox(height: 6),
                  Text('Granddaughter Emma', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('Connected • 00:24', style: TextStyle(color: Colors.greenAccent, fontSize: 13)),
                ],
              ),
            ),
            // Self-view PiP
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 60,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade800,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white70, size: 28),
                ),
              ),
            ),
            // Bottom end call bar
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: const Icon(Icons.mic, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 18),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.call_end, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 18),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildQRCodeStage(int stepIndex, double anim) {
    if (stepIndex == 0) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.camera_alt, color: Colors.white, size: 48),
              SizedBox(height: 8),
              Text('Camera App Open', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              Text('Point at the menu code on your table', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      );
    } else if (stepIndex == 1) {
      return Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.qr_code, size: 90, color: Colors.black),
            ),
            // Animated green scanner laser
            Positioned(
              top: 30 + (80 * anim),
              child: Container(
                width: 120,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  boxShadow: [
                    BoxShadow(color: const Color(0xCC69F0AE), blurRadius: 6, spreadRadius: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (stepIndex == 2) {
      return Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 0.95 + 0.1 * anim,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.amberAccent, blurRadius: 8)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.link, color: Colors.black, size: 20),
                      SizedBox(width: 8),
                      Text('🔗 cafe-menu.com/food', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('👆 Tap this yellow link button once!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6)),
              child: Row(
                children: const [
                  Icon(Icons.restaurant, color: Colors.deepOrange, size: 18),
                  SizedBox(width: 6),
                  Text('Garden Café — Digital Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.deepOrange)),
                ],
              ),
            ),
            const Divider(height: 12),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.soup_kitchen, color: Colors.brown, size: 24),
                    title: const Text('Tomato Basil Soup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    trailing: Text('\$6.50', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800, fontSize: 14)),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.lunch_dining, color: Colors.amber, size: 24),
                    title: const Text('Grilled Chicken Panini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    trailing: Text('\$9.00', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTextSizeStage(int stepIndex, double anim) {
    if (stepIndex == 0) {
      return Container(
        color: Colors.grey.shade100,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: const [
                  Icon(Icons.settings, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Settings Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade700, width: 2),
              ),
              child: Row(
                children: const [
                  Icon(Icons.brightness_medium, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(child: Text('Display & Brightness', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                  Icon(Icons.chevron_right, color: Colors.blue),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (stepIndex == 1) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Display Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade700, width: 2),
              ),
              child: Row(
                children: const [
                  Icon(Icons.format_size, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(child: Text('Font Size & Text Style', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                  Icon(Icons.arrow_forward, color: Colors.green),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (stepIndex == 2) {
      // Dynamic slider animating right with enlarging text
      final textScale = 14.0 + (10.0 * anim);
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(
                  'Reading is clear & comfortable!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: textScale, color: Colors.blue.shade900),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Text('A', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Slider(
                    value: 0.3 + 0.6 * anim,
                    onChanged: null,
                    activeColor: Colors.blue.shade700,
                  ),
                ),
                const Text('A', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
            const Text('Slider moving right to enlarge text', style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      );
    } else {
      return Container(
        color: Colors.green.shade50,
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 48, color: Colors.green.shade700),
              const SizedBox(height: 8),
              Text('Large Font Active Everywhere!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green.shade900)),
              const SizedBox(height: 4),
              const Text('Messages, menus, and guides are now easy on your eyes.', style: TextStyle(fontSize: 13, color: Colors.black87), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildMapsStage(int stepIndex, double anim) {
    if (stepIndex == 0) {
      return Container(
        color: const Color(0xFFE8ECEF),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('City Care Pharmacy & Clinic', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                  Spacer(),
                  Icon(Icons.mic, color: Colors.black54),
                ],
              ),
            ),
            const Spacer(),
            const Icon(Icons.location_on, color: Colors.red, size: 36),
            const Text('Pharmacy Located', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Spacer(),
          ],
        ),
      );
    } else if (stepIndex == 1) {
      return Container(
        color: const Color(0xFFE8ECEF),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)]),
              child: Row(
                children: [
                  const Icon(Icons.local_pharmacy, color: Colors.red, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('City Care Pharmacy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Open now • 4 mins walk (350m)', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.95 + 0.1 * anim,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                      icon: const Icon(Icons.directions, size: 16),
                      label: const Text('Directions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (stepIndex == 2) {
      return Container(
        color: const Color(0xFFD4E6F1),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.my_location, color: Colors.blue, size: 24),
                  SizedBox(width: 6),
                  Text('--- Walking Path ---', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Icon(Icons.local_hospital, color: Colors.red, size: 24),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(20)),
                child: const Text('▶ Start Walking Navigation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(height: 6),
              const Text('Voice speaks turn-by-turn guidance', style: TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.green.shade50,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 50),
              const SizedBox(height: 6),
              Text('You Have Arrived Safely!', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('City Care Pharmacy is right in front of you.', style: TextStyle(fontSize: 13, color: Colors.black87)),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildAntiScamStage(int stepIndex, double anim) {
    if (stepIndex == 0) {
      return Container(
        color: Colors.red.shade900,
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 0.95 + 0.15 * anim,
                child: const Icon(Icons.warning, color: Colors.amber, size: 48),
              ),
              const SizedBox(height: 8),
              const Text('🚨 Urgent Alert Scam 🚨', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('"Your bank is blocked! Send OTP immediately!"', style: TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(6)),
                child: const Text('FAKE SCARE TACTIC', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ),
      );
    } else if (stepIndex == 1) {
      return Container(
        color: const Color(0xFF1E293B),
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, color: Colors.redAccent, size: 52),
              const SizedBox(height: 8),
              const Text('🛑 GOLDEN SAFETY RULE 🛑', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0x33F44336), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent)),
                child: const Text('NEVER share OTP codes or passwords with ANY caller!', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      );
    } else if (stepIndex == 2) {
      return Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unknown Suspicious Call', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 12),
              Transform.scale(
                scale: 0.95 + 0.15 * anim,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.call_end, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text('HANG UP & BLOCK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text('It is always polite & safe to hang up!', style: TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.green.shade50,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user, color: Colors.green.shade700, size: 48),
              const SizedBox(height: 8),
              Text('You Are Protected & Safe!', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('Call your trusted family contact to verify anything suspicious.', style: TextStyle(fontSize: 12, color: Colors.black87), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildGenericStage(int stepIndex, double anim, CommunityVideo video) {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: anim * 0.2,
              child: const Icon(Icons.school, size: 46, color: Colors.amber),
            ),
            const SizedBox(height: 8),
            Text('Step ${stepIndex + 1} of 4', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(video.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center, maxLines: 2),
            const SizedBox(height: 6),
            const Text('Follow the step-by-step guidance below', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildStageForCurrentStep(_GuideStep step, double anim) {
    final title = widget.video.title.toLowerCase();
    final cat = widget.video.category.toLowerCase();
    final stepIndex = (step.stepNumber - 1).clamp(0, 3);

    if (title.contains('whatsapp') || cat.contains('whatsapp')) {
      return _buildWhatsAppStage(stepIndex, anim);
    }
    if (title.contains('qr') || cat.contains('qr')) {
      return _buildQRCodeStage(stepIndex, anim);
    }
    if (title.contains('text') || title.contains('bigger') || title.contains('clearer')) {
      return _buildTextSizeStage(stepIndex, anim);
    }
    if (title.contains('maps') || title.contains('clinic') || cat.contains('maps')) {
      return _buildMapsStage(stepIndex, anim);
    }
    if (title.contains('scam') || title.contains('fake') || title.contains('safety')) {
      return _buildAntiScamStage(stepIndex, anim);
    }
    return _buildGenericStage(stepIndex, anim, widget.video);
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final currentStep = _getCurrentStep();
    final progressFraction = (_totalSeconds > 0)
        ? (_currentSeconds / _totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title and Close button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${video.category} • By ${video.uploaderName}',
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close Video',
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Simulated Interactive Video Screen
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
                  border: Border.all(color: Colors.grey.shade800, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // Active Visual Step Mockup
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _animController,
                          builder: (context, _) => _buildStageForCurrentStep(currentStep, _animController.value),
                        ),
                      ),

                      // Status Badge (Top-Right: LIVE / PAUSED)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isPlaying ? Colors.red.shade700 : Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isPlaying ? Icons.play_arrow : Icons.pause,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isPlaying ? 'PLAYING' : 'PAUSED',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Active Step Badge (Top-Left)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xE60D47A1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Step ${currentStep.stepNumber} of ${_steps.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      // Bottom Overlay Scrubber Bar
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black87, Colors.transparent],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                  trackHeight: 4,
                                ),
                                child: Slider(
                                  value: progressFraction,
                                  onChanged: (val) {
                                    _seekTo((val * _totalSeconds).round());
                                  },
                                  activeColor: Colors.blueAccent,
                                  inactiveColor: Colors.white38,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_currentSeconds ~/ 60}:${(_currentSeconds % 60).toString().padLeft(2, '0')}',
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${_totalSeconds ~/ 60}:${(_totalSeconds % 60).toString().padLeft(2, '0')}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Senior Subtitles & Narration Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade700, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(currentStep.icon, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentStep.title,
                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        if (!_isMuted)
                          const Icon(Icons.volume_up, color: Colors.amber, size: 18)
                        else
                          const Icon(Icons.volume_off, color: Colors.white38, size: 18),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentStep.caption,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, height: 1.3),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentStep.tip,
                      style: TextStyle(color: Colors.amber.shade200, fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Step Chapter Chips for Quick Navigation
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _steps.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final step = _steps[i];
                    final isCurrent = currentStep.stepNumber == step.stepNumber;
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _seekTo(step.startSecond),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isCurrent ? Colors.blue.shade700 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Step ${step.stepNumber}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Playback Control Buttons (Play, Pause, Replay, Skip, Speed, Mute)
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 26),
                    label: Text(_isPlaying ? 'Pause' : 'Play', style: const TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(100, 48),
                    ),
                    onPressed: _togglePlayPause,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.replay, size: 26),
                    label: const Text('Replay', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 48),
                    ),
                    onPressed: _replay,
                  ),
                  IconButton(
                    tooltip: 'Back 10 seconds',
                    icon: const Icon(Icons.replay_10, size: 28),
                    onPressed: () => _seekTo(_currentSeconds - 10),
                  ),
                  IconButton(
                    tooltip: 'Forward 10 seconds',
                    icon: const Icon(Icons.forward_10, size: 28),
                    onPressed: () => _seekTo(_currentSeconds + 10),
                  ),
                  IconButton(
                    tooltip: _isMuted ? 'Unmute Voice Narration' : 'Mute Voice Narration',
                    icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, size: 26, color: _isMuted ? Colors.red : Colors.blue.shade700),
                    onPressed: _toggleMute,
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    onPressed: _toggleSpeed,
                    child: Text(
                      _playbackSpeed == 1.0 ? '🐢 0.75x Slow' : '⚡ 1.0x Normal',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description Text
              Text(
                video.description,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
