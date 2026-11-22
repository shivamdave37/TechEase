import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../design_system.dart';
import '../../models/category.dart';
import '../../services/learning_service.dart';
import '../../services/localization_service.dart';
import '../../services/saved_lessons_service.dart';
import '../../services/user_service.dart';
import '../category_screen.dart';
import '../lesson_player_screen.dart';
import '../share/share_to_phone_dialog.dart';
import 'glossary_screen.dart';

class LearnHomeView extends StatelessWidget {
  const LearnHomeView({Key? key}) : super(key: key);

  void _showFamilyHelpDialog(BuildContext context, UserService user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.family_restroom, color: Colors.red.shade800, size: 28),
            ),
            const SizedBox(width: 10),
            const Text('Ask Family for Help', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Never worry if you get stuck! Your trusted helper is ready to assist you:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.blue, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.profile.familyContactName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        Text(
                          user.profile.familyContactPhone,
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'A pre-written help message will be prepared for WhatsApp so you do not have to type.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.chat),
            label: const Text('Send Help Message', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green.shade800,
                  content: Text(
                    'Help request sent to ${user.profile.familyContactName}! They will check in soon.',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final learning = Provider.of<LearningService>(context);
    final saved = Provider.of<SavedLessonsService>(context);
    final user = Provider.of<UserService>(context);
    final loc = Provider.of<LocalizationService>(context);

    final unfinishedLesson = saved.getLastUnfinishedLesson(learning);

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final crossAxisCount = isTablet ? 3 : 2;
    final childAspectRatio = isTablet ? 1.05 : 0.82;

    final completedCount = learning.completedLessonIds.length;
    final totalLessons = learning.getAllLessons().length;
    final progressPct = totalLessons > 0 ? (completedCount / totalLessons) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_rounded, color: Theme.of(context).primaryColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'TechEase',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                loc.tr('learn_title'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Open / Share to Phone',
            icon: const Icon(Icons.qr_code_2, size: 28),
            onPressed: () => ShareToPhoneDialog.show(context),
          ),
          IconButton(
            tooltip: loc.tr('glossary_title'),
            icon: const Icon(Icons.menu_book, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GlossaryScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: learning.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(AppDesign.spaceMedium),
                children: [
                  // Warm Senior Greeting Hero Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppDesign.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${loc.tr('welcome')}, ${user.profile.name}!',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🔥', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user.profile.learningStreakDays} Day Streak',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Learn how to use your smartphone',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.tr('learn_subtitle'),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Overall Progress Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress: $completedCount of $totalLessons lessons done',
                              style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${(progressPct * 100).toInt()}%',
                              style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progressPct.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Action Assist Row
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Ask Family Button
                      Expanded(
                        child: InkWell(
                          onTap: () => _showFamilyHelpDialog(context, user),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade300, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.support_agent, color: Colors.red.shade800, size: 26),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Need Help?',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
                                      ),
                                      Text(
                                        'Ask Family',
                                        style: TextStyle(fontSize: 12, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Send to Phone Button
                      Expanded(
                        child: InkWell(
                          onTap: () => ShareToPhoneDialog.show(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade600, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.qr_code_2, color: Colors.green.shade800, size: 26),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Phone View',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
                                      ),
                                      Text(
                                        'Scan QR Code',
                                        style: TextStyle(fontSize: 12, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Resume Unfinished Lesson Banner
                  if (unfinishedLesson != null) ...[
                    const SizedBox(height: AppDesign.spaceMedium),
                    Card(
                      color: Colors.amber.shade50,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.amber.shade400, width: 2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LessonPlayerScreen(lesson: unfinishedLesson)),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade700,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.tr('resume_lesson'),
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                                    ),
                                    Text(
                                      unfinishedLesson.title,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Daily Senior Tech Tip Card
                  const SizedBox(height: AppDesign.spaceMedium),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today's Senior Wisdom Tip",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Never share your 4-digit bank SMS code (OTP) with anyone, even if they claim to be a bank manager.',
                                style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Glossary Quick Button
                  const SizedBox(height: AppDesign.spaceSmall),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.menu_book, size: 26, color: Colors.blue),
                      ),
                      title: Text(loc.tr('glossary_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: const Text('Explanations of icons like Wi-Fi, QR code, and mic.', style: TextStyle(fontSize: 14)),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GlossaryScreen()),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDesign.spaceMedium),
                  const Text(
                    'Topics to Learn',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppDesign.spaceSmall),

                  // Categories Grid with rich visual accents
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: AppDesign.spaceMedium,
                      crossAxisSpacing: AppDesign.spaceMedium,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: learning.categories.length,
                    itemBuilder: (context, i) {
                      final cat = learning.categories[i];
                      final gradient = AppDesign.getCategoryGradient(cat.title);
                      final iconData = AppDesign.getCategoryIcon(cat.title);

                      // Check completion of this category's lessons
                      int totalCatLessons = 0;
                      int completedCatLessons = 0;
                      for (final task in cat.tasks) {
                        for (final l in task.lessons) {
                          totalCatLessons++;
                          if (learning.isLessonCompleted(l.id)) {
                            completedCatLessons++;
                          }
                        }
                      }
                      final isCatCompleted = totalCatLessons > 0 && completedCatLessons == totalCatLessons;

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CategoryScreen(category: cat)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Thematic Icon Badge
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: gradient,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.12),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Icon(iconData, color: Colors.white, size: 32),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  cat.title,
                                  style: AppDesign.title.copyWith(fontSize: 18),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cat.description,
                                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                // Progress Badge
                                if (isCatCompleted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green.shade800, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Completed',
                                          style: TextStyle(
                                            color: Colors.green.shade900,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$totalCatLessons ${totalCatLessons == 1 ? "lesson" : "lessons"}',
                                      style: TextStyle(
                                        color: Colors.blue.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
