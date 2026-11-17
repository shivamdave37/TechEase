import 'package:material_ui/material_ui.dart';
import '../models/user_profile.dart';

class UserService extends ChangeNotifier {
  late UserProfile _profile;

  UserService() {
    _profile = UserProfile.defaultProfile();
  }

  UserProfile get profile => _profile;
  List<String> get blockedUserIds => _profile.blockedUserIds;
  bool get isAdmin => _profile.isAdmin;

  void updateName(String newName) {
    if (newName.trim().isNotEmpty) {
      _profile.name = newName.trim();
      notifyListeners();
    }
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
