import 'package:mvvm/domain/models/auth/auth_response.dart';
import 'package:mvvm/domain/models/auth/auth_login_request.dart';
import 'package:mvvm/utils/result.dart';

abstract class AuthRepository {
  Future<Result<AuthResponse>> login(AuthLoginRequest dadosLogin);
  Future<Result<void>> logout();
}
