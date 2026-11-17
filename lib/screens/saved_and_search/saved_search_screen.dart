import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../design_system.dart';
import '../../models/lesson.dart';
import '../../services/learning_service.dart';
import '../../services/localization_service.dart';
import '../../services/saved_lessons_service.dart';
import '../../services/search_service.dart';
import '../lesson_player_screen.dart';

class SavedSearchScreen extends StatefulWidget {
  const SavedSearchScreen({Key? key}) : super(key: key);

  @override
  State<SavedSearchScreen> createState() => _SavedSearchScreenState();
}

class _SavedSearchScreenState extends State<SavedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showVoiceSearchDialog() {
    final loc = Provider.of<LocalizationService>(context, listen: false);
    final search = Provider.of<SearchService>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.mic, color: Colors.blue.shade700, size: 32),
                const SizedBox(width: 10),
                Text(loc.tr('voice_search')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade300, width: 3),
                  ),
                  child: const Icon(Icons.mic, color: Colors.blue, size: 44),
                ),
                const SizedBox(height: 16),
                Text(
                  loc.tr('voice_search_prompt'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Text(
                    loc.tr('voice_search_permission_msg'),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 14),
                // Quick simulated speech recognitions for testing
                const Text('Or tap a spoken sample:', style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      label: const Text('WhatsApp message'),
                      onPressed: () {
                        _searchController.text = 'WhatsApp';
                        search.setQuery('WhatsApp');
                        Navigator.pop(ctx);
                      },
                    ),
                    ActionChip(
                      label: const Text('Scan QR code'),
                      onPressed: () {
                        _searchController.text = 'QR';
                        search.setQuery('QR');
                        Navigator.pop(ctx);
                      },
                    ),
                    ActionChip(
                      label: const Text('Google Maps'),
                      onPressed: () {
                        _searchController.text = 'Maps';
                        search.setQuery('Maps');
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close', style: TextStyle(fontSize: 18)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final learning = Provider.of<LearningService>(context);
    final saved = Provider.of<SavedLessonsService>(context);
    final search = Provider.of<SearchService>(context);
    final loc = Provider.of<LocalizationService>(context);

    final results = search.search(learning);
    final bookmarkedLessons = saved.getBookmarkedLessons(learning);
    final isSearching = search.query.trim().isNotEmpty || search.selectedCategory != 'All';

    final categories = ['All', ...learning.categories.map((c) => c.title)];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tr('nav_saved'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Header
            Container(
              padding: const EdgeInsets.all(AppDesign.spaceMedium),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: loc.tr('search_hint'),
                            prefixIcon: const Icon(Icons.search, size: 28),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      search.clearQuery();
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: const TextStyle(fontSize: 18),
                          onChanged: (val) => search.setQuery(val),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Voice Search Button
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          tooltip: loc.tr('voice_search'),
                          icon: const Icon(Icons.mic, color: Colors.white, size: 28),
                          onPressed: _showVoiceSearchDialog,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Category Filter Chips
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final catName = categories[i];
                        final isSelected = search.selectedCategory == catName;
                        return ChoiceChip(
                          label: Text(
                            catName == 'All' ? loc.tr('filter_all') : catName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Colors.blue.shade700,
                          backgroundColor: Colors.grey.shade100,
                          onSelected: (_) => search.setCategoryFilter(catName),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content Body: Either Search Results or Saved Lessons & Suggestions
            Expanded(
              child: isSearching
                  ? _buildSearchResults(results, saved, loc)
                  : _buildSavedLessonsAndSuggestions(bookmarkedLessons, saved, search, loc),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchResults results, SavedLessonsService saved, LocalizationService loc) {
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDesign.spaceLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.search_off, size: 64, color: Colors.black38),
              SizedBox(height: 16),
              Text(
                'No matching lessons or words found.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Try typing a simpler word like "call", "photo", or "map".',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppDesign.spaceMedium),
      children: [
        if (results.lessons.isNotEmpty) ...[
          Text('Lessons (${results.lessons.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...results.lessons.map((lesson) => _buildLessonCard(lesson, saved)),
          const SizedBox(height: 16),
        ],
        if (results.glossaryTerms.isNotEmpty) ...[
          Text('Glossary Terms (${results.glossaryTerms.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...results.glossaryTerms.map((term) => Card(
                child: ListTile(
                  leading: const Icon(Icons.help_outline, color: Colors.blue, size: 30),
                  title: Text(term.term, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(term.definition, style: const TextStyle(fontSize: 15)),
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildSavedLessonsAndSuggestions(
    List<Lesson> bookmarkedLessons,
    SavedLessonsService saved,
    SearchService search,
    LocalizationService loc,
  ) {
    return ListView(
      padding: const EdgeInsets.all(AppDesign.spaceMedium),
      children: [
        // Saved Lessons Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.tr('saved_lessons'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              '${bookmarkedLessons.length} saved',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (bookmarkedLessons.isEmpty)
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.bookmark_border, size: 48, color: Colors.black38),
                  const SizedBox(height: 12),
                  Text(
                    loc.tr('no_saved_lessons'),
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...bookmarkedLessons.map((lesson) => _buildLessonCard(lesson, saved)),

        const SizedBox(height: 24),
        const Text(
          'Suggested Searches',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SearchService.suggestedSearches.map((suggestion) {
            return ActionChip(
              avatar: const Icon(Icons.search, size: 18),
              label: Text(suggestion, style: const TextStyle(fontSize: 15)),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () {
                _searchController.text = suggestion;
                search.setQuery(suggestion);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLessonCard(Lesson lesson, SavedLessonsService saved) {
    final isBookmarked = saved.isBookmarked(lesson.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
          child: const Icon(Icons.menu_book, color: Colors.blue, size: 28),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          lesson.description,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: isBookmarked ? Colors.amber.shade800 : Colors.grey,
            size: 30,
          ),
          onPressed: () => saved.toggleBookmark(lesson.id),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LessonPlayerScreen(lesson: lesson)),
          );
        },
      ),
    );
  }
}
