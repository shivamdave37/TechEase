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
  bool isLoggedIn;
  String rawPhoneNumber;
  List<String> blockedUserIds;
  List<String> bookmarkedLessonIds;
  List<String> completedLessonIds;
  Map<String, int> lessonStepProgress; // lessonId -> lastStepIndex

  // Senior-First Assistance & Motivation features
  String familyContactName;
  String familyContactPhone;
  int learningStreakDays;
  List<String> earnedBadges;

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
    this.isLoggedIn = true,
    this.rawPhoneNumber = '+91 98765 43210',
    List<String>? blockedUserIds,
    List<String>? bookmarkedLessonIds,
    List<String>? completedLessonIds,
    Map<String, int>? lessonStepProgress,
    this.familyContactName = 'Daughter Sarah',
    this.familyContactPhone = '+91 98765 12345',
    this.learningStreakDays = 3,
    List<String>? earnedBadges,
  })  : blockedUserIds = blockedUserIds ?? [],
        bookmarkedLessonIds = bookmarkedLessonIds ?? [],
        completedLessonIds = completedLessonIds ?? [],
        lessonStepProgress = lessonStepProgress ?? {},
        earnedBadges = earnedBadges ?? ['starter_badge', 'whatsapp_badge'];

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
      familyContactName: 'Daughter Sarah',
      familyContactPhone: '+91 98765 12345',
      learningStreakDays: 3,
      earnedBadges: ['starter_badge', 'whatsapp_badge'],
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
      familyContactName: json['familyContactName'] as String? ?? 'Daughter Sarah',
      familyContactPhone: json['familyContactPhone'] as String? ?? '+91 98765 12345',
      learningStreakDays: json['learningStreakDays'] as int? ?? 3,
      earnedBadges: (json['earnedBadges'] as List<dynamic>? ?? ['starter_badge', 'whatsapp_badge']).cast<String>(),
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
    'familyContactName': familyContactName,
    'familyContactPhone': familyContactPhone,
    'learningStreakDays': learningStreakDays,
    'earnedBadges': earnedBadges,
  };
}
