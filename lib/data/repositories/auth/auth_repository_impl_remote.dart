// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import 'package:mvvm/core/exceptions/app_exception.dart';
import 'package:mvvm/core/storage/auth_stored/auth_stored.dart';
import 'package:mvvm/data/repositories/auth/auth_repository.dart';
import 'package:mvvm/data/services/auth/auth_service.dart';
import 'package:mvvm/domain/models/auth/auth_login_request.dart';
import 'package:mvvm/domain/models/auth/auth_response.dart';
import 'package:mvvm/utils/result.dart';

class AuthRepositoryImplRemote extends ChangeNotifier
    implements AuthRepository {
  AuthRepositoryImplRemote({
    required AuthService authService,
    required AuthStored authStored,
  }) : _service = authService,
       _storage = authStored;

  final AuthService _service;
  final AuthStored _storage;

  @override
  Future<Result<AuthResponse>> login(AuthLoginRequest dadosLogin) async {
    try {
      final response = await _service.login(dadosLogin);
      _isLoggedIn = true;
      await _storage.saveTokens(response.accessToken, response.refreshToken);
      return Result.ok(response);
    } catch (e) {
      _isLoggedIn = false;
      return Result.error(AppException(message: e.toString()));
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _storage.clear();
      _isLoggedIn = false;
      return Result.ok(null);
    } catch (e) {
      _isLoggedIn = false;
      return Result.error(AppException(message: e.toString()));
    } finally {
      notifyListeners();
    }
  }

  @override
  bool get isLoggedIn => _isLoggedIn;
  bool _isLoggedIn = false;
}
