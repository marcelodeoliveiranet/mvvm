import 'package:mvvm/core/exceptions/app_exception.dart';

class NetworkException extends AppException {
  NetworkException({required super.message});

  factory NetworkException.timeout({required String message}) =>
      NetworkException(message: message);

  factory NetworkException.noInternet({required String message}) =>
      NetworkException(message: message);

  factory NetworkException.cancelled({required String message}) =>
      NetworkException(message: message);
}
