import 'package:dio/dio.dart';
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
      throw _handlerError(e, "Erro ao buscar os usuários");
    }
  }

  Future<User> getById(int id) async {
    try {
      final response = await _dio.get("$endPoint/$id");
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handlerError(e, "Erro ao buscar o usuário");
    }
  }

  Future<User> create(User user) async {
    try {
      final response = await _dio.post(endPoint, data: user.toJson());

      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handlerError(e, "Erro ao criar o usuário");
    }
  }

  Future<User> update(int id, User user) async {
    try {
      final response = await _dio.put("$endPoint/$id", data: user.toJson());

      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handlerError(e, "Erro ao alterar o usuário");
    }
  }

  Future<void> detele(int id) async {
    try {
      await _dio.delete("$endPoint/$id");
    } on DioException catch (e) {
      throw _handlerError(e, "Erro ao excluir o usuário");
    }
  }

  Exception _handlerError(DioException e, String message) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception("$message: Timeout de conexão");

      case DioExceptionType.receiveTimeout:
        return Exception("$message: Timeout de resposta");

      case DioExceptionType.connectionError:
        return Exception("$message: Erro de conexão com o servidor");

      default:
        return Exception("$message: ${e.response?.data}");
    }
  }
}
