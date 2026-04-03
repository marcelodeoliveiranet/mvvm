import 'package:flutter/foundation.dart';
import 'package:mvvm/data/repositories/auth/auth_repository.dart';
import 'package:mvvm/domain/models/auth/auth_login_request.dart';
import 'package:mvvm/domain/models/auth/auth_response.dart';
import 'package:mvvm/utils/result.dart';

class MockAuthRepository extends ChangeNotifier implements AuthRepository {
  Result<AuthResponse>? loginResult;
  Result<void>? logoutResult;
  int loginCallCount = 0;
  int logoutCallCount = 0;

  bool _isLoggedIn = false;

  @override
  bool get isLoggedIn => _isLoggedIn;

  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  @override
  Future<Result<AuthResponse>> login(AuthLoginRequest dadosLogin) async {
    loginCallCount++;
    final result = loginResult!;
    if (result is Ok<AuthResponse>) {
      _isLoggedIn = true;
    }
    notifyListeners();
    return result;
  }

  @override
  Future<Result<void>> logout() async {
    logoutCallCount++;
    _isLoggedIn = false;
    notifyListeners();
    return logoutResult ?? Result.ok(null);
  }
}
