import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../design_system.dart';
import '../../services/community_video_service.dart';
import '../../services/moderation_service.dart';

class ModerationScreen extends StatelessWidget {
  const ModerationScreen({Key? key}) : super(key: key);

  void _showRejectDialog(BuildContext context, String videoId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Video Submission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter a respectful, clear reason for rejection (e.g. video shows private info or is unclear):'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Rejection Reason', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final videoService = Provider.of<CommunityVideoService>(context, listen: false);
              videoService.rejectVideo(videoId, reasonController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video rejected with explanation.')),
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moderation = Provider.of<ModerationService>(context);
    final videoService = Provider.of<CommunityVideoService>(context);

    final pendingVideos = videoService.pendingModerationVideos;
    final activeReports = moderation.activeReports;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Moderation Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Video Queue', style: TextStyle(fontSize: 16)),
                    if (pendingVideos.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.amber,
                        child: Text('${pendingVideos.length}', style: const TextStyle(fontSize: 12, color: Colors.black)),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Reported Items', style: TextStyle(fontSize: 16)),
                    if (activeReports.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text('${activeReports.length}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Video Submission Queue
            pendingVideos.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppDesign.spaceLarge),
                      child: Text(
                        'No pending videos awaiting review.\nAll submissions have been checked!',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppDesign.spaceMedium),
                    itemCount: pendingVideos.length,
                    itemBuilder: (context, i) {
                      final v = pendingVideos[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(6)),
                                    child: Text('Pending Review', style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(v.category, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(v.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(v.description, style: const TextStyle(fontSize: 15)),
                              const SizedBox(height: 8),
                              Text('Submitted by: ${v.uploaderName}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                    onPressed: () => _showRejectDialog(context, v.id),
                                    child: const Text('Reject with Reason'),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                                    onPressed: () {
                                      videoService.approveVideo(v.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Video approved and published to library!')),
                                      );
                                    },
                                    child: const Text('Approve & Publish'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            // Tab 2: Reported Content Queue
            activeReports.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppDesign.spaceLarge),
                      child: Text(
                        'No active reports.\nThe community space is safe and clean!',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppDesign.spaceMedium),
                    itemCount: activeReports.length,
                    itemBuilder: (context, i) {
                      final rep = activeReports[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.report, color: Colors.red, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Reported ${rep.itemType.replaceAll('_', ' ').toUpperCase()}',
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Item: ${rep.titleOrSender}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                                child: Text('Reason given: ${rep.reason}', style: const TextStyle(fontSize: 15, color: Colors.black87)),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => moderation.dismissReport(rep.id),
                                    child: const Text('Dismiss Report'),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                                    onPressed: () {
                                      moderation.resolveAndRemove(rep.id, videoService);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Content removed and violation resolved.')),
                                      );
                                    },
                                    child: const Text('Take Down Content'),
                                  ),
                                ],
                              ),
                            ],
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
