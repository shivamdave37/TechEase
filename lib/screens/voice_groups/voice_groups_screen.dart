import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../design_system.dart';
import '../../services/localization_service.dart';
import '../../services/user_service.dart';
import '../../services/voice_group_service.dart';
import 'voice_chat_screen.dart';

class VoiceGroupsScreen extends StatelessWidget {
  const VoiceGroupsScreen({Key? key}) : super(key: key);

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final topicController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create New Voice Group', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Group Name', hintText: 'e.g. Garden Lovers Voice Club'),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: topicController,
                decoration: const InputDecoration(labelText: 'Topic', hintText: 'e.g. Daily gardening tips'),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description', hintText: 'Explain the group purpose'),
                maxLines: 2,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontSize: 16))),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              final user = Provider.of<UserService>(context, listen: false);
              final voiceService = Provider.of<VoiceGroupService>(context, listen: false);

              voiceService.createGroup(
                name: nameController.text,
                topic: topicController.text,
                description: descController.text,
                creatorName: user.profile.name,
                creatorId: user.profile.id,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice group created successfully!')),
              );
            },
            child: const Text('Create Group', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Join Group with Code', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the invite code given by your family or friends (e.g. SENIOR-101):',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Invite Code',
                hintText: 'e.g. SENIOR-101',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontSize: 16))),
          ElevatedButton(
            onPressed: () {
              if (codeController.text.trim().isEmpty) return;
              final user = Provider.of<UserService>(context, listen: false);
              final voiceService = Provider.of<VoiceGroupService>(context, listen: false);

              final success = voiceService.joinGroupByCode(
                codeController.text,
                user.profile.id,
                user.profile.name,
              );

              Navigator.pop(ctx);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Joined group successfully!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not find a group with that code. Please check and try again.')),
                );
              }
            },
            child: const Text('Join Group', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voiceService = Provider.of<VoiceGroupService>(context);
    final loc = Provider.of<LocalizationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tr('voice_groups_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Explanatory Banner
            Container(
              padding: const EdgeInsets.all(AppDesign.spaceMedium),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
                    child: const Icon(Icons.record_voice_over, color: Colors.blue, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.tr('voice_groups_title'),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Text(
                          loc.tr('voice_groups_subtitle'),
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Action Buttons: Create & Join
            Padding(
              padding: const EdgeInsets.all(AppDesign.spaceMedium),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 52),
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 24),
                      label: Text(loc.tr('create_group'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () => _showCreateGroupDialog(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                      icon: const Icon(Icons.vpn_key, size: 22),
                      label: Text(loc.tr('join_group'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () => _showJoinGroupDialog(context),
                    ),
                  ),
                ],
              ),
            ),

            // Group List
            Expanded(
              child: voiceService.groups.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDesign.spaceLarge),
                        child: Text(
                          'No groups yet. Create one or join with an invite code!',
                          style: AppDesign.body.copyWith(color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppDesign.spaceMedium),
                      itemCount: voiceService.groups.length,
                      itemBuilder: (context, i) {
                        final grp = voiceService.groups[i];
                        final unreadCount = voiceService.getMessagesForGroup(grp.id).length;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                              child: const Icon(Icons.people, color: Colors.blue, size: 30),
                            ),
                            title: Text(grp.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(grp.topic, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Text('${grp.members.length} members', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                    Text('Code: ${grp.inviteCode}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (unreadCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                                    child: Text('$unreadCount msgs', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black45),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => VoiceChatScreen(group: grp)),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
