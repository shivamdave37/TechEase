import 'package:flutter_test/flutter_test.dart';
import 'package:elder_smartphone_learning_app/models/community_video.dart';
import 'package:elder_smartphone_learning_app/services/accessibility_service.dart';
import 'package:elder_smartphone_learning_app/services/analytics_service.dart';
import 'package:elder_smartphone_learning_app/services/community_video_service.dart';
import 'package:elder_smartphone_learning_app/services/learning_service.dart';
import 'package:elder_smartphone_learning_app/services/localization_service.dart';
import 'package:elder_smartphone_learning_app/services/moderation_service.dart';
import 'package:elder_smartphone_learning_app/services/saved_lessons_service.dart';
import 'package:elder_smartphone_learning_app/services/search_service.dart';
import 'package:elder_smartphone_learning_app/services/user_service.dart';
import 'package:elder_smartphone_learning_app/services/voice_group_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalizationService', () {
    test('default locale is en and translates keys', () {
      final loc = LocalizationService();
      expect(loc.currentLocale, 'en');
      expect(loc.tr('welcome'), 'Welcome');
      expect(loc.tr('next'), 'Next');
    });

    test('switches to Hindi and Spanish', () {
      final loc = LocalizationService();
      loc.setLocale('hi');
      expect(loc.currentLocale, 'hi');
      expect(loc.tr('welcome'), 'स्वागत है');

      loc.setLocale('es');
      expect(loc.currentLocale, 'es');
      expect(loc.tr('welcome'), 'Bienvenido');
    });

    test('returns key or English fallback for missing keys', () {
      final loc = LocalizationService();
      expect(loc.tr('non_existent_key'), 'non_existent_key');
    });
  });

  group('AccessibilityService', () {
    test('font scale is bounded within 0.85 and 1.35', () {
      final acc = AccessibilityService();
      expect(acc.fontScale, 1.0);
      acc.setFontScale(1.25);
      expect(acc.fontScale, 1.25);

      // Outside bounds should be ignored
      acc.setFontScale(2.5);
      expect(acc.fontScale, 1.25);
    });

    test('high contrast mode changes theme correctly', () {
      final acc = AccessibilityService();
      expect(acc.isHighContrast, isFalse);
      acc.toggleHighContrast(true);
      expect(acc.isHighContrast, isTrue);

      final theme = acc.themeData;
      expect(theme.primaryColor.toARGB32(), 0xFF000000); // pure black in high contrast
    });
  });

  group('UserService', () {
    test('updates name and manages blocked users', () {
      final user = UserService();
      expect(user.profile.name, 'Elder Learner');
      user.updateName('Grandma Rose');
      expect(user.profile.name, 'Grandma Rose');

      expect(user.isUserBlocked('spammer_123'), isFalse);
      user.blockUser('spammer_123');
      expect(user.isUserBlocked('spammer_123'), isTrue);
      user.unblockUser('spammer_123');
      expect(user.isUserBlocked('spammer_123'), isFalse);
    });

    test('requests OTP and verifies phone number login', () {
      final user = UserService();
      final otp = user.requestOtp('+91 98765 43210');
      expect(otp, '1234');
      expect(user.pendingPhone, '+91 98765 43210');

      // Incorrect OTP fails
      final wrong = user.verifyOtp('9999');
      expect(wrong, isFalse);

      // Correct OTP succeeds
      final success = user.verifyOtp('1234');
      expect(success, isTrue);
      expect(user.profile.isLoggedIn, isTrue);
      expect(user.profile.maskedPhone, '***-***-3210');

      user.logout();
      expect(user.profile.isLoggedIn, isFalse);
    });
  });

  group('SavedLessonsService', () {
    test('adds, checks, and toggles bookmarks', () {
      final saved = SavedLessonsService();
      expect(saved.isBookmarked('test_lesson'), isFalse);
      saved.addBookmark('test_lesson');
      expect(saved.isBookmarked('test_lesson'), isTrue);
      saved.toggleBookmark('test_lesson');
      expect(saved.isBookmarked('test_lesson'), isFalse);
    });

    test('saves step progress and retrieves saved step', () {
      final saved = SavedLessonsService();
      saved.saveStepProgress('lesson_a', 3);
      expect(saved.getSavedStep('lesson_a'), 3);
      expect(saved.lastActiveLessonId, 'lesson_a');
    });
  });

  group('SearchService', () {
    late LearningService learning;

    setUp(() {
      learning = LearningService();
    });

    test('returns empty search on blank query and All category', () {
      final search = SearchService();
      final results = search.search(learning);
      expect(results.isEmpty, isTrue);
    });

    test('finds matching lessons and glossary terms', () {
      final search = SearchService();
      search.setQuery('WhatsApp');
      final results = search.search(learning);
      expect(results.isEmpty, isFalse);
    });

    test('filters search results by category', () {
      final search = SearchService();
      search.setCategoryFilter('Google Maps');
      final results = search.search(learning);
      expect(results.categories.any((c) => c.title == 'Google Maps'), isTrue);
      expect(results.categories.any((c) => c.title == 'WhatsApp'), isFalse);
    });
  });

  group('CommunityVideoService', () {
    test('initializes with approved videos', () {
      final service = CommunityVideoService();
      expect(service.approvedVideos.isNotEmpty, isTrue);
    });

    test('toggles helpful count', () {
      final service = CommunityVideoService();
      final video = service.approvedVideos.first;
      final initialCount = video.helpfulCount;

      service.toggleHelpful(video.id);
      expect(video.isMarkedHelpful, isTrue);
      expect(video.helpfulCount, initialCount + 1);

      service.toggleHelpful(video.id);
      expect(video.isMarkedHelpful, isFalse);
      expect(video.helpfulCount, initialCount);
    });

    test('submits video to pending queue and approves it', () {
      final service = CommunityVideoService();
      final initialPending = service.pendingModerationVideos.length;

      service.submitVideo(
        title: 'New Senior Guide',
        description: 'Easy way to take pictures',
        category: 'Photos & Gallery',
        uploaderName: 'Elder Learner',
        uploaderId: 'user_1',
        videoPathOrUrl: 'path/to/vid',
        durationSeconds: 40,
      );

      expect(service.pendingModerationVideos.length, initialPending + 1);
      final newVid = service.pendingModerationVideos.first;
      expect(newVid.title, 'New Senior Guide');
      expect(newVid.status, VideoModerationStatus.pending);

      service.approveVideo(newVid.id);
      expect(newVid.status, VideoModerationStatus.approved);
    });

    test('rejects video with reason', () {
      final service = CommunityVideoService();
      service.submitVideo(
        title: 'Unsafe Video',
        description: 'Contains sensitive details',
        category: 'WhatsApp',
        uploaderName: 'User',
        uploaderId: 'u2',
        videoPathOrUrl: 'url',
        durationSeconds: 20,
      );
      final vid = service.pendingModerationVideos.first;
      service.rejectVideo(vid.id, 'Shows private address');
      expect(vid.status, VideoModerationStatus.rejected);
      expect(vid.rejectionReason, 'Shows private address');
    });
  });

  group('VoiceGroupService', () {
    test('initializes with seed groups and messages', () {
      final service = VoiceGroupService();
      expect(service.groups.length, greaterThanOrEqualTo(2));
      final msgs = service.getMessagesForGroup('grp_beginners');
      expect(msgs.isNotEmpty, isTrue);
    });

    test('creates new voice group', () {
      final service = VoiceGroupService();
      final count = service.groups.length;

      service.createGroup(
        name: 'Grandparents Club',
        topic: 'Stories and recipes',
        description: 'Share family voice stories',
        creatorName: 'Elder Learner',
        creatorId: 'user_1',
      );

      expect(service.groups.length, count + 1);
      expect(service.groups.first.name, 'Grandparents Club');
    });

    test('joins group with invite code', () {
      final service = VoiceGroupService();
      final group = service.groups.first;
      final joined = service.joinGroupByCode(group.inviteCode, 'new_user_9', 'New Member');
      expect(joined, isTrue);
      expect(group.members.any((m) => m.userId == 'new_user_9'), isTrue);

      final invalid = service.joinGroupByCode('INVALID-999', 'user_x', 'Test');
      expect(invalid, isFalse);
    });

    test('sends and plays voice messages', () {
      final service = VoiceGroupService();
      service.sendVoiceMessage(
        groupId: 'grp_beginners',
        senderId: 'user_1',
        senderName: 'Learner',
        durationSeconds: 10,
        waveform: [0.2, 0.4, 0.8],
      );

      final msgs = service.getMessagesForGroup('grp_beginners');
      final lastMsg = msgs.last;
      expect(lastMsg.durationSeconds, 10);

      service.playMessage(lastMsg.id);
      expect(service.isPlayingAudio, isTrue);
      expect(service.currentlyPlayingMessageId, lastMsg.id);

      service.stopAudio();
      expect(service.isPlayingAudio, isFalse);
    });
  });

  group('ModerationService', () {
    test('reports and resolves items', () {
      final mod = ModerationService();
      final initialCount = mod.activeReports.length;

      mod.reportItem(
        itemType: 'video',
        itemId: 'vid_test',
        titleOrSender: 'Spam Video',
        reason: 'Fraudulent content',
        reportedByUserId: 'user_1',
      );

      expect(mod.activeReports.length, initialCount + 1);
      final report = mod.activeReports.first;
      mod.dismissReport(report.id);
      expect(report.isResolved, isTrue);
    });
  });

  group('AnalyticsService', () {
    test('logs events and aggregates counters', () {
      final analytics = AnalyticsService();
      expect(analytics.lessonsStarted, 0);
      analytics.logEvent('lesson_started');
      expect(analytics.lessonsStarted, 1);

      analytics.logEvent('lesson_completed');
      expect(analytics.lessonsCompleted, 1);

      analytics.logEvent('video_watched');
      expect(analytics.videosWatched, 1);

      analytics.logEvent('voice_message_sent');
      expect(analytics.voiceMessagesSent, 1);
    });
  });
}
