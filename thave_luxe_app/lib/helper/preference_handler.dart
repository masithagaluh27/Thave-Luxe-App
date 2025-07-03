import 'package:shared_preferences/shared_preferences.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart';

class PreferenceHandler {
  static const String _tokenKey = 'auth_token';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userIdKey = 'user_id';

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> setUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user.id != null) {
      await prefs.setInt(_userIdKey, user.id!);
    }
    if (user.name != null) {
      await prefs.setString(_userNameKey, user.name!);
    }
    if (user.email != null) {
      await prefs.setString(_userEmailKey, user.email!);
    }
  }

  static Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getInt(_userIdKey);
    final name = prefs.getString(_userNameKey);
    final email = prefs.getString(_userEmailKey);

    if (id == null || name == null || email == null) {
      return null;
    }

    return User(id: id, name: name, email: email);
  }

  static Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userIdKey);
  }

  static Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
