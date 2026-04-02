// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  final SharedPreferences _preferences;

  SharedPreferencesService(this._preferences);

  String? get accessToken => _preferences.getString("access_token");
  String? get refreshToken => _preferences.getString("refresh_token");

  Future<void> saveTokens(String access, String refresh) async {
    await _preferences.setString("access_token", access);
    await _preferences.setString("refresh_token", refresh);
  }

  Future<void> clear() async {
    await _preferences.remove("access_token");
    await _preferences.remove("refresh_token");
  }
}
