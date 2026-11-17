import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../design_system.dart';
import '../models/lesson.dart';
import '../services/learning_service.dart';
import '../services/saved_lessons_service.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final saved = Provider.of<SavedLessonsService>(context, listen: false);
      final savedStep = saved.getSavedStep(widget.lesson.id);
      if (savedStep > 0 && savedStep < widget.lesson.steps.length) {
        setState(() => _currentIndex = savedStep);
      }
    });
  }

  void _onStepChange(int newIndex) {
    setState(() => _currentIndex = newIndex);
    final saved = Provider.of<SavedLessonsService>(context, listen: false);
    final learning = Provider.of<LearningService>(context, listen: false);

    saved.saveStepProgress(widget.lesson.id, newIndex);
    if (newIndex == widget.lesson.steps.length - 1) {
      learning.markLessonCompleted(widget.lesson.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.lesson.steps;
    final saved = Provider.of<SavedLessonsService>(context);
    final isBookmarked = saved.isBookmarked(widget.lesson.id);

    final imageHeight = (MediaQuery.of(context).size.height * 0.3)
        .clamp(160.0, 280.0)
        .toDouble();
    if (steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.lesson.title)),
        body: const Center(
          child: Text(
            'No steps available for this lesson.',
            style: AppDesign.body,
          ),
        ),
      );
    }

    final step = steps[_currentIndex];
    final progress = (_currentIndex + 1) / steps.length;
    final isLastStep = _currentIndex == steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            tooltip: isBookmarked ? 'Remove Bookmark' : 'Save Lesson',
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.amber.shade300 : Colors.white,
              size: 28,
            ),
            onPressed: () {
              saved.toggleBookmark(widget.lesson.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isBookmarked ? 'Removed from saved lessons' : 'Saved to your lessons list!',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDesign.spaceMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step Indicator & Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Text(
                      'Step ${_currentIndex + 1} of ${steps.length}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}% Done',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              const SizedBox(height: AppDesign.spaceMedium),

              // Image & Instruction text area
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(AppDesign.spaceSmall),
                child: Column(
                  children: [
                    SizedBox(
                      height: imageHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          step.image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDesign.spaceSmall),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        step.text,
                        style: AppDesign.body.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDesign.spaceMedium),

              // Navigation Controls: Back, Repeat, Next
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _NavButton(
                    label: 'Back',
                    icon: Icons.arrow_back,
                    enabled: _currentIndex > 0,
                    onPressed: _currentIndex > 0
                        ? () => _onStepChange(_currentIndex - 1)
                        : null,
                  ),
                  _NavButton(
                    label: 'Repeat',
                    icon: Icons.replay,
                    onPressed: _repeatInstruction,
                  ),
                  _NavButton(
                    label: isLastStep ? 'Finished' : 'Next',
                    icon: isLastStep ? Icons.check : Icons.arrow_forward,
                    enabled: true,
                    onPressed: isLastStep
                        ? _showCompletionDialog
                        : () => _onStepChange(_currentIndex + 1),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Still Confused? & Practice Mode Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _showConfusedDialog,
                      icon: const Icon(Icons.help_outline, size: 24),
                      label: const Text(
                        'Still Confused?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PracticeScreen(lesson: widget.lesson),
                        ),
                      ),
                      icon: const Icon(Icons.sports_esports, size: 24),
                      label: const Text(
                        'Practice Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    final learning = Provider.of<LearningService>(context, listen: false);
    learning.markLessonCompleted(widget.lesson.id);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.celebration, color: Colors.green, size: 36),
            SizedBox(width: 10),
            Text('Lesson Completed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wonderful job! You have completed all steps of "${widget.lesson.title}".',
              style: const TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 12),
            const Text(
              'Would you like to try Practice Mode now to practice tapping the simulated screen?',
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back to Steps', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PracticeScreen(lesson: widget.lesson)),
              );
            },
            child: const Text('Practice Now', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showConfusedDialog() {
    final instruction = widget.lesson.steps[_currentIndex].text;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.support_agent, color: Colors.blue, size: 30),
            SizedBox(width: 10),
            Text('Let me help'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Take a breath. You are doing great! Here is what to do for this step in simpler words:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Text(
                '👉 $instruction',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You can also tap "Practice Mode" below to try selecting the step on your own without any worry of making mistakes.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  void _repeatInstruction() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.volume_up, color: Colors.blue, size: 28),
            SizedBox(width: 8),
            Text('Repeat Step'),
          ],
        ),
        content: Text(
          widget.lesson.steps[_currentIndex].text,
          style: AppDesign.body.copyWith(fontSize: 20),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool enabled;

  const _NavButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(100, 52),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
