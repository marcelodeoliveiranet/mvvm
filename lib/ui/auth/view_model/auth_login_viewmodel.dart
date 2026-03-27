import 'package:flutter/foundation.dart';
import 'package:mvvm/data/repositories/auth/auth_repository.dart';
import 'package:mvvm/domain/models/auth/auth_login_request.dart';
import 'package:mvvm/domain/models/auth/auth_response.dart';
import 'package:mvvm/ui/auth/view_model/auth_view_model.dart';
import 'package:mvvm/utils/command.dart';
import 'package:mvvm/utils/result.dart';

class AuthLoginViewModel extends ChangeNotifier {
  AuthLoginViewModel({
    required AuthRepository authRepository,
    required AuthViewModel authViewModel,
  }) : _authRepository = authRepository,
       _authViewModel = authViewModel {
    loginCommand = Command1(login);
    logoutCommand = Command0(logout);
  }

  final AuthRepository _authRepository;
  final AuthViewModel _authViewModel;

  late Command1<void, AuthLoginRequest> loginCommand;
  late Command0<void> logoutCommand;

  Future<Result<void>> login(AuthLoginRequest dadosLogin) async {
    final result = await _authRepository.login(dadosLogin);

    switch (result) {
      case Ok<AuthResponse>():
        _authViewModel.setLoggedIn();
        notifyListeners();
        return Result.ok(null);

      case Failure<AuthResponse>(error: final e):
        notifyListeners();
        return Result.error(e);
    }
  }

  Future<Result<void>> logout() async {
    final result = await _authRepository.logout();

    switch (result) {
      case Ok():
        _authViewModel.setLoggedOut();
        notifyListeners();
        return Result.ok(null);

      case Failure(error: final e):
        notifyListeners();
        return Result.error(e);
    }
  }
}
