import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/domain/models/auth/auth_login_request.dart';
import 'package:mvvm/domain/models/auth/auth_response.dart';
import 'package:mvvm/ui/auth/login/view_model/login_viewmodel.dart';
import 'package:mvvm/utils/result.dart';

import '../../../../mocks/mock_auth_repository.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LoginViewmodel viewModel;

  setUp(() {
    mockRepository = MockAuthRepository();
    viewModel = LoginViewmodel(authRepository: mockRepository);
  });

  final loginRequest = AuthLoginRequest(email: 'test@email.com', senha: '123456');
  final authResponse = AuthResponse(accessToken: 'access', refreshToken: 'refresh');

  group('LoginViewmodel', () {
    test('loginCommand deve existir após inicialização', () {
      expect(viewModel.loginCommand, isNotNull);
    });

    test('login deve retornar Ok no sucesso', () async {
      mockRepository.loginResult = Result.ok(authResponse);

      final result = await viewModel.login(loginRequest);

      expect(result, isA<Ok>());
      expect(mockRepository.loginCallCount, 1);
    });

    test('login deve retornar Failure no erro', () async {
      mockRepository.loginResult = Result.error(Exception('falhou'));

      final result = await viewModel.login(loginRequest);

      expect(result, isA<Failure>());
    });

    test('loginCommand.execute deve atualizar estado', () async {
      mockRepository.loginResult = Result.ok(authResponse);

      await viewModel.loginCommand.execute(loginRequest);

      expect(viewModel.loginCommand.completed, true);
      expect(viewModel.loginCommand.error, false);
    });

    test('loginCommand.execute deve setar error no erro', () async {
      mockRepository.loginResult = Result.error(Exception('erro'));

      await viewModel.loginCommand.execute(loginRequest);

      expect(viewModel.loginCommand.error, true);
      expect(viewModel.loginCommand.completed, false);
    });
  });
}
