import 'package:flutter/foundation.dart';
import 'package:mvvm/domain/models/auth/auth_response.dart';
import 'package:mvvm/domain/models/auth/auth_login_request.dart';
import 'package:mvvm/utils/result.dart';

abstract class AuthRepository extends ChangeNotifier {
  bool get isLoggedIn;

  Future<Result<AuthResponse>> login(AuthLoginRequest dadosLogin);
  Future<Result<void>> logout();
}
