import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/core/errors/dio_error_handler.dart';
import 'package:mvvm/core/exceptions/http_exception.dart';
import 'package:mvvm/core/exceptions/network_exception.dart';
import 'package:mvvm/core/exceptions/unknown_exception.dart';

void main() {
  final requestOptions = RequestOptions(
    path: '/test',
    receiveTimeout: const Duration(seconds: 20),
  );

  group('DioErrorHandler - Timeouts', () {
    test('connectionTimeout deve retornar NetworkException', () {
      final error = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: requestOptions,
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<NetworkException>());
      expect(result.message, contains('20 segundos'));
    });

    test('sendTimeout deve retornar NetworkException', () {
      final error = DioException(
        type: DioExceptionType.sendTimeout,
        requestOptions: requestOptions,
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<NetworkException>());
    });

    test('receiveTimeout deve retornar NetworkException', () {
      final error = DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: requestOptions,
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<NetworkException>());
    });
  });

  group('DioErrorHandler - Network errors', () {
    test('connectionError deve retornar NetworkException sem internet', () {
      final error = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: requestOptions,
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<NetworkException>());
      expect(result.message, contains('Sem conexão'));
    });

    test('cancel deve retornar NetworkException cancelada', () {
      final error = DioException(
        type: DioExceptionType.cancel,
        requestOptions: requestOptions,
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<NetworkException>());
      expect(result.message, contains('cancelada'));
    });
  });

  group('DioErrorHandler - HTTP errors', () {
    test('400 deve retornar BadRequestException', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: requestOptions,
        response: Response(
          statusCode: 400,
          requestOptions: requestOptions,
          data: {'message': 'Dados inválidos'},
        ),
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<BadRequestException>());
      expect(result.message, 'Dados inválidos');
      expect(result.statusCode, 400);
    });

    test('401 deve retornar UnauthorizedException', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: requestOptions,
        response: Response(
          statusCode: 401,
          requestOptions: requestOptions,
          data: {'message': 'Não autorizado'},
        ),
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<UnauthorizedException>());
      expect(result.statusCode, 401);
    });

    test('403 deve retornar ForbiddenException', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: requestOptions,
        response: Response(
          statusCode: 403,
          requestOptions: requestOptions,
          data: {'message': 'Proibido'},
        ),
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<ForbiddenException>());
      expect(result.statusCode, 403);
    });

    test('404 deve retornar NotFoundException', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: requestOptions,
        response: Response(
          statusCode: 404,
          requestOptions: requestOptions,
          data: {'message': 'Não encontrado'},
        ),
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<NotFoundException>());
      expect(result.statusCode, 404);
    });

    test('422 deve retornar ValidationException', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: requestOptions,
        response: Response(
          statusCode: 422,
          requestOptions: requestOptions,
          data: {'message': 'Validação falhou'},
        ),
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<ValidationException>());
      expect(result.statusCode, 422);
    });

    test('500 deve retornar ServerException', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: requestOptions,
        response: Response(
          statusCode: 500,
          requestOptions: requestOptions,
          data: {'message': 'Erro interno'},
        ),
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<ServerException>());
    });

    test('502 deve retornar ServerException', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: requestOptions,
        response: Response(
          statusCode: 502,
          requestOptions: requestOptions,
        ),
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<ServerException>());
    });

    test('503 deve retornar ServerException', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: requestOptions,
        response: Response(
          statusCode: 503,
          requestOptions: requestOptions,
        ),
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<ServerException>());
    });

    test('status desconhecido deve retornar HttpException genérica', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: requestOptions,
        response: Response(
          statusCode: 418,
          requestOptions: requestOptions,
        ),
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<HttpException>());
      expect(result.statusCode, 418);
    });
  });

  group('DioErrorHandler - Extração de mensagem', () {
    test('deve extrair mensagem do campo message', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: requestOptions,
        response: Response(
          statusCode: 400,
          requestOptions: requestOptions,
          data: {'message': 'Campo obrigatório'},
        ),
      );

      final result = DioErrorHandler.handle(error);
      expect(result.message, 'Campo obrigatório');
    });

    test('deve extrair mensagem do campo errors', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: requestOptions,
        response: Response(
          statusCode: 422,
          requestOptions: requestOptions,
          data: {
            'errors': {
              'email': ['Email inválido'],
            },
          },
        ),
      );

      final result = DioErrorHandler.handle(error);
      expect(result.message, 'Email inválido');
    });

    test('deve retornar mensagem padrão quando data é null', () {
      final error = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: requestOptions,
        response: Response(
          statusCode: 400,
          requestOptions: requestOptions,
          data: null,
        ),
      );

      final result = DioErrorHandler.handle(error);
      expect(result.message, contains('Erro HTTP'));
    });
  });

  group('DioErrorHandler - Unknown', () {
    test('tipo unknown deve retornar UnknownException', () {
      final error = DioException(
        type: DioExceptionType.unknown,
        requestOptions: requestOptions,
        message: 'Algo deu errado',
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<UnknownException>());
      expect(result.message, 'Algo deu errado');
    });

    test('tipo unknown sem mensagem deve usar mensagem padrão', () {
      final error = DioException(
        type: DioExceptionType.unknown,
        requestOptions: requestOptions,
      );

      final result = DioErrorHandler.handle(error);

      expect(result, isA<UnknownException>());
      expect(result.message, 'Erro inesperado');
    });
  });
}
