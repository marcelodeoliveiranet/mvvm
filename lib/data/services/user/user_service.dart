import 'package:dio/dio.dart';
import 'package:mvvm/core/errors/dio_error_handler.dart';
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
      throw DioErrorHandler.handle(e);
    }
  }

  Future<User> getById(int id) async {
    try {
      final response = await _dio.get("$endPoint/$id");
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<User> create(User user) async {
    try {
      final response = await _dio.post(endPoint, data: user.toJson());

      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<User> update(int id, User user) async {
    try {
      final response = await _dio.put("$endPoint/$id", data: user.toJson());

      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> detele(int id) async {
    try {
      await _dio.delete("$endPoint/$id");
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
