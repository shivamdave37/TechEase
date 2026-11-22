import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../design_system.dart';
import '../models/task.dart';
import '../services/learning_service.dart';
import 'lesson_player_screen.dart';

class TaskScreen extends StatelessWidget {
  final Task task;
  const TaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final learning = Provider.of<LearningService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDesign.spaceMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.description,
                      style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDesign.spaceMedium),

              const Text(
                'Step-by-Step Lessons',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDesign.spaceSmall),

              Expanded(
                child: ListView.builder(
                  itemCount: task.lessons.isEmpty ? 1 : task.lessons.length,
                  itemBuilder: (context, i) {
                    if (task.lessons.isEmpty) {
                      return const Center(
                        child: Text(
                          'No lessons are available for this task yet.',
                          style: AppDesign.body,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final lesson = task.lessons[i];
                    final isCompleted = learning.isLessonCompleted(lesson.id);
                    final stepCount = lesson.steps.length;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.green.shade100 : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isCompleted ? Icons.check_circle : Icons.play_arrow_rounded,
                            color: isCompleted ? Colors.green.shade800 : Colors.blue.shade800,
                            size: 28,
                          ),
                        ),
                        title: Text(lesson.title, style: AppDesign.title.copyWith(fontSize: 18)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.description,
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$stepCount ${stepCount == 1 ? "Step" : "Steps"}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                  ),
                                  if (isCompleted) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '✓ Completed',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black45),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonPlayerScreen(lesson: lesson),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
