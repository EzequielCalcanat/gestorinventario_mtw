import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsRepository {
  static Future<String?> getBranchId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_branch_id');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('logged_user_id');
  }
}
