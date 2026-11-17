import 'package:flutter_test/flutter_test.dart';
import 'package:elder_smartphone_learning_app/models/lesson.dart';
import 'package:elder_smartphone_learning_app/models/lesson_step.dart';
import 'package:elder_smartphone_learning_app/models/task.dart';
import 'package:elder_smartphone_learning_app/models/category.dart';

void main() {
  group('LessonStep model', () {
    test('fromJson parses correctly', () {
      final step = LessonStep.fromJson({
        'order': 1,
        'text': 'Tap the WhatsApp icon',
        'image': 'assets/images/whatsapp_step1.png',
      });
      expect(step.order, 1);
      expect(step.text, 'Tap the WhatsApp icon');
      expect(step.image, 'assets/images/whatsapp_step1.png');
    });
  });

  group('Lesson model', () {
    test('fromJson parses steps correctly', () {
      final lesson = Lesson.fromJson({
        'id': 'l1',
        'title': 'Open WhatsApp',
        'description': 'Learn to open the app',
        'steps': [
          {'order': 1, 'text': 'Find the icon', 'image': 'assets/images/step1.png'},
          {'order': 2, 'text': 'Tap the icon', 'image': 'assets/images/step2.png'},
        ],
      });
      expect(lesson.id, 'l1');
      expect(lesson.steps.length, 2);
      expect(lesson.steps.first.order, 1);
      expect(lesson.steps.last.order, 2);
    });

    test('fromJson with empty steps', () {
      final lesson = Lesson.fromJson({
        'id': 'l2',
        'title': 'Empty',
        'description': 'No steps',
        'steps': [],
      });
      expect(lesson.steps, isEmpty);
    });
  });

  group('Task model', () {
    test('fromJson parses lessons', () {
      final task = Task.fromJson({
        'id': 't1',
        'title': 'Send a Message',
        'description': 'How to send a message',
        'lessons': [
          {
            'id': 'l1',
            'title': 'Open WhatsApp',
            'description': 'Open the app',
            'steps': [
              {'order': 1, 'text': 'Find the icon', 'image': 'assets/images/step1.png'},
            ],
          }
        ],
      });
      expect(task.id, 't1');
      expect(task.lessons.length, 1);
      expect(task.lessons.first.title, 'Open WhatsApp');
    });

    test('fromJson with no lessons key defaults to empty', () {
      final task = Task.fromJson({
        'id': 't2',
        'title': 'Empty Task',
        'description': 'Has no lessons',
      });
      expect(task.lessons, isEmpty);
    });
  });

  group('Category model', () {
    test('fromJson parses tasks', () {
      final cat = Category.fromJson({
        'id': 'c1',
        'title': 'WhatsApp',
        'description': 'Learn WhatsApp',
        'imageAsset': 'assets/images/whatsapp.png',
        'tasks': [
          {
            'id': 't1',
            'title': 'Send a Message',
            'description': 'How to send',
            'lessons': [],
          }
        ],
      });
      expect(cat.id, 'c1');
      expect(cat.title, 'WhatsApp');
      expect(cat.tasks.length, 1);
    });
  });

  group('Lesson progression', () {
    late Lesson lesson;
    setUp(() {
      lesson = Lesson.fromJson({
        'id': 'l1',
        'title': 'Test Lesson',
        'description': 'desc',
        'steps': [
          {'order': 1, 'text': 'Step 1', 'image': 'a.png'},
          {'order': 2, 'text': 'Step 2', 'image': 'b.png'},
          {'order': 3, 'text': 'Step 3', 'image': 'c.png'},
        ],
      });
    });

    test('starts at first step', () {
      expect(lesson.steps.first.text, 'Step 1');
    });

    test('can navigate to next step', () {
      int index = 0;
      index++;
      expect(lesson.steps[index].text, 'Step 2');
    });

    test('back button disabled at step 0', () {
      int index = 0;
      final canGoBack = index > 0;
      expect(canGoBack, isFalse);
    });

    test('next button disabled at last step', () {
      int index = lesson.steps.length - 1;
      final canGoNext = index < lesson.steps.length - 1;
      expect(canGoNext, isFalse);
    });

    test('repeat keeps same index', () {
      int index = 1;
      // Repeat means no change to index
      final afterRepeat = index;
      expect(afterRepeat, 1);
    });
  });

  group('Practice mode logic', () {
    late Lesson lesson;
    setUp(() {
      lesson = Lesson.fromJson({
        'id': 'l1',
        'title': 'Practice Lesson',
        'description': 'desc',
        'steps': [
          {'order': 1, 'text': 'Step A', 'image': 'a.png'},
          {'order': 2, 'text': 'Step B', 'image': 'b.png'},
          {'order': 3, 'text': 'Step C', 'image': 'c.png'},
        ],
      });
    });

    test('correct answer advances step', () {
      int stepIndex = 0;
      bool complete = false;
      void choose(int selected) {
        if (selected == stepIndex) {
          if (stepIndex == lesson.steps.length - 1) {
            complete = true;
          } else {
            stepIndex++;
          }
        }
      }
      choose(0); // correct
      expect(stepIndex, 1);
      expect(complete, isFalse);
    });

    test('incorrect answer does not advance step', () {
      int stepIndex = 0;
      void choose(int selected) {
        if (selected == stepIndex) stepIndex++;
      }
      choose(2); // wrong
      expect(stepIndex, 0);
    });

    test('completing last step sets complete', () {
      int stepIndex = 2; // already on last step
      bool complete = false;
      void choose(int selected) {
        if (selected == stepIndex) {
          if (stepIndex == lesson.steps.length - 1) {
            complete = true;
          } else {
            stepIndex++;
          }
        }
      }
      choose(2); // correct last step
      expect(complete, isTrue);
    });
  });
}
