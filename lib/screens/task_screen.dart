import 'package:flutter/material.dart';
import '../design_system.dart';
import '../models/task.dart';
import 'lesson_player_screen.dart';

class TaskScreen extends StatelessWidget {
  final Task task;
  const TaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(task.title)),
      body: Padding(
        padding: const EdgeInsets.all(AppDesign.spaceMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description, style: AppDesign.body),
            const SizedBox(height: AppDesign.spaceMedium),
            Expanded(
              child: ListView.builder(
                  itemCount: task.lessons.isEmpty ? 1 : task.lessons.length,
                itemBuilder: (context, i) {
                  if (task.lessons.isEmpty) return const Center(child: Text('No lessons are available for this task yet.', style: AppDesign.body, textAlign: TextAlign.center));
                  final lesson = task.lessons[i];
                  return Card(
                    child: ListTile(
                      title: Text(lesson.title, style: AppDesign.title),
                      subtitle: Text(lesson.description, style: AppDesign.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LessonPlayerScreen(lesson: lesson)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
