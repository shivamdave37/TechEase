import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elder_smartphone_learning_app/app.dart';

void main() {
  testWidgets(
    'Complete End-to-End Learning Journey: Category -> Task -> Lesson -> Practice',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Start at the app's real home screen and load bundled category data.
      await tester.pumpWidget(const ElderApp());
      await pumpUntilCategoriesLoad(tester);
      expect(find.text('Learn how to use your smartphone'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);

      // Home -> category -> task -> lesson.
      await tester.tap(find.text('WhatsApp'));
      await tester.pumpAndSettle();
      expect(find.text('Send a WhatsApp Message'), findsOneWidget);

      await tester.tap(find.text('Send a WhatsApp Message'));
      await tester.pumpAndSettle();
      expect(find.text('Open WhatsApp and Send Message'), findsOneWidget);

      await tester.tap(find.text('Open WhatsApp and Send Message'));
      await tester.pumpAndSettle();
      expect(find.text('Step 1 of 5'), findsOneWidget);
      expect(
        find.text("Tap the green WhatsApp icon on your phone's home screen."),
        findsOneWidget,
      );

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Step 2 of 5'), findsOneWidget);
      expect(
        find.text('Tap the green chat button in the bottom right corner.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Step 1 of 5'), findsOneWidget);

      await tester.tap(find.text('Repeat'));
      await tester.pumpAndSettle();
      expect(find.text('Repeat Step'), findsOneWidget);
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Still Confused?'));
      await tester.pumpAndSettle();
      expect(find.text('Let me help'), findsOneWidget);
      await tester.tap(find.text('I Understand'));
      await tester.pumpAndSettle();

      // Practice the actual lesson sequence, including a wrong answer and retry.
      await tester.tap(find.text('Practice Mode'));
      await tester.pumpAndSettle();
      expect(find.text('Practice step 1 of 5'), findsOneWidget);

      await tester.ensureVisible(
        find.text('Tap the green chat button in the bottom right corner.'),
      );
      await tester.tap(
        find.text('Tap the green chat button in the bottom right corner.'),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          'That is a different step. Try again, or review the lesson for help.',
        ),
        findsOneWidget,
      );

      await tester.drag(find.byType(ListView), const Offset(0, 800));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.text("Tap the green WhatsApp icon on your phone's home screen."),
      );
      await tester.tap(
        find.text("Tap the green WhatsApp icon on your phone's home screen."),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Correct. Tap the green WhatsApp icon'),
        findsOneWidget,
      );

      await tester.ensureVisible(
        find.text('Tap the green chat button in the bottom right corner.'),
      );
      await tester.tap(
        find.text('Tap the green chat button in the bottom right corner.'),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.text('Find and tap the name of the person you want to message.'),
      );
      await tester.tap(
        find.text('Find and tap the name of the person you want to message.'),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.text('Tap the message box at the bottom and type your words.'),
      );
      await tester.tap(
        find.text('Tap the message box at the bottom and type your words.'),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.text('Tap the green paper-plane button on the right to send.'),
      );
      await tester.tap(
        find.text('Tap the green paper-plane button on the right to send.'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Practice complete!'), findsOneWidget);

      await tester.tap(find.text('Practise again'));
      await tester.pumpAndSettle();
      expect(find.text('Practice step 1 of 5'), findsOneWidget);
    },
  );
}

Future<void> pumpUntilCategoriesLoad(WidgetTester tester) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    // Asset reads use real async I/O and the loading indicator keeps animating.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    if (find.text('WhatsApp').evaluate().isNotEmpty) return;
  }
  fail('The home screen did not load the bundled WhatsApp category.');
}
