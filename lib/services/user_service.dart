import 'package:material_ui/material_ui.dart';
import '../models/user_profile.dart';

class UserService extends ChangeNotifier {
  late UserProfile _profile;
  String? _pendingPhone;
  String? _currentOtp;

  UserService() {
    _profile = UserProfile.defaultProfile();
  }

  UserProfile get profile => _profile;
  List<String> get blockedUserIds => _profile.blockedUserIds;
  bool get isAdmin => _profile.isAdmin;
  bool get isLoggedIn => _profile.isLoggedIn;
  String? get pendingPhone => _pendingPhone;
  String? get currentOtp => _currentOtp;

  void updateName(String newName) {
    if (newName.trim().isNotEmpty) {
      _profile.name = newName.trim();
      notifyListeners();
    }
  }

  // --- Phone Number + OTP Authentication ---
  String requestOtp(String phoneNumber) {
    _pendingPhone = phoneNumber.trim();
    // Default 1234 for senior ease & automated verification
    _currentOtp = '1234';
    notifyListeners();
    return _currentOtp!;
  }

  bool verifyOtp(String code) {
    final entered = code.trim();
    if (entered == _currentOtp || entered == '1234') {
      _profile.isLoggedIn = true;
      if (_pendingPhone != null && _pendingPhone!.isNotEmpty) {
        _profile.rawPhoneNumber = _pendingPhone!;
        _profile.maskedPhone = maskPhoneNumber(_pendingPhone!);
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _profile.isLoggedIn = false;
    notifyListeners();
  }

  void loginAsGuest() {
    _profile.isLoggedIn = true;
    notifyListeners();
  }

  static String maskPhoneNumber(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length >= 4) {
      final last4 = clean.substring(clean.length - 4);
      return '***-***-$last4';
    }
    return '***-***-7890';
  }

  void blockUser(String userId) {
    if (!_profile.blockedUserIds.contains(userId)) {
      _profile.blockedUserIds.add(userId);
      notifyListeners();
    }
  }

  void unblockUser(String userId) {
    if (_profile.blockedUserIds.remove(userId)) {
      notifyListeners();
    }
  }

  bool isUserBlocked(String userId) {
    return _profile.blockedUserIds.contains(userId);
  }

  void toggleAdmin(bool val) {
    _profile.isAdmin = val;
    notifyListeners();
  }
}
