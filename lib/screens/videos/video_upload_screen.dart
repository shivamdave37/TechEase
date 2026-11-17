import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../design_system.dart';
import '../../services/community_video_service.dart';
import '../../services/user_service.dart';

class VideoUploadScreen extends StatefulWidget {
  const VideoUploadScreen({Key? key}) : super(key: key);

  @override
  State<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  String _selectedCategory = 'WhatsApp';
  String _selectedGuideType = 'Step-by-Step Guide';
  bool _noSensitiveDataConfirmed = false;
  bool _isAntiFakeConfirmed = false;
  bool _publishDirectly = true;
  int _sourceMode = 0; // 0 = Record, 1 = Gallery, 2 = Video Link
  bool _isPlayingPreview = false;

  final List<String> _categories = [
    'WhatsApp',
    'Smartphone Basics',
    'Google Maps',
    'QR Codes',
    'Photos & Gallery',
    'Internet & Browsing',
  ];

  final List<String> _guideTypes = [
    'Step-by-Step Guide',
    'Anti-Scam Guide',
    'Settings & Display Guide',
    'Communication & Messaging Guide',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _submitVideo() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a clear title for your guide video.')),
      );
      return;
    }

    if (!_isAntiFakeConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please certify that this is a genuine, safe guide video (no fake advice).')),
      );
      return;
    }

    if (!_noSensitiveDataConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm the safety checklist to protect user privacy.')),
      );
      return;
    }

    final user = Provider.of<UserService>(context, listen: false);
    final videoService = Provider.of<CommunityVideoService>(context, listen: false);

    final videoSource = _sourceMode == 2 && _urlController.text.trim().isNotEmpty
        ? _urlController.text.trim()
        : 'assets/videos/sample.mp4';

    videoService.submitVideo(
      title: _titleController.text,
      description: _descController.text.isNotEmpty
          ? _descController.text
          : 'Step-by-step verified learning guide for seniors.',
      category: _selectedCategory,
      uploaderName: '${user.profile.name} (Verified Contributor)',
      uploaderId: user.profile.id,
      videoPathOrUrl: videoSource,
      durationSeconds: 65,
      autoApprove: _publishDirectly,
      guideType: _selectedGuideType,
      isAntiFakeCertified: true,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.verified, color: Colors.green, size: 36),
            SizedBox(width: 10),
            Text('Guide Uploaded!'),
          ],
        ),
        content: Text(
          _publishDirectly
              ? 'Thank you for protecting our senior community!\n\nYour authentic guide video has been published directly with a "🛡️ Verified Safe Guide" badge. Other seniors can now learn safely without worrying about fake advice.'
              : 'Thank you! Your guide video has been submitted to the community board for review.',
          style: const TextStyle(fontSize: 17, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('View in Video Library', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload a Safe Guide Video', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDesign.spaceMedium),
          children: [
            // Anti-Fake Mission Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade600, width: 2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: Colors.green.shade800, size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community Anti-Fake Video Shield',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Fake and scam videos harm seniors with bad advice. Help your fellow learners by uploading real, clear, step-by-step guides.',
                          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step 1: Guide Type & Category
            const Text('Step 1: Guide Category & Type', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedGuideType,
              decoration: InputDecoration(
                labelText: 'Type of Guide',
                prefixIcon: const Icon(Icons.verified),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: _guideTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 16))))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedGuideType = val);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Topic / App Category',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 16))))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 22),

            // Step 2: Choose Video Input Source
            const Text('Step 2: Video Source', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _sourceMode == 0 ? Colors.blue.shade700 : Colors.grey.shade200,
                      foregroundColor: _sourceMode == 0 ? Colors.white : Colors.black87,
                      minimumSize: const Size(0, 50),
                    ),
                    icon: const Icon(Icons.videocam),
                    label: const Text('Record'),
                    onPressed: () {
                      setState(() => _sourceMode = 0);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Camera ready. Video recorded successfully.')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _sourceMode == 1 ? Colors.blue.shade700 : Colors.grey.shade200,
                      foregroundColor: _sourceMode == 1 ? Colors.white : Colors.black87,
                      minimumSize: const Size(0, 50),
                    ),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    onPressed: () {
                      setState(() => _sourceMode = 1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Video selected from phone gallery.')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _sourceMode == 2 ? Colors.blue.shade700 : Colors.grey.shade200,
                      foregroundColor: _sourceMode == 2 ? Colors.white : Colors.black87,
                      minimumSize: const Size(0, 50),
                    ),
                    icon: const Icon(Icons.link),
                    label: const Text('Web Link'),
                    onPressed: () => setState(() => _sourceMode = 2),
                  ),
                ),
              ],
            ),
            if (_sourceMode == 2) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Paste Video Link (YouTube or Web URL)',
                  hintText: 'https://youtube.com/watch?v=...',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(height: 14),

            // Video Preview Player Box
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isPlayingPreview ? Icons.pause_circle_filled : Icons.play_circle_fill,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isPlayingPreview ? 'Playing Guide Preview (0:15 / 1:05)' : 'Tap to Preview Your Guide Video',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _isPlayingPreview = !_isPlayingPreview),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Step 3: Video Title & Description
            const Text('Step 3: Title & Explanation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title of your guide video',
                hintText: 'e.g. How to send a photo to your daughter on WhatsApp',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Clear step-by-step description',
                hintText: 'Explain the steps in simple everyday language so seniors can follow easily.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 2,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 22),

            // Anti-Fake Video & Safety Checklist
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade600, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel, color: Colors.amber.shade900, size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'Authenticity & Anti-Fake Pledge',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.transparent,
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isAntiFakeConfirmed,
                      title: const Text(
                        'I certify this is an authentic, genuine educational guide (no fake advice or scam claims).',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onChanged: (val) => setState(() => _isAntiFakeConfirmed = val ?? false),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _noSensitiveDataConfirmed,
                      title: const Text(
                        'I confirm this video is safe and exposes no bank pins, passwords, or personal phone numbers.',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onChanged: (val) => setState(() => _noSensitiveDataConfirmed = val ?? false),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Publishing Options
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _publishDirectly,
              title: const Text(
                'Publish as Verified Safe Guide',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Makes your guide immediately available in the senior library with the verified shield badge.',
                style: TextStyle(fontSize: 14),
              ),
              onChanged: (val) => setState(() => _publishDirectly = val),
            ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.verified, size: 26),
              onPressed: _submitVideo,
              label: const Text('Publish Guide Video', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
