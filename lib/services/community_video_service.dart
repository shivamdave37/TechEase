import 'package:material_ui/material_ui.dart';
import '../models/community_video.dart';

class CommunityVideoService extends ChangeNotifier {
  final List<CommunityVideo> _videos = [];
  String _selectedCategory = 'All';

  String get selectedCategory => _selectedCategory;
  List<CommunityVideo> get allVideos => List.unmodifiable(_videos);

  List<CommunityVideo> get approvedVideos {
    return _videos.where((v) {
      if (v.status != VideoModerationStatus.approved) return false;
      if (_selectedCategory != 'All' && v.category != _selectedCategory) return false;
      return true;
    }).toList();
  }

  List<CommunityVideo> get pendingModerationVideos {
    return _videos.where((v) => v.status == VideoModerationStatus.pending).toList();
  }

  CommunityVideoService() {
    _seedInitialVideos();
  }

  void _seedInitialVideos() {
    _videos.addAll([
      CommunityVideo(
        id: 'vid_1',
        title: 'How to Make a WhatsApp Video Call',
        description: 'See how to tap the video camera button in a chat to speak face-to-face with your grandkids.',
        category: 'WhatsApp',
        durationSeconds: 85,
        uploaderId: 'user_mary',
        uploaderName: 'Mary (Senior Community Ambassador)',
        videoUrl: 'assets/videos/sample.mp4',
        thumbnailUrl: 'assets/images/whatsapp_step3.png',
        helpfulCount: 42,
        isMarkedHelpful: false,
        status: VideoModerationStatus.approved,
        uploadDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CommunityVideo(
        id: 'vid_2',
        title: 'How to Scan a Restaurant QR Code Menu',
        description: 'Simple walkthrough showing how to hold the phone camera steady to see the food menu.',
        category: 'QR Codes',
        durationSeconds: 65,
        uploaderId: 'user_robert',
        uploaderName: 'Robert (Tech Helper)',
        videoUrl: 'assets/videos/sample.mp4',
        thumbnailUrl: 'assets/images/qr.png',
        helpfulCount: 38,
        isMarkedHelpful: false,
        status: VideoModerationStatus.approved,
        uploadDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      CommunityVideo(
        id: 'vid_3',
        title: 'How to Make Phone Text Bigger & Clearer',
        description: 'Watch step-by-step how to adjust the screen text size so reading is effortless on the eyes.',
        category: 'Smartphone Basics',
        durationSeconds: 50,
        uploaderId: 'user_priya',
        uploaderName: 'Priya (Community Volunteer)',
        videoUrl: 'assets/videos/sample.mp4',
        thumbnailUrl: 'assets/images/basics.png',
        helpfulCount: 56,
        isMarkedHelpful: true,
        status: VideoModerationStatus.approved,
        uploadDate: DateTime.now().subtract(const Duration(days: 7)),
      ),
      CommunityVideo(
        id: 'vid_4',
        title: 'Finding the Nearest Clinic or Pharmacy on Google Maps',
        description: 'Type "clinic" or "pharmacy" in Google Maps and tap Directions to get walking or bus routes.',
        category: 'Google Maps',
        durationSeconds: 95,
        uploaderId: 'user_carlos',
        uploaderName: 'Carlos (Senior Peer)',
        videoUrl: 'assets/videos/sample.mp4',
        thumbnailUrl: 'assets/images/maps.png',
        helpfulCount: 29,
        isMarkedHelpful: false,
        status: VideoModerationStatus.approved,
        uploadDate: DateTime.now().subtract(const Duration(days: 10)),
        isVerifiedGuide: true,
        guideType: 'Maps Navigation Guide',
        isAntiFakeCertified: true,
      ),
      CommunityVideo(
        id: 'vid_5',
        title: 'Anti-Scam Alert: How to Spot Fake Calls & Scam Messages',
        description: 'Crucial guide for seniors: Never share OTPs or click suspicious links claiming you won a prize. Learn to block fake numbers safely.',
        category: 'Smartphone Basics',
        durationSeconds: 110,
        uploaderId: 'user_safety_team',
        uploaderName: 'Elderly Cyber Safety Team',
        videoUrl: 'assets/videos/sample.mp4',
        thumbnailUrl: 'assets/images/basics.png',
        helpfulCount: 88,
        isMarkedHelpful: true,
        status: VideoModerationStatus.approved,
        uploadDate: DateTime.now().subtract(const Duration(days: 1)),
        isVerifiedGuide: true,
        guideType: 'Anti-Scam Guide',
        isAntiFakeCertified: true,
      ),
    ]);
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleHelpful(String videoId) {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      final video = _videos[index];
      if (video.isMarkedHelpful) {
        video.isMarkedHelpful = false;
        video.helpfulCount = (video.helpfulCount - 1).clamp(0, 99999);
      } else {
        video.isMarkedHelpful = true;
        video.helpfulCount += 1;
      }
      notifyListeners();
    }
  }

  void reportVideo(String videoId, String reason) {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      _videos[index].reportsCount += 1;
      notifyListeners();
    }
  }

  void submitVideo({
    required String title,
    required String description,
    required String category,
    required String uploaderName,
    required String uploaderId,
    required String videoPathOrUrl,
    required int durationSeconds,
    bool autoApprove = false,
    String guideType = 'Step-by-Step Guide',
    bool isAntiFakeCertified = true,
  }) {
    final newVideo = CommunityVideo(
      id: 'vid_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      description: description.trim(),
      category: category,
      durationSeconds: durationSeconds,
      uploaderId: uploaderId,
      uploaderName: uploaderName,
      videoUrl: videoPathOrUrl,
      thumbnailUrl: 'assets/images/basics.png',
      status: autoApprove ? VideoModerationStatus.approved : VideoModerationStatus.pending,
      uploadDate: DateTime.now(),
      isVerifiedGuide: true,
      guideType: guideType,
      isAntiFakeCertified: isAntiFakeCertified,
    );
    _videos.insert(0, newVideo);
    notifyListeners();
  }

  void approveVideo(String videoId) {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      _videos[index].status = VideoModerationStatus.approved;
      _videos[index].rejectionReason = null;
      notifyListeners();
    }
  }

  void rejectVideo(String videoId, String reason) {
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      _videos[index].status = VideoModerationStatus.rejected;
      _videos[index].rejectionReason = reason;
      notifyListeners();
    }
  }
}
