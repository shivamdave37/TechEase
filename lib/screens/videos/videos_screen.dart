import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../design_system.dart';
import '../../models/community_video.dart';
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

class _VideoPlayerModal extends StatefulWidget {
  final CommunityVideo video;
  const _VideoPlayerModal({Key? key, required this.video}) : super(key: key);

  @override
  State<_VideoPlayerModal> createState() => _VideoPlayerModalState();
}

class _VideoPlayerModalState extends State<_VideoPlayerModal> {
  bool _isPlaying = true;
  double _currentProgress = 0.35;

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final totalSeconds = video.durationSeconds;
    final currentSeconds = (totalSeconds * _currentProgress).toInt();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    video.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Video Player Screen
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Icon(
                      _isPlaying ? Icons.play_arrow : Icons.pause,
                      size: 72,
                      color: Colors.white54,
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Column(
                      children: [
                        Slider(
                          value: _currentProgress,
                          onChanged: (val) => setState(() => _currentProgress = val),
                          activeColor: Colors.blue,
                          inactiveColor: Colors.white30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${currentSeconds ~/ 60}:${(currentSeconds % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            Text(
                              '${totalSeconds ~/ 60}:${(totalSeconds % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Control Buttons: Play, Pause, Replay
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 26),
                  label: Text(_isPlaying ? 'Pause' : 'Play', style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(110, 48)),
                  onPressed: () => setState(() => _isPlaying = !_isPlaying),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.replay, size: 26),
                  label: const Text('Replay', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(110, 48)),
                  onPressed: () => setState(() {
                    _currentProgress = 0.0;
                    _isPlaying = true;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              video.description,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
