import 'task.dart';

class Category {
  final String id;
  final String title;
  final String description;
  final String imageAsset; // path to illustration asset
  final List<Task> tasks;

  Category({
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.tasks,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final tasksJson = json['tasks'] as List<dynamic>? ?? const [];
    List<Task> taskList = tasksJson.map((e) => Task.fromJson(e)).toList();
    return Category(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageAsset: json['imageAsset'] as String,
      tasks: taskList,
    );
  }
}
