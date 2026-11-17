enum VideoModerationStatus { pending, approved, rejected }

class CommunityVideo {
  final String id;
  final String title;
  final String description;
  final String category;
  final int durationSeconds;
  final String uploaderId;
  final String uploaderName;
  final String videoUrl;
  final String thumbnailUrl;
  int helpfulCount;
  bool isMarkedHelpful;
  int reportsCount;
  VideoModerationStatus status;
  String? rejectionReason;
  final DateTime uploadDate;
  final bool isVerifiedGuide;
  final String guideType;
  final bool isAntiFakeCertified;

  CommunityVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationSeconds,
    required this.uploaderId,
    required this.uploaderName,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.helpfulCount = 0,
    this.isMarkedHelpful = false,
    this.reportsCount = 0,
    this.status = VideoModerationStatus.approved,
    this.rejectionReason,
    required this.uploadDate,
    this.isVerifiedGuide = true,
    this.guideType = 'Step-by-Step Guide',
    this.isAntiFakeCertified = true,
  });

  factory CommunityVideo.fromJson(Map<String, dynamic> json) {
    return CommunityVideo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      durationSeconds: json['durationSeconds'] as int? ?? 60,
      uploaderId: json['uploaderId'] as String? ?? 'user_1',
      uploaderName: json['uploaderName'] as String? ?? 'Community Member',
      videoUrl: json['videoUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      isMarkedHelpful: json['isMarkedHelpful'] as bool? ?? false,
      reportsCount: json['reportsCount'] as int? ?? 0,
      status: VideoModerationStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'approved'),
        orElse: () => VideoModerationStatus.approved,
      ),
      rejectionReason: json['rejectionReason'] as String?,
      uploadDate: json['uploadDate'] != null
          ? DateTime.parse(json['uploadDate'] as String)
          : DateTime.now(),
      isVerifiedGuide: json['isVerifiedGuide'] as bool? ?? true,
      guideType: json['guideType'] as String? ?? 'Step-by-Step Guide',
      isAntiFakeCertified: json['isAntiFakeCertified'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'durationSeconds': durationSeconds,
    'uploaderId': uploaderId,
    'uploaderName': uploaderName,
    'videoUrl': videoUrl,
    'thumbnailUrl': thumbnailUrl,
    'helpfulCount': helpfulCount,
    'isMarkedHelpful': isMarkedHelpful,
    'reportsCount': reportsCount,
    'status': status.name,
    'rejectionReason': rejectionReason,
    'uploadDate': uploadDate.toIso8601String(),
    'isVerifiedGuide': isVerifiedGuide,
    'guideType': guideType,
    'isAntiFakeCertified': isAntiFakeCertified,
  };
}
