import 'package:mvvm/core/exceptions/app_exception.dart';

class HttpException extends AppException {
  const HttpException({required super.message, super.statusCode, super.data});
}

class BadRequestException extends HttpException {
  const BadRequestException({required super.message, super.data})
    : super(statusCode: 400);
}

class UnauthorizedException extends HttpException {
  const UnauthorizedException({required super.message})
    : super(statusCode: 401);
}

class ForbiddenException extends HttpException {
  const ForbiddenException({required super.message}) : super(statusCode: 403);
}

class NotFoundException extends HttpException {
  const NotFoundException({required super.message}) : super(statusCode: 404);
}

class ValidationException extends HttpException {
  const ValidationException({required super.message, super.data})
    : super(statusCode: 422);
}

class ServerException extends HttpException {
  const ServerException({required super.message}) : super(statusCode: 500);
}
