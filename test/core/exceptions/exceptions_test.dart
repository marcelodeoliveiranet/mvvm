import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/core/exceptions/app_exception.dart';
import 'package:mvvm/core/exceptions/http_exception.dart';
import 'package:mvvm/core/exceptions/network_exception.dart';
import 'package:mvvm/core/exceptions/unknown_exception.dart';

void main() {
  group('AppException', () {
    test('deve criar com mensagem', () {
      const e = AppException(message: 'erro');
      expect(e.message, 'erro');
      expect(e.statusCode, isNull);
      expect(e.data, isNull);
    });

    test('deve criar com todos os campos', () {
      const e = AppException(message: 'erro', statusCode: 500, data: 'dados');
      expect(e.statusCode, 500);
      expect(e.data, 'dados');
    });

    test('toString deve retornar a mensagem', () {
      const e = AppException(message: 'minha mensagem');
      expect(e.toString(), 'minha mensagem');
    });

    test('deve implementar Exception', () {
      const e = AppException(message: 'teste');
      expect(e, isA<Exception>());
    });
  });

  group('HttpException', () {
    test('BadRequestException deve ter statusCode 400', () {
      const e = BadRequestException(message: 'bad');
      expect(e.statusCode, 400);
      expect(e, isA<HttpException>());
      expect(e, isA<AppException>());
    });

    test('UnauthorizedException deve ter statusCode 401', () {
      const e = UnauthorizedException(message: 'unauth');
      expect(e.statusCode, 401);
    });

    test('ForbiddenException deve ter statusCode 403', () {
      const e = ForbiddenException(message: 'forbidden');
      expect(e.statusCode, 403);
    });

    test('NotFoundException deve ter statusCode 404', () {
      const e = NotFoundException(message: 'not found');
      expect(e.statusCode, 404);
    });

    test('ValidationException deve ter statusCode 422', () {
      const e = ValidationException(message: 'invalid');
      expect(e.statusCode, 422);
    });

    test('ServerException deve ter statusCode 500', () {
      const e = ServerException(message: 'server error');
      expect(e.statusCode, 500);
    });

    test('BadRequestException deve aceitar data', () {
      const e = BadRequestException(message: 'bad', data: {'field': 'error'});
      expect(e.data, {'field': 'error'});
    });
  });

  group('NetworkException', () {
    test('timeout deve criar instância', () {
      final e = NetworkException.timeout(message: 'timeout msg');
      expect(e, isA<NetworkException>());
      expect(e.message, 'timeout msg');
    });

    test('noInternet deve criar instância', () {
      final e = NetworkException.noInternet(message: 'sem internet');
      expect(e, isA<NetworkException>());
      expect(e.message, 'sem internet');
    });

    test('cancelled deve criar instância', () {
      final e = NetworkException.cancelled(message: 'cancelado');
      expect(e, isA<NetworkException>());
      expect(e.message, 'cancelado');
    });

    test('deve ser subclasse de AppException', () {
      final e = NetworkException(message: 'test');
      expect(e, isA<AppException>());
    });
  });

  group('UnknownException', () {
    test('deve criar com mensagem', () {
      const e = UnknownException(message: 'desconhecido');
      expect(e.message, 'desconhecido');
      expect(e, isA<AppException>());
    });
  });
}
