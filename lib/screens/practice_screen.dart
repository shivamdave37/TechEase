import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../design_system.dart';
import '../models/lesson.dart';
import '../services/analytics_service.dart';
import '../services/learning_service.dart';

/// A text-and-interactive practice simulation. It teaches the sequence safely without controlling another app.
class PracticeScreen extends StatefulWidget {
  final Lesson lesson;
  const PracticeScreen({Key? key, required this.lesson}) : super(key: key);

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _stepIndex = 0;
  String? _feedback;
  bool _complete = false;

  @override
  Widget build(BuildContext context) {
    final steps = widget.lesson.steps;
    return Scaffold(
      appBar: AppBar(title: Text('Practice: ${widget.lesson.title}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDesign.spaceMedium),
          child: steps.isEmpty
              ? const Center(
                  child: Text(
                    'There are no steps to practise yet.',
                    style: AppDesign.body,
                    textAlign: TextAlign.center,
                  ),
                )
              : _complete
              ? _completionView()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Practice step ${_stepIndex + 1} of ${steps.length}',
                      style: AppDesign.title,
                    ),
                    const SizedBox(height: AppDesign.spaceMedium),
                    const Text(
                      'What should you do now?',
                      style: AppDesign.body,
                    ),
                    const SizedBox(height: AppDesign.spaceMedium),
                    Expanded(
                      child: ListView(
                        children: [
                          for (var i = 0; i < steps.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppDesign.spaceSmall,
                              ),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 64),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(16),
                                ),
                                onPressed: () => _choose(i),
                                child: Text(
                                  steps[i].text,
                                  style: AppDesign.body,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_feedback != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDesign.spaceSmall,
                        ),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            _feedback!,
                            style: AppDesign.body.copyWith(
                              color: _feedback!.startsWith('Correct') ? Colors.green.shade800 : Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    const Text(
                      'This is a learning simulation. It does not open or control WhatsApp or any other app.',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _completionView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
            semanticLabel: 'Practice complete',
          ),
          const SizedBox(height: AppDesign.spaceMedium),
          const Text(
            'Practice complete!',
            style: AppDesign.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'You selected every step in the right order! You are ready to use this on your phone with confidence.',
            style: TextStyle(fontSize: 18, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesign.spaceLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => setState(() {
                  _stepIndex = 0;
                  _feedback = null;
                  _complete = false;
                }),
                child: const Text('Practise again'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(context),
                child: const Text('Finish Practice'),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  void _choose(int selectedIndex) {
    if (selectedIndex != _stepIndex) {
      setState(
        () => _feedback = 'That is a different step. Try again, or review the lesson for help.',
      );
      return;
    }
    setState(() {
      _feedback = 'Correct. ${widget.lesson.steps[_stepIndex].text}';
      if (_stepIndex == widget.lesson.steps.length - 1) {
        _complete = true;
        // Mark completed in learning and analytics
        try {
          final learning = Provider.of<LearningService>(context, listen: false);
          final analytics = Provider.of<AnalyticsService>(context, listen: false);
          learning.markLessonCompleted(widget.lesson.id);
          analytics.logEvent('practice_completed', {'lessonId': widget.lesson.id});
        } catch (_) {}
      } else {
        _stepIndex++;
      }
    });
  }
}
