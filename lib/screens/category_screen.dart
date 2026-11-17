import 'package:flutter/material.dart';
import '../design_system.dart';
import '../models/category.dart';
import 'task_screen.dart';

class CategoryScreen extends StatelessWidget {
  final Category category;
  const CategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: Padding(
        padding: const EdgeInsets.all(AppDesign.spaceMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.description, style: AppDesign.body),
            const SizedBox(height: AppDesign.spaceMedium),
            Expanded(
              child: ListView.builder(
                  itemCount: category.tasks.isEmpty ? 1 : category.tasks.length,
                itemBuilder: (context, i) {
                  if (category.tasks.isEmpty) return const Center(child: Text('No tasks are available in this category yet.', style: AppDesign.body, textAlign: TextAlign.center));
                  final task = category.tasks[i];
                  return Card(
                    child: ListTile(
                      title: Text(task.title, style: AppDesign.title),
                      subtitle: Text(task.description, style: AppDesign.body),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TaskScreen(task: task)),
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
