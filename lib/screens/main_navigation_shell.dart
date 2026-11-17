import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import 'learn/learn_home_view.dart';
import 'profile/profile_screen.dart';
import 'saved_and_search/saved_search_screen.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopOrTablet = screenWidth > 600;

    final content = Scaffold(
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

    if (isDesktopOrTablet) {
      return Scaffold(
        backgroundColor: Colors.blueGrey.shade100,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: content,
          ),
        ),
      );
    }

    return content;
  }
}
