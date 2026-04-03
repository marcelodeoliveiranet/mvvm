import 'package:mvvm/data/services/auth/auth_service.dart';
import 'package:mvvm/domain/models/auth/auth_login_request.dart';
import 'package:mvvm/domain/models/auth/auth_refresh_token.dart';
import 'package:mvvm/domain/models/auth/auth_response.dart';

class MockAuthService implements AuthService {
  AuthResponse? loginResult;
  Exception? loginError;
  AuthResponse? refreshResult;
  Exception? refreshError;

  int loginCallCount = 0;
  int refreshCallCount = 0;

  @override
  String get endPoint => 'auth/login';

  @override
  Future<AuthResponse> login(AuthLoginRequest dadosLogin) async {
    loginCallCount++;
    if (loginError != null) throw loginError!;
    return loginResult!;
  }

  @override
  Future<AuthResponse> refresh(AuthRefreshToken refreshToken) async {
    refreshCallCount++;
    if (refreshError != null) throw refreshError!;
    return refreshResult!;
  }
}
