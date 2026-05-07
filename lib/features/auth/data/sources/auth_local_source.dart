import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

// Contract
abstract class AuthLocalSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
}

class AuthLocalSourceImpl implements AuthLocalSource {
  final SharedPreferences _prefs;
  AuthLocalSourceImpl(this._prefs);

  static const _tokenKey = 'jwt_token';
  static const _userKey = 'current_user';

  @override
  Future<void> saveToken(String token) async => _prefs.setString(_tokenKey, token);

  @override
  Future<String?> getToken() async => _prefs.getString(_tokenKey);

  @override
  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }

  @override
  Future<void> saveUser(UserModel user) async =>
      _prefs.setString(_userKey, jsonEncode(user.toJson()));

  @override
  Future<UserModel?> getUser() async {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
