import 'lesson.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final List<Lesson> lessons;

  Task({required this.id, required this.title, required this.description, required this.lessons});

  factory Task.fromJson(Map<String, dynamic> json) {
    var lessonsJson = json['lessons'] as List<dynamic>? ?? [];
    List<Lesson> lessonList = lessonsJson.map((e) => Lesson.fromJson(e)).toList();
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      lessons: lessonList,
    );
  }
}
