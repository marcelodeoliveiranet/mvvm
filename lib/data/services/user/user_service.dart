import 'package:dio/dio.dart';
import 'package:mvvm/core/exceptions/app_exception.dart';
import 'package:mvvm/domain/models/user/user.dart';

class UserService {
  final Dio _dio;

  UserService(this._dio);

  final String endPoint = "user";

  Future<List<User>> getAll() async {
    try {
      final response = await _dio.get(endPoint);
      final List data = response.data;
      return data.map((json) => User.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handlerError(e);
    }
  }

  Future<User> getById(int id) async {
    try {
      final response = await _dio.get("$endPoint/$id");
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handlerError(e);
    }
  }

  Future<User> create(User user) async {
    try {
      final response = await _dio.post(endPoint, data: user.toJson());

      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handlerError(e);
    }
  }

  Future<User> update(int id, User user) async {
    try {
      final response = await _dio.put("$endPoint/$id", data: user.toJson());

      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handlerError(e);
    }
  }

  Future<void> detele(int id) async {
    try {
      await _dio.delete("$endPoint/$id");
    } on DioException catch (e) {
      throw _handlerError(e);
    }
  }

  Exception _handlerError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return AppException(
          message: "Erro de timeout com o servidor: ${e.message}",
        );

      case DioExceptionType.receiveTimeout:
        return AppException(message: "Erro de receivetimeour: ${e.message}");

      case DioExceptionType.connectionError:
        return AppException(
          message: "Erro de conexão com o servidor: ${e.message}",
        );

      default:
        return AppException(message: "Erro critico: ${e.message}");
    }
  }
}
