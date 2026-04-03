import 'package:mvvm/data/services/local/shared_preferences_service.dart';

class MockSharedPreferencesService implements SharedPreferencesService {
  String? _accessToken;
  String? _refreshToken;
  int saveCallCount = 0;
  int clearCallCount = 0;

  @override
  String? get accessToken => _accessToken;

  @override
  String? get refreshToken => _refreshToken;

  @override
  Future<void> saveTokens(String access, String refresh) async {
    saveCallCount++;
    _accessToken = access;
    _refreshToken = refresh;
  }

  @override
  Future<void> clear() async {
    clearCallCount++;
    _accessToken = null;
    _refreshToken = null;
  }
}
