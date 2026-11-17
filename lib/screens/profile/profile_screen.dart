import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../design_system.dart';
import '../../services/accessibility_service.dart';
import '../../services/analytics_service.dart';
import '../../services/learning_service.dart';
import '../../services/localization_service.dart';
import '../../services/moderation_service.dart';
import '../../services/user_service.dart';
import '../auth/phone_login_screen.dart';
import 'moderation_screen.dart';
import 'privacy_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _showEditNameDialog(BuildContext context, UserService userService) {
    final controller = TextEditingController(text: userService.profile.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Your Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Display Name'),
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              userService.updateName(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAnalyticsDialog(BuildContext context, AnalyticsService analytics) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.analytics, color: Colors.blue, size: 28),
            SizedBox(width: 8),
            Text('Learning Activity Summary'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statRow('Lessons Started:', '${analytics.lessonsStarted}'),
            _statRow('Lessons Finished:', '${analytics.lessonsCompleted}'),
            _statRow('Practice Tests Passed:', '${analytics.practiceCompleted}'),
            _statRow('Videos Watched:', '${analytics.videosWatched}'),
            _statRow('Voice Notes Shared:', '${analytics.voiceMessagesSent}'),
            _statRow('Searches Performed:', '${analytics.searchQueriesPerformed}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(fontSize: 18))),
        ],
      ),
    );
  }

  static Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserService>(context);
    final accessibility = Provider.of<AccessibilityService>(context);
    final loc = Provider.of<LocalizationService>(context);
    final learning = Provider.of<LearningService>(context);
    final moderation = Provider.of<ModerationService>(context);
    final analytics = Provider.of<AnalyticsService>(context);

    final completedCount = learning.completedLessonIds.length;
    final totalCount = learning.getAllLessons().length;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tr('profile_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDesign.spaceMedium),
          children: [
            // User Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.person, size: 40, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.profile.name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Protected Phone: ${user.profile.maskedPhone}',
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: const Size(0, 36),
                            ),
                            icon: const Icon(Icons.phone_android, size: 16),
                            label: const Text('Sign In / Change Phone (OTP)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PhoneLoginScreen(isModal: true)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditNameDialog(context, user),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Learning Achievements Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Learning Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: _buildBadge(Icons.check_circle, '$completedCount / $totalCount', 'Completed')),
                        Expanded(child: _buildBadge(Icons.sports_esports, 'Practice', 'Sandbox Ready')),
                        Expanded(child: _buildBadge(Icons.thumb_up, 'Community', 'Active Learner')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section: Accessibility Controls
            const Text('Accessibility & View Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text Size Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.tr('text_size'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${(accessibility.fontScale * 100).toInt()}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                    Slider(
                      value: accessibility.fontScale,
                      min: 0.85,
                      max: 1.35,
                      divisions: 5,
                      label: '${(accessibility.fontScale * 100).toInt()}%',
                      onChanged: (val) => accessibility.setFontScale(val),
                    ),
                    Text(
                      'Preview: This is how instructions will look on your screen.',
                      style: TextStyle(fontSize: 16 * accessibility.fontScale, color: Colors.black87),
                    ),
                    const Divider(height: 28),

                    // High Contrast Toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(loc.tr('high_contrast'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Black & white bold edges for maximum clarity and less glare.'),
                      value: accessibility.isHighContrast,
                      onChanged: (val) => accessibility.toggleHighContrast(val),
                    ),
                    const Divider(height: 28),

                    // Theme Colors
                    const Text('Theme Color', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      children: AccessibilityService.availableThemeColors.map((color) {
                        final isSelected = accessibility.primaryColor == color && !accessibility.isHighContrast;
                        return GestureDetector(
                          onTap: () => accessibility.setPrimaryColor(color),
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 22,
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 28) : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section: Language Selection
            const Text('Language / भाषा / Idioma', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: loc.supportedLanguages.entries.map((entry) {
                  final isSelected = loc.currentLocale == entry.key;
                  return ListTile(
                    title: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.blue.shade900 : Colors.black87,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.blue, size: 28)
                        : const Icon(Icons.radio_button_unchecked, color: Colors.black38, size: 26),
                    onTap: () => loc.setLocale(entry.key),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Navigation Options
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip, color: Colors.blue, size: 28),
                    title: const Text('Privacy & Security Guide', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Blocked users, phone protection, safety rules'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacySettingsScreen()),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.analytics_outlined, color: Colors.green, size: 28),
                    title: const Text('My Learning Stats', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Review what you have learned and practiced'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showAnalyticsDialog(context, analytics),
                  ),
                  if (user.isAdmin) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings, color: Colors.purple, size: 28),
                      title: const Text('Admin Moderation Dashboard', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Review pending video uploads and reports'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (moderation.pendingTasksCount > 0)
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Text('${moderation.pendingTasksCount}', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ModerationScreen()),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue.shade800, size: 28),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
