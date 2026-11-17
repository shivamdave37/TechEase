import 'package:material_ui/material_ui.dart';
import 'community_video_service.dart';

class ReportedItem {
  final String id;
  final String itemType; // 'video' or 'voice_message'
  final String itemId;
  final String titleOrSender;
  final String reason;
  final String reportedByUserId;
  final DateTime reportedAt;
  bool isResolved;

  ReportedItem({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.titleOrSender,
    required this.reason,
    required this.reportedByUserId,
    required this.reportedAt,
    this.isResolved = false,
  });
}

class ModerationService extends ChangeNotifier {
  final List<ReportedItem> _reports = [];

  List<ReportedItem> get activeReports =>
      _reports.where((r) => !r.isResolved).toList();

  ModerationService() {
    _seedInitialReports();
  }

  void _seedInitialReports() {
    _reports.addAll([
      ReportedItem(
        id: 'rep_1',
        itemType: 'video',
        itemId: 'vid_1',
        titleOrSender: 'How to Make a WhatsApp Video Call',
        reason: 'Misleading sound volume advice',
        reportedByUserId: 'user_anonymous',
        reportedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      ReportedItem(
        id: 'rep_2',
        itemType: 'voice_message',
        itemId: 'msg_spam',
        titleOrSender: 'Unknown Caller (Audio)',
        reason: 'Possible lottery scam or spam message',
        reportedByUserId: 'elder_user_1',
        reportedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ]);
  }

  void reportItem({
    required String itemType,
    required String itemId,
    required String titleOrSender,
    required String reason,
    required String reportedByUserId,
  }) {
    final report = ReportedItem(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      itemType: itemType,
      itemId: itemId,
      titleOrSender: titleOrSender,
      reason: reason,
      reportedByUserId: reportedByUserId,
      reportedAt: DateTime.now(),
    );
    _reports.insert(0, report);
    notifyListeners();
  }

  void dismissReport(String reportId) {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _reports[index].isResolved = true;
      notifyListeners();
    }
  }

  void resolveAndRemove(String reportId, CommunityVideoService? videoService) {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      final report = _reports[index];
      report.isResolved = true;
      if (report.itemType == 'video' && videoService != null) {
        videoService.rejectVideo(report.itemId, 'Removed by moderator: ${report.reason}');
      }
      notifyListeners();
    }
  }

  int get pendingTasksCount {
    return _reports.where((r) => !r.isResolved).length;
  }
}
