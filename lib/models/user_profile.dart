class UserProfile {
  final String id;
  String name;
  String maskedPhone;
  String email;
  String languageCode; // 'en', 'hi', 'es'
  double fontSizeScale; // 0.85 to 1.35
  bool highContrastEnabled;
  int primaryColorValue; // e.g. Colors.blue.value
  bool isAdmin;
  List<String> blockedUserIds;
  List<String> bookmarkedLessonIds;
  List<String> completedLessonIds;
  Map<String, int> lessonStepProgress; // lessonId -> lastStepIndex

  UserProfile({
    required this.id,
    required this.name,
    required this.maskedPhone,
    required this.email,
    this.languageCode = 'en',
    this.fontSizeScale = 1.0,
    this.highContrastEnabled = false,
    this.primaryColorValue = 0xFF1976D2, // Colors.blue.shade700
    this.isAdmin = true, // Defaults to true so the user can test the admin moderation dashboard freely!
    List<String>? blockedUserIds,
    List<String>? bookmarkedLessonIds,
    List<String>? completedLessonIds,
    Map<String, int>? lessonStepProgress,
  })  : blockedUserIds = blockedUserIds ?? [],
        bookmarkedLessonIds = bookmarkedLessonIds ?? [],
        completedLessonIds = completedLessonIds ?? [],
        lessonStepProgress = lessonStepProgress ?? {};

  factory UserProfile.defaultProfile() {
    return UserProfile(
      id: 'elder_user_1',
      name: 'Elder Learner',
      maskedPhone: '***-***-7890',
      email: 'learner@example.com',
      languageCode: 'en',
      fontSizeScale: 1.0,
      highContrastEnabled: false,
      primaryColorValue: 0xFF1565C0,
      isAdmin: true,
      bookmarkedLessonIds: ['lesson1'],
      completedLessonIds: [],
      lessonStepProgress: {'lesson1': 1},
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? 'elder_user_1',
      name: json['name'] as String? ?? 'Elder Learner',
      maskedPhone: json['maskedPhone'] as String? ?? '***-***-7890',
      email: json['email'] as String? ?? '',
      languageCode: json['languageCode'] as String? ?? 'en',
      fontSizeScale: (json['fontSizeScale'] as num?)?.toDouble() ?? 1.0,
      highContrastEnabled: json['highContrastEnabled'] as bool? ?? false,
      primaryColorValue: json['primaryColorValue'] as int? ?? 0xFF1565C0,
      isAdmin: json['isAdmin'] as bool? ?? true,
      blockedUserIds: (json['blockedUserIds'] as List<dynamic>? ?? []).cast<String>(),
      bookmarkedLessonIds: (json['bookmarkedLessonIds'] as List<dynamic>? ?? []).cast<String>(),
      completedLessonIds: (json['completedLessonIds'] as List<dynamic>? ?? []).cast<String>(),
      lessonStepProgress: (json['lessonStepProgress'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v as int)),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'maskedPhone': maskedPhone,
    'email': email,
    'languageCode': languageCode,
    'fontSizeScale': fontSizeScale,
    'highContrastEnabled': highContrastEnabled,
    'primaryColorValue': primaryColorValue,
    'isAdmin': isAdmin,
    'blockedUserIds': blockedUserIds,
    'bookmarkedLessonIds': bookmarkedLessonIds,
    'completedLessonIds': completedLessonIds,
    'lessonStepProgress': lessonStepProgress,
  };
}
