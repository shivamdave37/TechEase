import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../design_system.dart';
import '../models/lesson.dart';
import '../services/analytics_service.dart';
import '../services/learning_service.dart';
import '../services/user_service.dart';

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
  bool _showHint = false;

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
                    // Header with Progress & Step Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Practice step ${_stepIndex + 1} of ${steps.length}',
                          style: AppDesign.title,
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() => _showHint = !_showHint),
                          icon: const Icon(Icons.lightbulb_outline, size: 18),
                          label: Text(_showHint ? 'Hide Hint' : 'Need Hint?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_stepIndex + 1) / steps.length,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                    const SizedBox(height: AppDesign.spaceMedium),

                    // Smartphone Mock Simulation Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Icon(
                              Icons.phone_android,
                              color: Colors.blue,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Risk-Free Sandbox',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _showHint
                                      ? '💡 Hint: Look for what you should do next in step ${_stepIndex + 1}.'
                                      : 'Tap the correct next action from the list below. Unlimited retries!',
                                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDesign.spaceMedium),

                    const Text(
                      'What should you do now?',
                      style: AppDesign.body,
                    ),
                    const SizedBox(height: AppDesign.spaceMedium),

                    // Choice List
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(
                                    color: _feedback != null && _feedback!.startsWith('Correct') && i == _stepIndex - 1
                                        ? Colors.green.shade600
                                        : Colors.grey.shade400,
                                    width: 1.5,
                                  ),
                                ),
                                onPressed: () => _choose(i),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Text(
                                        '${i + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        steps[i].text,
                                        style: AppDesign.body.copyWith(fontSize: 18),
                                      ),
                                    ),
                                  ],
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
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _feedback!.startsWith('Correct') ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _feedback!.startsWith('Correct') ? Colors.green.shade400 : Colors.red.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _feedback!.startsWith('Correct') ? Icons.check_circle : Icons.info,
                                  color: _feedback!.startsWith('Correct') ? Colors.green.shade800 : Colors.red.shade800,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _feedback!,
                                    style: AppDesign.body.copyWith(
                                      color: _feedback!.startsWith('Correct') ? Colors.green.shade800 : Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
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
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
                semanticLabel: 'Practice complete',
              ),
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
            const SizedBox(height: 14),

            // Achievement Badge Awarded Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade400, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🏅', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Practice Explorer Badge Earned!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown),
                      ),
                      Text(
                        'Added to your Profile achievements',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDesign.spaceLarge),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => setState(() {
                    _stepIndex = 0;
                    _feedback = null;
                    _complete = false;
                    _showHint = false;
                  }),
                  child: const Text('Practise again'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Finish Practice'),
                ),
              ],
            ),
          ],
        ),
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
          final user = Provider.of<UserService>(context, listen: false);

          learning.markLessonCompleted(widget.lesson.id);
          user.addBadge('practice_master');
          analytics.logEvent('practice_completed', {'lessonId': widget.lesson.id});
        } catch (_) {}
      } else {
        _stepIndex++;
      }
    });
  }
}
