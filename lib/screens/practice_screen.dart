import 'package:flutter/material.dart';

import '../design_system.dart';
import '../models/lesson.dart';

/// A text-only practice exercise. It teaches the sequence but never opens or
/// controls another app.
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
              ? const Center(child: Text('There are no steps to practise yet.', style: AppDesign.body, textAlign: TextAlign.center))
              : _complete
                  ? _completionView()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Practice step ${_stepIndex + 1} of ${steps.length}', style: AppDesign.title),
                        const SizedBox(height: AppDesign.spaceMedium),
                        const Text('What should you do now?', style: AppDesign.body),
                        const SizedBox(height: AppDesign.spaceMedium),
                        Expanded(
                          child: ListView(
                            children: [
                              for (var i = 0; i < steps.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: AppDesign.spaceSmall),
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 64), alignment: Alignment.centerLeft, padding: const EdgeInsets.all(16)),
                                    onPressed: () => _choose(i),
                                    child: Text(steps[i].text, style: AppDesign.body),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_feedback != null)
                          Padding(padding: const EdgeInsets.symmetric(vertical: AppDesign.spaceSmall), child: Semantics(liveRegion: true, child: Text(_feedback!, style: AppDesign.body))),
                        const Text('This is a practice activity. It does not open or control WhatsApp or any other app.', style: TextStyle(fontSize: 16, color: Colors.black87)),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _completionView() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle, size: 72, color: Colors.green, semanticLabel: 'Practice complete'),
          const SizedBox(height: AppDesign.spaceMedium),
          const Text('Practice complete!', style: AppDesign.headline, textAlign: TextAlign.center),
          const SizedBox(height: AppDesign.spaceMedium),
          ElevatedButton(onPressed: () => setState(() { _stepIndex = 0; _feedback = null; _complete = false; }), child: const Text('Practise again')),
        ]),
      );

  void _choose(int selectedIndex) {
    if (selectedIndex != _stepIndex) {
      setState(() => _feedback = 'That is a different step. Try again, or review the lesson for help.');
      return;
    }
    setState(() {
      _feedback = 'Correct. ${widget.lesson.steps[_stepIndex].text}';
      if (_stepIndex == widget.lesson.steps.length - 1) {
        _complete = true;
      } else {
        _stepIndex++;
      }
    });
  }
}
