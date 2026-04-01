import 'package:mvvm/data/repositories/auth/auth_repository.dart';
import 'package:mvvm/domain/models/auth/auth_login_request.dart';
import 'package:mvvm/utils/command.dart';
import 'package:mvvm/utils/result.dart';

class LoginViewmodel {
  LoginViewmodel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    loginCommand = Command1(login);
  }

  final AuthRepository _authRepository;
  late Command1<void, AuthLoginRequest> loginCommand;

  Future<Result<void>> login(AuthLoginRequest dadosLogin) async {
    return await _authRepository.login(dadosLogin);
  }
}
