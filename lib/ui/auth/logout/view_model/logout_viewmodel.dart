import 'package:mvvm/data/repositories/auth/auth_repository.dart';
import 'package:mvvm/utils/command.dart';
import 'package:mvvm/utils/result.dart';

class LogoutViewmodel {
  LogoutViewmodel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    logoutCommand = Command0(logout);
  }

  final AuthRepository _authRepository;
  late Command0<void> logoutCommand;

  Future<Result<void>> logout() async {
    return await _authRepository.logout();
  }
}
