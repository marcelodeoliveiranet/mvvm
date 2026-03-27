import 'package:mvvm/core/exceptions/app_exception.dart';
import 'package:mvvm/data/repositories/user/user_repository.dart';
import 'package:mvvm/data/services/user/user_service.dart';
import 'package:mvvm/domain/models/user/user.dart';
import 'package:mvvm/utils/result.dart';

class UserRepositoryImplRemote implements UserRepository {
  UserRepositoryImplRemote(UserService service) : _service = service;

  final UserService _service;

  @override
  Future<Result<List<User>>> getAll() async {
    try {
      final user = await _service.getAll();
      return Result.ok(user);
    } catch (e) {
      return Result.error(AppException(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> getById(int id) async {
    try {
      final user = await _service.getById(id);
      return Result.ok(user);
    } catch (e) {
      return Result.error(AppException(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> create(User user) async {
    try {
      final created = await _service.create(user);
      return Result.ok(created);
    } catch (e) {
      return Result.error(AppException(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> update(User user) async {
    try {
      final updated = await _service.update(user.id!, user);
      return Result.ok(updated);
    } catch (e) {
      return Result.error(AppException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> delete(int id) async {
    try {
      await _service.detele(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(AppException(message: e.toString()));
    }
  }
}
