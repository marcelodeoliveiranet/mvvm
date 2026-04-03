import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mvvm/core/exceptions/http_exception.dart';
import 'package:mvvm/data/services/auth/auth_service.dart';
import 'package:mvvm/domain/models/auth/auth_login_request.dart';
import 'package:mvvm/domain/models/auth/auth_refresh_token.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late AuthService authService;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/'));
    dioAdapter = DioAdapter(dio: dio);
    authService = AuthService(dio);
  });

  group('AuthService - login', () {
    final request = AuthLoginRequest(email: 'test@email.com', senha: '123456');

    test('deve retornar AuthResponse no sucesso', () async {
      dioAdapter.onPost(
        'auth/login',
        (server) => server.reply(200, {
          'accessToken': 'access123',
          'refreshToken': 'refresh456',
        }),
        data: request.toJson(),
      );

      final response = await authService.login(request);

      expect(response.accessToken, 'access123');
      expect(response.refreshToken, 'refresh456');
    });

    test('deve lançar BadRequestException em erro 400', () async {
      dioAdapter.onPost(
        'auth/login',
        (server) => server.reply(400, {'message': 'Credenciais inválidas'}),
        data: request.toJson(),
      );

      expect(
        () => authService.login(request),
        throwsA(isA<BadRequestException>()),
      );
    });

    test('deve lançar UnauthorizedException em erro 401', () async {
      dioAdapter.onPost(
        'auth/login',
        (server) => server.reply(401, {'message': 'Não autorizado'}),
        data: request.toJson(),
      );

      expect(
        () => authService.login(request),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });

  group('AuthService - refresh', () {
    final refreshToken = AuthRefreshToken(refreshToken: 'myRefreshToken');

    test('deve retornar AuthResponse no sucesso', () async {
      dioAdapter.onPost(
        'auth/login',
        (server) => server.reply(200, {
          'accessToken': 'newAccess',
          'refreshToken': 'newRefresh',
        }),
        data: refreshToken.toJson(),
      );

      final response = await authService.refresh(refreshToken);

      expect(response.accessToken, 'newAccess');
      expect(response.refreshToken, 'newRefresh');
    });

    test('deve lançar exceção em erro', () async {
      dioAdapter.onPost(
        'auth/login',
        (server) => server.reply(500, {'message': 'Erro interno'}),
        data: refreshToken.toJson(),
      );

      expect(
        () => authService.refresh(refreshToken),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
