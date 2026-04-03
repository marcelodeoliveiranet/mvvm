import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/ui/auth/logout/view_model/logout_viewmodel.dart';
import 'package:mvvm/utils/result.dart';

import '../../../../mocks/mock_auth_repository.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LogoutViewmodel viewModel;

  setUp(() {
    mockRepository = MockAuthRepository();
    viewModel = LogoutViewmodel(authRepository: mockRepository);
  });

  group('LogoutViewmodel', () {
    test('logoutCommand deve existir após inicialização', () {
      expect(viewModel.logoutCommand, isNotNull);
    });

    test('logout deve retornar Ok no sucesso', () async {
      mockRepository.logoutResult = Result.ok(null);

      final result = await viewModel.logout();

      expect(result, isA<Ok>());
      expect(mockRepository.logoutCallCount, 1);
    });

    test('logout deve retornar Failure no erro', () async {
      mockRepository.logoutResult = Result.error(Exception('falhou'));

      final result = await viewModel.logout();

      expect(result, isA<Failure>());
    });

    test('logoutCommand.execute deve atualizar estado', () async {
      mockRepository.logoutResult = Result.ok(null);

      await viewModel.logoutCommand.execute();

      expect(viewModel.logoutCommand.completed, true);
    });

    test('logoutCommand.execute deve setar error no erro', () async {
      mockRepository.logoutResult = Result.error(Exception('erro'));

      await viewModel.logoutCommand.execute();

      expect(viewModel.logoutCommand.error, true);
    });
  });
}
