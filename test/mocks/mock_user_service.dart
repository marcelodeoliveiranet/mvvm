import 'package:mvvm/data/services/user/user_service.dart';
import 'package:mvvm/domain/models/user/user.dart';

class MockUserService implements UserService {
  List<User>? getAllResult;
  Exception? getAllError;
  User? getByIdResult;
  Exception? getByIdError;
  User? createResult;
  Exception? createError;
  User? updateResult;
  Exception? updateError;
  Exception? deleteError;

  @override
  String get endPoint => 'user';

  @override
  Future<List<User>> getAll() async {
    if (getAllError != null) throw getAllError!;
    return getAllResult!;
  }

  @override
  Future<User> getById(int id) async {
    if (getByIdError != null) throw getByIdError!;
    return getByIdResult!;
  }

  @override
  Future<User> create(User user) async {
    if (createError != null) throw createError!;
    return createResult!;
  }

  @override
  Future<User> update(int id, User user) async {
    if (updateError != null) throw updateError!;
    return updateResult!;
  }

  @override
  Future<void> detele(int id) async {
    if (deleteError != null) throw deleteError!;
  }
}
