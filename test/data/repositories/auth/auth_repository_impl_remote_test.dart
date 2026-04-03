import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/core/exceptions/app_exception.dart';
import 'package:mvvm/data/repositories/auth/auth_repository_impl_remote.dart';
import 'package:mvvm/domain/models/auth/auth_login_request.dart';
import 'package:mvvm/domain/models/auth/auth_response.dart';
import 'package:mvvm/utils/result.dart';

import '../../../mocks/mock_auth_service.dart';
import '../../../mocks/mock_shared_preferences_service.dart';

void main() {
  late MockAuthService mockService;
  late MockSharedPreferencesService mockStorage;
  late AuthRepositoryImplRemote repository;

  setUp(() {
    mockService = MockAuthService();
    mockStorage = MockSharedPreferencesService();
    repository = AuthRepositoryImplRemote(
      authService: mockService,
      authLocalService: mockStorage,
    );
  });

  final loginRequest = AuthLoginRequest(email: 'test@email.com', senha: '123456');
  final authResponse = AuthResponse(accessToken: 'access', refreshToken: 'refresh');

  group('AuthRepositoryImplRemote - estado inicial', () {
    test('isLoggedIn deve ser false inicialmente', () {
      expect(repository.isLoggedIn, false);
    });
  });

  group('AuthRepositoryImplRemote - login', () {
    test('deve retornar Ok e setar isLoggedIn=true no sucesso', () async {
      mockService.loginResult = authResponse;

      final result = await repository.login(loginRequest);

      expect(result, isA<Ok<AuthResponse>>());
      expect((result as Ok<AuthResponse>).value.accessToken, 'access');
      expect(repository.isLoggedIn, true);
    });

    test('deve salvar tokens no storage no sucesso', () async {
      mockService.loginResult = authResponse;

      await repository.login(loginRequest);

      expect(mockStorage.saveCallCount, 1);
      expect(mockStorage.accessToken, 'access');
      expect(mockStorage.refreshToken, 'refresh');
    });

    test('deve retornar Failure e setar isLoggedIn=false no erro', () async {
      mockService.loginError = AppException(message: 'Credenciais inválidas');

      final result = await repository.login(loginRequest);

      expect(result, isA<Failure<AuthResponse>>());
      expect(repository.isLoggedIn, false);
    });

    test('deve notificar listeners no sucesso', () async {
      mockService.loginResult = authResponse;
      var notified = false;
      repository.addListener(() => notified = true);

      await repository.login(loginRequest);

      expect(notified, true);
    });

    test('deve notificar listeners no erro', () async {
      mockService.loginError = Exception('falhou');
      var notified = false;
      repository.addListener(() => notified = true);

      await repository.login(loginRequest);

      expect(notified, true);
    });
  });

  group('AuthRepositoryImplRemote - logout', () {
    test('deve retornar Ok e setar isLoggedIn=false no sucesso', () async {
      // Primeiro faz login
      mockService.loginResult = authResponse;
      await repository.login(loginRequest);
      expect(repository.isLoggedIn, true);

      // Depois faz logout
      final result = await repository.logout();

      expect(result, isA<Ok<void>>());
      expect(repository.isLoggedIn, false);
    });

    test('deve limpar storage no logout', () async {
      mockService.loginResult = authResponse;
      await repository.login(loginRequest);

      await repository.logout();

      expect(mockStorage.clearCallCount, 1);
      expect(mockStorage.accessToken, isNull);
      expect(mockStorage.refreshToken, isNull);
    });

    test('deve notificar listeners no logout', () async {
      var notifyCount = 0;
      repository.addListener(() => notifyCount++);

      await repository.logout();

      expect(notifyCount, greaterThan(0));
    });
  });
}
