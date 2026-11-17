import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:elder_smartphone_learning_app/app.dart';
import 'package:elder_smartphone_learning_app/screens/main_navigation_shell.dart';
import 'package:elder_smartphone_learning_app/screens/learn/learn_home_view.dart';
import 'package:elder_smartphone_learning_app/screens/saved_and_search/saved_search_screen.dart';
import 'package:elder_smartphone_learning_app/screens/videos/videos_screen.dart';
import 'package:elder_smartphone_learning_app/screens/voice_groups/voice_groups_screen.dart';
import 'package:elder_smartphone_learning_app/screens/profile/profile_screen.dart';

void main() {
  testWidgets('ElderApp smoke test - renders MainNavigationShell with 5 destinations', (WidgetTester tester) async {
    await tester.pumpWidget(const ElderApp());
    await tester.pumpAndSettle();

    // Verify MainNavigationShell is active
    expect(find.byType(MainNavigationShell), findsOneWidget);

    // Verify all 5 tab destinations are visible in the navigation bar
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Saved & Search'), findsOneWidget);
    expect(find.text('Videos'), findsOneWidget);
    expect(find.text('Voice Groups'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Initial tab is Learn
    expect(find.byType(LearnHomeView), findsOneWidget);
  });

  testWidgets('Navigation Shell switches smoothly between all 5 modules', (WidgetTester tester) async {
    await tester.pumpWidget(const ElderApp());
    await tester.pumpAndSettle();

    // 1. Switch to Saved & Search (Tab 1)
    await tester.tap(find.text('Saved & Search'));
    await tester.pumpAndSettle();
    expect(find.byType(SavedSearchScreen), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // 2. Switch to Community Videos (Tab 2)
    await tester.tap(find.text('Videos'));
    await tester.pumpAndSettle();
    expect(find.byType(VideosScreen), findsOneWidget);
    expect(find.text('Share a Video'), findsOneWidget);

    // 3. Switch to Voice Groups (Tab 3)
    await tester.tap(find.text('Voice Groups'));
    await tester.pumpAndSettle();
    expect(find.byType(VoiceGroupsScreen), findsOneWidget);
    expect(find.text('Create New Group'), findsOneWidget);

    // 4. Switch to Profile & Accessibility (Tab 4)
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Accessibility & View Settings'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Language / भाषा / Idioma'), 300);
    expect(find.text('Language / भाषा / Idioma'), findsOneWidget);

    // 5. Switch back to Learn (Tab 0)
    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();
    expect(find.byType(LearnHomeView), findsOneWidget);
  });

  testWidgets('Saved & Search tab supports text search and filtering', (WidgetTester tester) async {
    await tester.pumpWidget(const ElderApp());
    await tester.pumpAndSettle();

    // Navigate to Saved & Search
    await tester.tap(find.text('Saved & Search'));
    await tester.pumpAndSettle();

    // Type query into search bar
    await tester.enterText(find.byType(TextField), 'WhatsApp');
    await tester.pumpAndSettle();

    // Should find WhatsApp lesson
    expect(find.text('WhatsApp'), findsWidgets);
  });

  testWidgets('Responsive Layout - verifies tablet width does not crash or overflow', (WidgetTester tester) async {
    // Set viewport to tablet size (800 x 1280)
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ElderApp());
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigationShell), findsOneWidget);
    expect(find.byType(LearnHomeView), findsOneWidget);
  });
}
