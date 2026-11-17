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
  String _selectedCategory = 'WhatsApp';
  bool _noSensitiveDataConfirmed = false;
  bool _isRecordingSelected = false;
  bool _isPlayingPreview = false;

  final List<String> _categories = [
    'WhatsApp',
    'Smartphone Basics',
    'Google Maps',
    'QR Codes',
    'Photos & Gallery',
    'Internet & Browsing',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitVideo() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a clear title for your video.')),
      );
      return;
    }

    if (!_noSensitiveDataConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm the safety checklist to protect your privacy.')),
      );
      return;
    }

    final user = Provider.of<UserService>(context, listen: false);
    final videoService = Provider.of<CommunityVideoService>(context, listen: false);

    videoService.submitVideo(
      title: _titleController.text,
      description: _descController.text,
      category: _selectedCategory,
      uploaderName: user.profile.name,
      uploaderId: user.profile.id,
      videoPathOrUrl: 'user_uploaded_${DateTime.now().millisecondsSinceEpoch}',
      durationSeconds: 45,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 36),
            SizedBox(width: 10),
            Text('Submitted!'),
          ],
        ),
        content: const Text(
          'Thank you for helping others learn!\n\nYour video has been sent to our community review board to make sure no personal info was accidentally shown. It will appear in the library once approved.',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close upload screen
            },
            child: const Text('Back to Videos', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share an Educational Video', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDesign.spaceMedium),
          children: [
            // Video Source Selector
            const Text('Step 1: Choose Video', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecordingSelected ? Colors.blue.shade700 : Colors.grey.shade200,
                      foregroundColor: _isRecordingSelected ? Colors.white : Colors.black87,
                      minimumSize: const Size(0, 56),
                    ),
                    icon: const Icon(Icons.videocam, size: 28),
                    label: const Text('Record Video', style: TextStyle(fontSize: 16)),
                    onPressed: () {
                      setState(() => _isRecordingSelected = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Camera ready. Video recorded successfully.')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isRecordingSelected ? Colors.blue.shade700 : Colors.grey.shade200,
                      foregroundColor: !_isRecordingSelected ? Colors.white : Colors.black87,
                      minimumSize: const Size(0, 56),
                    ),
                    icon: const Icon(Icons.photo_library, size: 28),
                    label: const Text('From Gallery', style: TextStyle(fontSize: 16)),
                    onPressed: () {
                      setState(() => _isRecordingSelected = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Video selected from phone gallery.')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Video Preview Player Box
            Container(
              height: 190,
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
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isPlayingPreview ? 'Playing Preview (0:15 / 0:45)' : 'Tap to Preview Your Video',
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
            const SizedBox(height: 24),

            // Details section
            const Text('Step 2: Video Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title of your video',
                hintText: 'e.g. How I send voice notes to my sister',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Short explanation (optional)',
                hintText: 'Tell other seniors what they will learn in this video.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 2,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 16)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 24),

            // Privacy & Safety Checklist
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade400, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield, color: Colors.amber.shade900, size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'Privacy & Safety Checklist',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'To protect you from scams or identity theft, please confirm your video does NOT show:',
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  const Text('• Bank card numbers, PINs, or OTPs\n• Passwords or email login screens\n• Your home address or official ID card', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _noSensitiveDataConfirmed,
                    title: const Text(
                      'I confirm this video is safe and contains no private passwords or financial information.',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onChanged: (val) => setState(() => _noSensitiveDataConfirmed = val ?? false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: _submitVideo,
              child: const Text('Submit Video for Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
