import 'package:shared_preferences/shared_preferences.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart'; // Import model tunggal User

class PreferenceHandler {
  static const String _tokenKey = 'auth_token';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userIdKey = 'user_id';

  // --- Token Management ---
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

  // --- User Data Management (using the consolidated User model) ---

  /// Sets user data (name, email, id) into SharedPreferences.
  /// This should be called after successful login or registration.
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
    // No need to set token here, setToken() method handles it.
  }

  /// Retrieves a User object from SharedPreferences.
  static Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getInt(_userIdKey);
    final name = prefs.getString(_userNameKey);
    final email = prefs.getString(_userEmailKey);

    // If any core user data is missing, return null (user not fully logged in/saved)
    if (id == null || name == null || email == null) {
      return null;
    }

    return User(id: id, name: name, email: email);
  }

  /// Clears only user-specific details (name, email, id) from SharedPreferences.
  static Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userIdKey); // Also clear user ID
  }

  /// Clears all stored preferences (token and user details).
  static Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
