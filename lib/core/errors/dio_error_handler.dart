import 'package:dio/dio.dart';
import 'package:mvvm/core/exceptions/app_exception.dart';

class DioErrorHandler {
  static AppException handle(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return AppException(
          message: "Erro de timeout com o servidor: ${e.message}",
        );

      case DioExceptionType.receiveTimeout:
        return AppException(message: "Erro de receive timeout: ${e.message}");

      case DioExceptionType.connectionError:
        return AppException(
          message: "Erro de conexão com o servidor: ${e.message}",
        );

      case DioExceptionType.badResponse:
        return AppException(
          message: "Erro na resposta: ${e.response?.statusCode}",
        );

      case DioExceptionType.cancel:
        return AppException(message: "Requisição cancelada");

      default:
        return AppException(message: "Erro inesperado: ${e.message}");
    }
  }
}
