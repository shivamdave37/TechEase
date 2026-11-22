import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:elder_smartphone_learning_app/widgets/zoomable_image_viewer.dart';
import 'package:elder_smartphone_learning_app/screens/auth/phone_login_screen.dart';
import 'package:elder_smartphone_learning_app/screens/videos/video_upload_screen.dart';
import 'package:elder_smartphone_learning_app/screens/videos/videos_screen.dart';
import 'package:elder_smartphone_learning_app/screens/voice_groups/voice_chat_screen.dart';
import 'package:elder_smartphone_learning_app/services/user_service.dart';
import 'package:elder_smartphone_learning_app/services/community_video_service.dart';
import 'package:elder_smartphone_learning_app/services/voice_group_service.dart';
import 'package:elder_smartphone_learning_app/services/moderation_service.dart';
import 'package:elder_smartphone_learning_app/services/localization_service.dart';

void main() {
  group('ZoomableImageViewer Tests', () {
    testWidgets('renders zoom controls, supports zoom in, and reset', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZoomableImageViewer(
              imagePath: 'assets/images/placeholder.png',
              height: 250,
            ),
          ),
        ),
      );

      // Verify controls are rendered
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.text('Zoom'), findsOneWidget);
      expect(find.byIcon(Icons.pinch), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen), findsOneWidget);

      // Tap zoom in button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Reset button now appears
      expect(find.text('Reset'), findsOneWidget);

      // Tap reset button
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Reset button disappears after resetting to scale 1.0
      expect(find.text('Reset'), findsNothing);
    });
  });

  group('PhoneLoginScreen Tests', () {
    testWidgets('completes phone entry, OTP request, and demo verification', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final userService = UserService();

      await tester.pumpWidget(
        ChangeNotifierProvider<UserService>.value(
          value: userService,
          child: const MaterialApp(
            home: PhoneLoginScreen(isModal: true),
          ),
        ),
      );

      // Initial state: phone entry step
      expect(find.text('Sign In with Phone'), findsOneWidget);
      expect(find.text('Send 4-Digit Login Code'), findsOneWidget);

      // Enter 10-digit phone number
      final phoneField = find.byType(TextField);
      expect(phoneField, findsOneWidget);
      await tester.enterText(phoneField, '9876543210');
      await tester.pump();

      // Tap "Send 4-Digit Login Code"
      await tester.ensureVisible(find.text('Send 4-Digit Login Code'));
      await tester.tap(find.text('Send 4-Digit Login Code'));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify OTP screen step is now visible
      expect(find.text('Enter 4-Digit Code'), findsOneWidget);
      expect(find.text('Verify & Sign In'), findsOneWidget);
      expect(find.text('Auto-Fill'), findsOneWidget);

      // Tap demo auto-fill button
      await tester.ensureVisible(find.text('Auto-Fill'));
      await tester.tap(find.text('Auto-Fill'));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Verify & Sign In
      await tester.ensureVisible(find.text('Verify & Sign In'));
      await tester.tap(find.text('Verify & Sign In'));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify user service updated state
      expect(userService.profile.isLoggedIn, isTrue);
      expect(userService.profile.maskedPhone, contains('3210'));
    });
  });

  group('VideoUploadScreen Guide Mode Tests', () {
    testWidgets('renders guide video upload controls and anti-fake certification', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final videoService = CommunityVideoService();
      final userService = UserService();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CommunityVideoService>.value(value: videoService),
            ChangeNotifierProvider<UserService>.value(value: userService),
          ],
          child: const MaterialApp(
            home: VideoUploadScreen(),
          ),
        ),
      );

      // Verify guide upload UI elements
      expect(find.text('Upload a Safe Guide Video'), findsOneWidget);
      expect(find.text('Community Anti-Fake Video Shield'), findsOneWidget);
      expect(find.text('Step 1: Guide Category & Type'), findsOneWidget);
      expect(find.text('Record'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Authenticity & Anti-Fake Pledge'), findsOneWidget);

      // Verify anti-fake certification checkbox is present
      expect(
        find.textContaining('I certify this is an authentic, genuine educational guide'),
        findsOneWidget,
      );
    });
  });

  group('VoiceChatScreen Audio & Recording Tests', () {
    testWidgets('renders voice chat messages, triggers recording, preview, and play', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final voiceService = VoiceGroupService();
      final userService = UserService();
      final modService = ModerationService();
      final testGroup = voiceService.groups.first;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<VoiceGroupService>.value(value: voiceService),
            ChangeNotifierProvider<UserService>.value(value: userService),
            ChangeNotifierProvider<ModerationService>.value(value: modService),
          ],
          child: MaterialApp(
            home: VoiceChatScreen(group: testGroup),
          ),
        ),
      );

      // Verify group info and initial messages
      expect(find.text(testGroup.name), findsOneWidget);
      expect(find.text('Hold to Record Voice Message'), findsOneWidget);

      // Verify seed messages rendered
      expect(find.text('Mary Higgins'), findsOneWidget);

      // Tap play on Mary's message
      final playButtons = find.byIcon(Icons.play_arrow);
      expect(playButtons, findsWidgets);
      await tester.tap(playButtons.first);
      await tester.pump();

      // Verify audio state updated to playing
      expect(voiceService.isPlayingAudio, isTrue);

      // Tap recording button
      await tester.tap(find.text('Hold to Record Voice Message'));
      await tester.pump(const Duration(milliseconds: 100));

      // Stop recording by tapping again
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();

      // Verify preview card appears with "Hear Recording" and "Send Message"
      expect(find.text('Hear Recording'), findsOneWidget);
      expect(find.text('Send Message'), findsOneWidget);

      // Tap "Send Message"
      await tester.tap(find.text('Send Message'));
      await tester.pumpAndSettle();

      // Verify message was added to group
      final updatedMsgs = voiceService.getMessagesForGroup(testGroup.id);
      expect(updatedMsgs.last.senderId, userService.profile.id);
    });

    testWidgets('allows recording and sending simulated voice notes via Senior Voice Studio', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final voiceService = VoiceGroupService();
      final userService = UserService();
      final modService = ModerationService();
      final testGroup = voiceService.groups.first;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<VoiceGroupService>.value(value: voiceService),
            ChangeNotifierProvider<UserService>.value(value: userService),
            ChangeNotifierProvider<ModerationService>.value(value: modService),
          ],
          child: MaterialApp(
            home: VoiceChatScreen(group: testGroup),
          ),
        ),
      );

      // Tap Voice Studio button
      expect(find.text('No microphone? Tap to use Senior Voice Studio'), findsOneWidget);
      await tester.tap(find.text('No microphone? Tap to use Senior Voice Studio'));
      await tester.pumpAndSettle();

      // Verify Voice Studio dialog appears
      expect(find.text('Senior Voice Studio'), findsOneWidget);
      expect(find.text('Create Voice Note'), findsOneWidget);

      // Tap Create Voice Note
      await tester.tap(find.text('Create Voice Note'));
      await tester.pumpAndSettle();

      // Verify preview card appears
      expect(find.text('Hear Recording'), findsOneWidget);
      expect(find.text('Send Message'), findsOneWidget);

      // Tap Send Message
      await tester.tap(find.text('Send Message'), warnIfMissed: false);
      await tester.pumpAndSettle();

      final updatedMsgs = voiceService.getMessagesForGroup(testGroup.id);
      expect(updatedMsgs.last.senderId, userService.profile.id);
    });
  });

  group('VideosScreen and Running Video Player Engine Tests', () {
    testWidgets('opens video modal, renders live running player with subtitles and controls', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final videoService = CommunityVideoService();
      final userService = UserService();
      final locService = LocalizationService();
      final modService = ModerationService();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CommunityVideoService>.value(value: videoService),
            ChangeNotifierProvider<UserService>.value(value: userService),
            ChangeNotifierProvider<LocalizationService>.value(value: locService),
            ChangeNotifierProvider<ModerationService>.value(value: modService),
          ],
          child: const MaterialApp(
            home: VideosScreen(),
          ),
        ),
      );

      // Verify VideosScreen loaded
      expect(find.text('How to Make a WhatsApp Video Call'), findsOneWidget);

      // Tap on the first video to open running video player modal
      await tester.tap(find.text('How to Make a WhatsApp Video Call'));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify modal opened with running video engine
      expect(find.text('PLAYING'), findsOneWidget);
      expect(find.text('Step 1 of 4'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Replay'), findsOneWidget);

      // Tap Pause
      await tester.tap(find.text('Pause'));
      await tester.pump(const Duration(milliseconds: 200));

      // Status changes to PAUSED and button label to Play
      expect(find.text('PAUSED'), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);

      // Tap Play to resume
      await tester.tap(find.text('Play'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('PLAYING'), findsOneWidget);

      // Tap Replay
      await tester.tap(find.text('Replay'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('PLAYING'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Modal closed, back on VideosScreen
      expect(find.text('How to Make a WhatsApp Video Call'), findsOneWidget);
    });
  });
}
