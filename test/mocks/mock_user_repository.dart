import 'package:mvvm/data/repositories/user/user_repository.dart';
import 'package:mvvm/domain/models/user/user.dart';
import 'package:mvvm/utils/result.dart';

class MockUserRepository implements UserRepository {
  Result<List<User>>? getAllResult;
  Result<User>? getByIdResult;
  Result<User>? createResult;
  Result<User>? updateResult;
  Result<void>? deleteResult;

  @override
  Future<Result<List<User>>> getAll() async => getAllResult!;

  @override
  Future<Result<User>> getById(int id) async => getByIdResult!;

  @override
  Future<Result<User>> create(User user) async => createResult!;

  @override
  Future<Result<User>> update(User user) async => updateResult!;

  @override
  Future<Result<void>> delete(int id) async => deleteResult!;
}
