import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import '../../design_system.dart';

class ShareToPhoneDialog extends StatelessWidget {
  const ShareToPhoneDialog({Key? key}) : super(key: key);

  static const String publicWebUrl = 'https://shivamdave37.github.io/TechEase/';
  static const String localWifiUrl = 'http://192.168.31.71:8080/';
  static const String apkDownloadUrl = 'https://github.com/shivamdave37/TechEase/releases/latest';

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const ShareToPhoneDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(AppDesign.spaceMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.phone_android, color: Colors.green.shade800, size: 30),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Open TechEase on Phone',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Use on any real smartphone (Android or iPhone)',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),

              Expanded(
                child: ListView(
                  children: [
                    // Method 1: Scan QR Code with Phone Camera
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.qr_code_scanner, color: Colors.blue, size: 24),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Method 1: Scan with Phone Camera',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Point any phone camera or Google Lens at this QR code to open the app instantly:',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),

                          // QR Code Image
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: Image.network(
                              'https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=https://shivamdave37.github.io/TechEase/',
                              width: 180,
                              height: 180,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Container(
                                width: 180,
                                height: 180,
                                color: Colors.grey.shade100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.qr_code, size: 80, color: Colors.black45),
                                    SizedBox(height: 6),
                                    Text('Scan link below', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Method 2: Send Web Link (Works anywhere via WhatsApp)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.link, color: Colors.green.shade800, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Method 2: Send Link to Friends / Family',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Copy this link and send it via WhatsApp, SMS, or Email. It opens directly on any smartphone with zero download needed:',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade400),
                            ),
                            child: SelectableText(
                              publicWebUrl,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.copy, size: 20),
                                  label: const Text('Copy Link to Clipboard', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(text: publicWebUrl));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Row(
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.white),
                                              SizedBox(width: 8),
                                              Text('Link successfully copied! You can now paste it in WhatsApp or SMS.'),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Method 3: Same Wi-Fi Network Link
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.amber.shade400),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.wifi, color: Colors.amber.shade900, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Method 3: Same Wi-Fi Network',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'If the phone is connected to the same home Wi-Fi as this laptop, open this link in the phone browser:',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: const SelectableText(
                              localWifiUrl,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // How to Install on Smartphone (App Icon)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '📲 How to Add as an App Icon on Phone Home Screen:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• On Android (Samsung, Xiaomi, Oppo, etc.):\n  Open the link in Chrome -> Tap 3 dots (top right) -> Tap "Install App" or "Add to Home screen".\n\n• On iPhone (Apple):\n  Open the link in Safari -> Tap the Share button at bottom -> Tap "Add to Home Screen".\n\nOnce added, it opens full-screen just like a regular app downloaded from Google Play or App Store!',
                            style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
