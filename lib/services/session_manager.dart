import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _tokenKey = 'token';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userRoleKey = 'user_role';
  static const _userPhoneKey = 'user_phone';
  static const _userAddressKey = 'user_address';
  static const _userPhotoKey = 'user_photo';

  static Future<void> saveSession({
    required String token,
    required String name,
    required String email,
    required String role,
    String? phone,
    String? address,
    String? photo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userRoleKey, role);
    await prefs.setString(_userPhoneKey, phone ?? '');
    await prefs.setString(_userAddressKey, address ?? '');
    await prefs.setString(_userPhotoKey, photo ?? '');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  static Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhoneKey);
  }

  static Future<String?> getUserAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userAddressKey);
  }

  static Future<String?> getUserPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhotoKey);
  }

  static Future<void> updateLocalProfile({
    required String name,
    required String email,
    String? phone,
    String? address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    if (phone != null) await prefs.setString(_userPhoneKey, phone);
    if (address != null) await prefs.setString(_userAddressKey, address);
  }

  static Future<void> updateLocalPhoto(String photoPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPhotoKey, photoPath);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_userAddressKey);
    await prefs.remove(_userPhotoKey);
  }
}
