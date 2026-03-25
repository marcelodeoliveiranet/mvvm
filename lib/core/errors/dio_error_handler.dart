import 'package:dio/dio.dart';
import 'package:mvvm/core/exceptions/http_exception.dart';
import 'package:mvvm/core/exceptions/network_exception.dart';
import 'package:mvvm/core/exceptions/app_exception.dart';
import 'package:mvvm/core/exceptions/unknown_exception.dart';

class DioErrorHandler {
  static AppException handle(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return _handleTimeout(e);

      case DioExceptionType.connectionError:
        return NetworkException.noInternet(
          message: "Sem conexão com a internet",
        );

      case DioExceptionType.cancel:
        return NetworkException.cancelled(message: "Requisição cancelada");

      case DioExceptionType.badResponse:
        return _handleHttpError(e);

      case DioExceptionType.unknown:
      default:
        return UnknownException(message: e.message ?? "Erro inesperado");
    }
  }

  static AppException _handleTimeout(DioException e) {
    final timeout = e.requestOptions.receiveTimeout;

    final seconds = timeout?.inSeconds ?? 0;

    return NetworkException.timeout(
      message:
          "O servidor demorou mais de $seconds segundos para responder. Verifique sua conexão e tente novamente.",
    );
  }

  static AppException _handleHttpError(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    final message = _extractMessage(data, statusCode);

    switch (statusCode) {
      case 400:
        return BadRequestException(message: message, data: data);

      case 401:
        return UnauthorizedException(message: message);

      case 403:
        return ForbiddenException(message: message);

      case 404:
        return NotFoundException(message: message);

      case 422:
        return ValidationException(message: message, data: data);

      case 500:
      case 502:
      case 503:
        return ServerException(message: message);

      default:
        return HttpException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
    }
  }

  static String _extractMessage(dynamic data, int? statusCode) {
    if (data == null) {
      return "Erro HTTP ${statusCode ?? ''}";
    }

    if (data is Map<String, dynamic>) {
      if (data["message"] != null) return data["message"];

      if (data["errors"] != null) {
        final errors = data["errors"];
        if (errors is Map) {
          return errors.values.first.first.toString();
        }
      }
    }

    if (statusCode == null) {
      return "Erro HTTP";
    } else {
      return "Erro HTTP $statusCode - $data";
    }
  }
}
