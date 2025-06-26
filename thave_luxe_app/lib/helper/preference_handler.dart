import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String _tokenKey =
      'auth_token'; // This is correct and consistent now
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // --- Token Operations ---
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('PreferenceHandler: Token saved: $token'); // Added logging
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('PreferenceHandler: Token retrieved: $token'); // Added logging
    return token;
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('PreferenceHandler: Token cleared.'); // Added logging
  }

  // --- User Name Operations ---
  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? '';
  }

  // --- User Email Operations ---
  static Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey) ?? '';
  }

  // --- Clear All User Details (for Logout) ---
  static Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    print('PreferenceHandler: User details cleared.'); // Added logging
  }

  // Clear all preferences (use with caution, only for full reset)
  static Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('PreferenceHandler: All preferences cleared.'); // Added logging
  }
}
