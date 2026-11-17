import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../design_system.dart';
import '../../services/learning_service.dart';
import '../../services/localization_service.dart';
import '../../services/saved_lessons_service.dart';
import '../../services/user_service.dart';
import '../category_screen.dart';
import '../lesson_player_screen.dart';
import 'glossary_screen.dart';

class LearnHomeView extends StatelessWidget {
  const LearnHomeView({Key? key}) : super(key: key);

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
    final childAspectRatio = isTablet ? 1.05 : 0.85;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tr('learn_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
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
                  // Greeting Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.blue.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${loc.tr('welcome')}, ${user.profile.name}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
                      ],
                    ),
                  ),

                  // Resume Unfinished Lesson Banner
                  if (unfinishedLesson != null) ...[
                    const SizedBox(height: AppDesign.spaceMedium),
                    Card(
                      color: Colors.amber.shade50,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.amber.shade400, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
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

                  // Glossary Button
                  const SizedBox(height: AppDesign.spaceSmall),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: const Icon(Icons.help_center, size: 32, color: Colors.blue),
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

                  // Categories Grid
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
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CategoryScreen(category: cat)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppDesign.spaceSmall),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Image.asset(
                                      cat.imageAsset,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.smartphone,
                                        size: 56,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppDesign.spaceSmall),
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
                                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
