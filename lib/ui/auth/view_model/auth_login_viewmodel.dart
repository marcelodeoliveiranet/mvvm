import 'package:flutter/foundation.dart';
import 'package:mvvm/data/repositories/auth/auth_repository.dart';
import 'package:mvvm/domain/models/auth/auth_login_request.dart';
import 'package:mvvm/domain/models/auth/auth_response.dart';
import 'package:mvvm/utils/result.dart';
import 'package:mvvm/utils/view_model_state.dart';

class AuthLoginViewModel extends ChangeNotifier {
  AuthLoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  ViewModelState state = ViewModelState.idle;
  String? errorMessage;

  Future<bool> login(AuthLoginRequest dadosLogin) async {
    state = ViewModelState.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _authRepository.login(dadosLogin);

    switch (result) {
      case Ok<AuthResponse>():
        state = ViewModelState.success;
        notifyListeners();
        return true;

      case Error<AuthResponse>(error: final e):
        state = ViewModelState.error;
        errorMessage = e.toString();
        notifyListeners();
        return false;
    }
  }

  Future<void> logout() async {
    errorMessage = null;
    notifyListeners();

    final result = await _authRepository.logout();

    switch (result) {
      case Ok():
        state = ViewModelState.success;
        break;
      case Error(error: final e):
        state = ViewModelState.error;
        errorMessage = e.toString();
    }

    notifyListeners();
  }
}
