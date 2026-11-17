import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';
import '../services/localization_service.dart';
import 'learn/learn_home_view.dart';
import 'profile/profile_screen.dart';
import 'saved_and_search/saved_search_screen.dart';
import 'share/share_to_phone_dialog.dart';
import 'videos/videos_screen.dart';
import 'voice_groups/voice_groups_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;
  const MainNavigationShell({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _tabs = const [
    LearnHomeView(),
    SavedSearchScreen(),
    VideosScreen(),
    VoiceGroupsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocalizationService>(context);
    final accessibility = Provider.of<AccessibilityService>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Auto-Screen Adaptation:
    // If opened on laptop/desktop/wide monitor (width >= 850px), adapts into a spacious desktop layout.
    // If opened on smartphone or portrait mobile (width < 850px), adapts into a native full-screen phone layout.
    final isLaptopOrDesktop = screenWidth >= 850;

    if (isLaptopOrDesktop) {
      return Scaffold(
        appBar: AppBar(
          elevation: 2,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.school, color: Theme.of(context).primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                loc.tr('app_title'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          actions: [
            // Quick Font Size Buttons in Laptop Header
            Row(
              children: [
                IconButton(
                  tooltip: 'Decrease font size',
                  icon: const Text('A-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  onPressed: () => accessibility.decreaseFont(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(accessibility.fontScale * 100).toInt()}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Increase font size',
                  icon: const Text('A+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  onPressed: () => accessibility.increaseFont(),
                ),
              ],
            ),
            const SizedBox(width: 8),

            // High Contrast Quick Toggle
            IconButton(
              tooltip: accessibility.isHighContrast ? 'Disable High Contrast' : 'Enable High Contrast',
              icon: Icon(accessibility.isHighContrast ? Icons.contrast : Icons.contrast_outlined),
              onPressed: () => accessibility.toggleHighContrast(!accessibility.isHighContrast),
            ),

            // Language Selector Popup
            PopupMenuButton<String>(
              tooltip: 'Change Language',
              icon: const Icon(Icons.language),
              initialValue: loc.currentLocale,
              onSelected: (code) => loc.setLocale(code),
              itemBuilder: (ctx) => loc.supportedLanguages.entries.map((entry) {
                final code = entry.key;
                final name = entry.value;
                return PopupMenuItem<String>(
                  value: code,
                  child: Row(
                    children: [
                      if (code == loc.currentLocale)
                        const Icon(Icons.check, color: Colors.blue, size: 18)
                      else
                        const SizedBox(width: 18),
                      const SizedBox(width: 8),
                      Text(name, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                );
              }).toList(),
            ),

            // Send / Open on Phone Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.qr_code_2, size: 20),
                label: const Text('Open on Phone', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => ShareToPhoneDialog.show(context),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Row(
          children: [
            // Spacious Left Navigation Rail for Laptop
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              labelType: screenWidth >= 1100
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              extended: screenWidth >= 1100,
              minWidth: 88,
              minExtendedWidth: 210,
              leading: const SizedBox(height: 8),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.school_outlined, size: 28),
                  selectedIcon: const Icon(Icons.school, size: 28),
                  label: Text(loc.tr('nav_learn'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.bookmark_outline, size: 28),
                  selectedIcon: const Icon(Icons.bookmark, size: 28),
                  label: Text(loc.tr('nav_saved'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.video_library_outlined, size: 28),
                  selectedIcon: const Icon(Icons.video_library, size: 28),
                  label: Text(loc.tr('nav_videos'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.record_voice_over_outlined, size: 28),
                  selectedIcon: const Icon(Icons.record_voice_over, size: 28),
                  label: Text(loc.tr('nav_groups'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person_outline, size: 28),
                  selectedIcon: const Icon(Icons.person, size: 28),
                  label: Text(loc.tr('nav_profile'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),

            // Main Responsive Content Area
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _tabs,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Smartphone Layout (Auto-screen for Phones and small screens)
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 72,
          indicatorColor: Colors.blue.shade100,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.blue.shade900 : Colors.black87,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: isSelected ? 30 : 26,
              color: isSelected ? Colors.blue.shade900 : Colors.black54,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.school_outlined),
              selectedIcon: const Icon(Icons.school),
              label: loc.tr('nav_learn'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.bookmark_outline),
              selectedIcon: const Icon(Icons.bookmark),
              label: loc.tr('nav_saved'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.video_library_outlined),
              selectedIcon: const Icon(Icons.video_library),
              label: loc.tr('nav_videos'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.record_voice_over_outlined),
              selectedIcon: const Icon(Icons.record_voice_over),
              label: loc.tr('nav_groups'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: loc.tr('nav_profile'),
            ),
          ],
        ),
      ),
    );
  }
}
