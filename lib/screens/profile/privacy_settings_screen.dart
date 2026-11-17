import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../design_system.dart';
import '../../services/user_service.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final blockedUsers = userService.blockedUserIds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDesign.spaceMedium),
          children: [
            // Phone Protection Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.green.shade800, size: 36),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Phone Number is Protected', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(
                          'We always mask your phone number (e.g. ***-***-7890) so strangers in groups can never see your private number.',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Blocked Users Management
            const Text('Blocked Users', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            blockedUsers.isEmpty
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: const [
                          Icon(Icons.block, color: Colors.black38),
                          SizedBox(width: 12),
                          Text('You have not blocked any users.', style: TextStyle(fontSize: 16, color: Colors.black54)),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: blockedUsers.map((uid) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.person_off, color: Colors.red),
                          title: Text('Blocked User ($uid)', style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: TextButton(
                            child: const Text('Unblock', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            onPressed: () => userService.unblockUser(uid),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 24),

            // Important Safety Rules for Seniors
            const Text('Smart Safety Rules for You', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildSafetyTip(
              icon: Icons.password,
              title: 'Never Share 4 or 6-digit Codes (OTPs)',
              desc: 'Banks and companies never call asking for text message codes. If someone asks for a code, hang up immediately.',
            ),
            const SizedBox(height: 10),
            _buildSafetyTip(
              icon: Icons.link_off,
              title: 'Be Careful with Unknown Message Links',
              desc: 'Do not tap links in messages saying you won a lottery or that your electricity is being cut off.',
            ),
            const SizedBox(height: 10),
            _buildSafetyTip(
              icon: Icons.money_off,
              title: 'Keep QR Code Scanning Safe',
              desc: 'Scanning a QR code is only for viewing menus or paying. You NEVER scan a QR code to RECEIVE money.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTip({required IconData icon, required String title, required String desc}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.blue.shade800, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
