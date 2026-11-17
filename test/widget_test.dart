import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elder_smartphone_learning_app/app.dart';
import 'package:elder_smartphone_learning_app/models/category.dart';
import 'package:elder_smartphone_learning_app/models/lesson.dart';
import 'package:elder_smartphone_learning_app/models/lesson_step.dart';
import 'package:elder_smartphone_learning_app/models/task.dart';
import 'package:elder_smartphone_learning_app/screens/category_screen.dart';
import 'package:elder_smartphone_learning_app/screens/task_screen.dart';
import 'package:elder_smartphone_learning_app/screens/lesson_player_screen.dart';
import 'package:elder_smartphone_learning_app/screens/practice_screen.dart';

void main() {
  testWidgets('ElderApp smoke test - renders welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ElderApp());
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Learn how to use your smartphone'), findsOneWidget);
  });

  testWidgets('Complete End-to-End Learning Journey: Category -> Task -> Lesson -> Practice', (WidgetTester tester) async {
    // 1. Build root category
    final lesson = Lesson(
      id: 'lesson1',
      title: 'Open WhatsApp and Send Message',
      description: 'Step-by-step messaging guide',
      steps: [
        LessonStep(order: 1, text: 'Tap green WhatsApp icon.', image: 'assets/images/whatsapp_step1.png'),
        LessonStep(order: 2, text: 'Tap chat button.', image: 'assets/images/whatsapp_step2.png'),
      ],
    );

    final task = Task(
      id: 'task1',
      title: 'Send a WhatsApp Message',
      description: 'Learn to send a text message',
      lessons: [lesson],
    );

    final category = Category(
      id: 'cat1',
      title: 'WhatsApp',
      description: 'Messaging app for family',
      imageAsset: 'assets/images/whatsapp.png',
      tasks: [task],
    );

    // 2. Start at Category Screen
    await tester.pumpWidget(MaterialApp(home: CategoryScreen(category: category)));
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Send a WhatsApp Message'), findsOneWidget);

    // 3. Tap Task -> Navigates to TaskScreen
    await tester.tap(find.text('Send a WhatsApp Message'));
    await tester.pumpAndSettle();
    expect(find.text('Open WhatsApp and Send Message'), findsOneWidget);

    // 4. Tap Lesson -> Navigates to LessonPlayerScreen
    await tester.tap(find.text('Open WhatsApp and Send Message'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 2'), findsOneWidget);
    expect(find.text('Tap green WhatsApp icon.'), findsOneWidget);

    // 5. Test Navigation inside Lesson: Next button
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 2'), findsOneWidget);
    expect(find.text('Tap chat button.'), findsOneWidget);

    // 6. Test Still Confused button
    await tester.tap(find.text('Still Confused?'));
    await tester.pumpAndSettle();
    expect(find.text('Let me help'), findsOneWidget);
    await tester.tap(find.text('I Understand'));
    await tester.pumpAndSettle();

    // 7. Tap Practice Mode -> Navigates to PracticeScreen
    await tester.tap(find.text('Practice Mode'));
    await tester.pumpAndSettle();
    expect(find.text('Practice step 1 of 2'), findsOneWidget);

    // 8. Interactive simulation: wrong choice
    await tester.tap(find.text('Tap chat button.'));
    await tester.pumpAndSettle();
    expect(find.text('That is a different step. Try again, or review the lesson for help.'), findsOneWidget);

    // 9. Interactive simulation: correct choice 1
    await tester.tap(find.text('Tap green WhatsApp icon.'));
    await tester.pumpAndSettle();
    expect(find.text('Correct. Tap green WhatsApp icon.'), findsOneWidget);

    // 10. Interactive simulation: correct choice 2 (completes)
    await tester.tap(find.text('Tap chat button.'));
    await tester.pumpAndSettle();
    expect(find.text('Practice complete!'), findsOneWidget);

    // 11. Retry practice
    await tester.tap(find.text('Practise again'));
    await tester.pumpAndSettle();
    expect(find.text('Practice step 1 of 2'), findsOneWidget);
  });
}
