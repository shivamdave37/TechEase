import 'package:material_ui/material_ui.dart';
import '../models/category.dart';
import '../models/glossary_term.dart';
import '../models/lesson.dart';
import 'learning_service.dart';

class SearchResults {
  final List<Lesson> lessons;
  final List<Category> categories;
  final List<GlossaryTerm> glossaryTerms;

  const SearchResults({
    required this.lessons,
    required this.categories,
    required this.glossaryTerms,
  });

  bool get isEmpty => lessons.isEmpty && categories.isEmpty && glossaryTerms.isEmpty;
  int get totalCount => lessons.length + categories.length + glossaryTerms.length;
}

class SearchService extends ChangeNotifier {
  String _query = '';
  String _selectedCategory = 'All';
  bool _isListeningVoice = false;

  String get query => _query;
  String get selectedCategory => _selectedCategory;
  bool get isListeningVoice => _isListeningVoice;

  static const List<String> suggestedSearches = [
    'Send WhatsApp message',
    'How to scan QR code',
    'Make ringtone louder',
    'Find directions on Maps',
    'Zoom in on photos',
    'What is Wi-Fi?',
    'Search on Google',
  ];

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearQuery() {
    _query = '';
    notifyListeners();
  }

  void setVoiceListening(bool listening) {
    _isListeningVoice = listening;
    notifyListeners();
  }

  SearchResults search(LearningService learningService) {
    final cleanQuery = _query.trim().toLowerCase();

    if (cleanQuery.isEmpty && _selectedCategory == 'All') {
      return const SearchResults(lessons: [], categories: [], glossaryTerms: []);
    }

    final matchedLessons = <Lesson>[];
    final matchedCategories = <Category>[];
    final matchedGlossary = <GlossaryTerm>[];

    // Search Categories
    for (final cat in learningService.categories) {
      if (_selectedCategory != 'All' && cat.title != _selectedCategory) {
        continue;
      }

      if (cleanQuery.isEmpty ||
          cat.title.toLowerCase().contains(cleanQuery) ||
          cat.description.toLowerCase().contains(cleanQuery)) {
        matchedCategories.add(cat);
      }

      // Search Lessons inside tasks
      for (final task in cat.tasks) {
        for (final lesson in task.lessons) {
          final matchesTitle = lesson.title.toLowerCase().contains(cleanQuery);
          final matchesDesc = lesson.description.toLowerCase().contains(cleanQuery);
          final matchesSteps = lesson.steps.any((s) => s.text.toLowerCase().contains(cleanQuery));

          if (cleanQuery.isEmpty || matchesTitle || matchesDesc || matchesSteps) {
            matchedLessons.add(lesson);
          }
        }
      }
    }

    // Search Glossary Terms
    if (_selectedCategory == 'All') {
      for (final term in learningService.glossaryTerms) {
        if (cleanQuery.isNotEmpty &&
            (term.term.toLowerCase().contains(cleanQuery) ||
                term.definition.toLowerCase().contains(cleanQuery) ||
                term.simpleExample.toLowerCase().contains(cleanQuery))) {
          matchedGlossary.add(term);
        }
      }
    }

    return SearchResults(
      lessons: matchedLessons,
      categories: matchedCategories,
      glossaryTerms: matchedGlossary,
    );
  }
}
