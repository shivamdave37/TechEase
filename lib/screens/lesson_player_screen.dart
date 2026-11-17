import 'package:flutter/material.dart';
import '../design_system.dart';
import '../models/lesson.dart';
import 'practice_screen.dart';

class LessonPlayerScreen extends StatefulWidget {
  final Lesson lesson;
  const LessonPlayerScreen({Key? key, required this.lesson}) : super(key: key);

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final steps = widget.lesson.steps;
    if (steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.lesson.title)),
        body: const Center(child: Text('No steps available.')),
      );
    }
    final step = steps[_currentIndex];
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: Padding(
        padding: const EdgeInsets.all(AppDesign.spaceMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Image.asset(step.image, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 120)),
                  ),
                  const SizedBox(height: AppDesign.spaceSmall),
                  Text(step.text, style: AppDesign.body.copyWith(fontSize: 22), textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: AppDesign.spaceMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavButton(label: 'Back', enabled: _currentIndex > 0, onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null),
                _NavButton(label: 'Repeat', onPressed: _repeatInstruction),
                _NavButton(label: 'Next', enabled: _currentIndex < steps.length - 1, onPressed: _currentIndex < steps.length - 1 ? () => setState(() => _currentIndex++) : null),
              ],
            ),
            const SizedBox(height: AppDesign.spaceSmall),
            ElevatedButton(
              onPressed: _showConfusedDialog,
              child: const Text('Still Confused?'),
            ),
            const SizedBox(height: AppDesign.spaceSmall),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PracticeScreen(lesson: widget.lesson))),
              child: const Text('Practice Mode'),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfusedDialog() {
    final instruction = widget.lesson.steps[_currentIndex].text;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Let me help'),
        content: Text('Try this one small action:\n\n$instruction', style: AppDesign.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _repeatInstruction() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Current step'),
        content: Text(widget.lesson.steps[_currentIndex].text, style: AppDesign.body),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  const _NavButton({required this.label, this.onPressed, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(minimumSize: const Size(88, AppDesign.minTouchTarget), padding: const EdgeInsets.symmetric(horizontal: 12)),
      child: Text(label, style: AppDesign.button),
    );
  }
}
