import 'package:material_ui/material_ui.dart';
import '../models/lesson.dart';
import 'learning_service.dart';

class SavedLessonsService extends ChangeNotifier {
  final Set<String> _bookmarkedLessonIds = {};
  final Map<String, int> _lessonStepProgress = {};
  String? _lastActiveLessonId;

  Set<String> get bookmarkedLessonIds => Set.unmodifiable(_bookmarkedLessonIds);
  String? get lastActiveLessonId => _lastActiveLessonId;

  bool isBookmarked(String lessonId) {
    return _bookmarkedLessonIds.contains(lessonId);
  }

  void toggleBookmark(String lessonId) {
    if (_bookmarkedLessonIds.contains(lessonId)) {
      _bookmarkedLessonIds.remove(lessonId);
    } else {
      _bookmarkedLessonIds.add(lessonId);
    }
    notifyListeners();
  }

  void addBookmark(String lessonId) {
    if (_bookmarkedLessonIds.add(lessonId)) {
      notifyListeners();
    }
  }

  void removeBookmark(String lessonId) {
    if (_bookmarkedLessonIds.remove(lessonId)) {
      notifyListeners();
    }
  }

  void saveStepProgress(String lessonId, int stepIndex) {
    _lessonStepProgress[lessonId] = stepIndex;
    _lastActiveLessonId = lessonId;
    notifyListeners();
  }

  int getSavedStep(String lessonId) {
    return _lessonStepProgress[lessonId] ?? 0;
  }

  List<Lesson> getBookmarkedLessons(LearningService learningService) {
    final list = <Lesson>[];
    for (final id in _bookmarkedLessonIds) {
      final lesson = learningService.findLessonById(id);
      if (lesson != null) {
        list.add(lesson);
      }
    }
    return list;
  }

  Lesson? getLastUnfinishedLesson(LearningService learningService) {
    if (_lastActiveLessonId == null) return null;
    return learningService.findLessonById(_lastActiveLessonId!);
  }
}
