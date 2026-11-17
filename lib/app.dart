import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'screens/main_navigation_shell.dart';
import 'services/accessibility_service.dart';
import 'services/analytics_service.dart';
import 'services/community_video_service.dart';
import 'services/learning_service.dart';
import 'services/localization_service.dart';
import 'services/moderation_service.dart';
import 'services/saved_lessons_service.dart';
import 'services/search_service.dart';
import 'services/user_service.dart';
import 'services/voice_group_service.dart';

class ElderApp extends StatelessWidget {
  const ElderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccessibilityService()),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
        ChangeNotifierProvider(create: (_) => UserService()),
        ChangeNotifierProvider(create: (_) => LearningService()),
        ChangeNotifierProvider(create: (_) => SavedLessonsService()),
        ChangeNotifierProvider(create: (_) => SearchService()),
        ChangeNotifierProvider(create: (_) => CommunityVideoService()),
        ChangeNotifierProvider(create: (_) => VoiceGroupService()),
        ChangeNotifierProvider(create: (_) => ModerationService()),
        ChangeNotifierProvider(create: (_) => AnalyticsService()),
      ],
      child: Consumer2<AccessibilityService, LocalizationService>(
        builder: (context, accessibility, localization, _) {
          return MaterialApp(
            title: localization.tr('app_title'),
            debugShowCheckedModeBanner: false,
            theme: accessibility.themeData,
            home: const MainNavigationShell(),
          );
        },
      ),
    );
  }
}
