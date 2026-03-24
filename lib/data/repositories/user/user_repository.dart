import 'package:mvvm/domain/models/user/user.dart';
import 'package:mvvm/utils/result.dart';

abstract class UserRepository {
  Future<Result<List<User>>> getAll();
  Future<Result<User>> getById(int id);
  Future<Result<User>> create(User user);
  Future<Result<User>> update(User user);
  Future<Result<void>> delete(int id);
}
