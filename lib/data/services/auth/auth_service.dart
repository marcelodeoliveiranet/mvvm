import 'package:dio/dio.dart';
import 'package:mvvm/core/errors/dio_error_handler.dart';
import 'package:mvvm/domain/models/auth/auth_login_request.dart';
import 'package:mvvm/domain/models/auth/auth_refresh_token.dart';
import 'package:mvvm/domain/models/auth/auth_response.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  final String endPoint = "auth/login";

  Future<AuthResponse> login(AuthLoginRequest dadosLogin) async {
    try {
      final response = await _dio.post(endPoint, data: dadosLogin.toJson());
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<AuthResponse> refresh(AuthRefreshToken refreshToken) async {
    try {
      final response = await _dio.post(endPoint, data: refreshToken.toJson());
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
