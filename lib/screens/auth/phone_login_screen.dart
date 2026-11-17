import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../design_system.dart';
import '../../services/user_service.dart';
import '../main_navigation_shell.dart';

class PhoneLoginScreen extends StatefulWidget {
  final bool isModal;
  const PhoneLoginScreen({Key? key, this.isModal = false}) : super(key: key);

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String _countryCode = '+91';
  bool _otpSent = false;
  String? _errorMessage;
  int _resendCountdown = 30;
  Timer? _countdownTimer;

  final List<String> _countryCodes = ['+91 (India)', '+1 (US/Canada)', '+44 (UK)', '+34 (Spain)', '+52 (Mexico)'];

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.length < 8) {
      setState(() => _errorMessage = 'Please enter a valid phone number (at least 8 digits).');
      return;
    }

    final userService = Provider.of<UserService>(context, listen: false);
    final fullNumber = '$_countryCode $phone';
    userService.requestOtp(fullNumber);

    setState(() {
      _otpSent = true;
      _errorMessage = null;
      _resendCountdown = 30;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_resendCountdown > 1) {
        setState(() => _resendCountdown--);
      } else {
        t.cancel();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.blue.shade900,
        content: Row(
          children: const [
            Icon(Icons.sms, color: Colors.amber, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '📩 SMS received! Your login verification code is 1234',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _verifyOtp() {
    final entered = _otpController.text.trim();
    if (entered.length < 4) {
      setState(() => _errorMessage = 'Please enter the 4-digit code.');
      return;
    }

    final userService = Provider.of<UserService>(context, listen: false);
    final success = userService.verifyOtp(entered);

    if (success) {
      setState(() => _errorMessage = null);
      if (widget.isModal) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Welcome! You have signed in successfully.', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ),
      );
    } else {
      setState(() => _errorMessage = 'Incorrect code. Please use demo code 1234 or try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_otpSent ? 'Verify Login Code' : 'Sign In with Phone', style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: widget.isModal
            ? IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: ListView(
              padding: const EdgeInsets.all(AppDesign.spaceMedium),
              children: [
                const SizedBox(height: 10),

                // Welcome Icon & Greeting
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade300, width: 2),
                    ),
                    child: Icon(_otpSent ? Icons.mark_email_read : Icons.phone_android, size: 54, color: Colors.blue.shade800),
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  _otpSent ? 'Enter 4-Digit Code' : 'Sign in to Keep Your Progress',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _otpSent
                      ? 'We sent a text message code to $_countryCode ${_phoneController.text}.\nNo password needed!'
                      : 'Enter your phone number. We will send an SMS code to sign you in safely without any password.',
                  style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.3),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade400),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (!_otpSent) ...[
                  // Phone Number Input Form
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _countryCode,
                            items: _countryCodes.map((c) {
                              final code = c.split(' ').first;
                              return DropdownMenuItem(value: code, child: Text(code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _countryCode = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            hintText: '98765 43210',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Privacy assurance note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade400),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.lock, color: Colors.green, size: 24),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your phone number is strictly private and always masked as ***-***-1234 to protect you.',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Send Code Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.send, size: 24),
                    label: const Text('Send 4-Digit Login Code', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                    onPressed: _sendOtp,
                  ),
                  const SizedBox(height: 16),

                  // Continue as Guest
                  Center(
                    child: TextButton(
                      onPressed: () {
                        if (widget.isModal) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const MainNavigationShell()),
                          );
                        }
                      },
                      child: const Text('Skip & Continue as Guest', style: TextStyle(fontSize: 16, color: Colors.black54)),
                    ),
                  ),
                ] else ...[
                  // OTP Input Form
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 16),
                    decoration: InputDecoration(
                      hintText: '----',
                      counterText: '',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Demo Auto-fill Helper
                  Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.blue.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue, size: 26),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Testing on laptop? Your verification code is 1234',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            onPressed: () => setState(() => _otpController.text = '1234'),
                            child: const Text('Auto-Fill'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Verify Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check_circle, size: 26),
                    label: const Text('Verify & Sign In', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    onPressed: _verifyOtp,
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      TextButton(
                        onPressed: () => setState(() {
                          _otpSent = false;
                          _otpController.clear();
                        }),
                        child: const Text('Change Phone Number', style: TextStyle(fontSize: 15)),
                      ),
                      TextButton(
                        onPressed: _resendCountdown <= 1 ? _sendOtp : null,
                        child: Text(
                          _resendCountdown > 1 ? 'Resend in ${_resendCountdown}s' : 'Resend Code',
                          style: TextStyle(
                            fontSize: 15,
                            color: _resendCountdown > 1 ? Colors.grey : Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
