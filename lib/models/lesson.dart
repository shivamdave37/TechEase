import 'lesson_step.dart';

class Lesson {
  final String id;
  final String title;
  final String description;
  final List<LessonStep> steps;

  Lesson({required this.id, required this.title, required this.description, required this.steps});

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final stepsJson = json['steps'] as List<dynamic>? ?? const [];
    List<LessonStep> stepList = stepsJson.map((e) => LessonStep.fromJson(e)).toList();
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      steps: stepList,
    );
  }
}
