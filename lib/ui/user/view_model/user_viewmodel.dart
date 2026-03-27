import 'package:flutter/material.dart';
import 'package:mvvm/data/repositories/user/user_repository.dart';
import 'package:mvvm/domain/models/user/user.dart';
import 'package:mvvm/utils/command.dart';
import 'package:mvvm/utils/result.dart';

class UserViewModel extends ChangeNotifier {
  UserViewModel({required UserRepository userRepository})
    : _repository = userRepository {
    loadUsersCommand = Command0(loadUsers);
    getUserByIdCommand = Command1(getUserById);
    createUserCommand = Command1(createUser);
    updateUserCommand = Command1(updateUser);
    deleteUserCommand = Command1(deleteUser);
  }

  final UserRepository _repository;

  late Command0<List<User>> loadUsersCommand;
  late Command1<User, int> getUserByIdCommand;
  late Command1<User, User> createUserCommand;
  late Command1<User, User> updateUserCommand;
  late Command1<void, int> deleteUserCommand;

  List<User> users = [];

  Future<Result<List<User>>> loadUsers() async {
    final result = await _repository.getAll();

    switch (result) {
      case Ok(value: final data):
        users = data;
        notifyListeners();
        return Result.ok(data);

      case Failure(error: final e):
        return Result.error(e);
    }
  }

  Future<Result<User>> getUserById(int id) async {
    final result = await _repository.getById(id);

    switch (result) {
      case Ok(value: final user):
        notifyListeners();
        return Result.ok(user);

      case Failure(error: final e):
        return Result.error(e);
    }
  }

  Future<Result<User>> createUser(User user) async {
    final result = await _repository.create(user);

    switch (result) {
      case Ok(value: final userCreated):
        users.add(userCreated);
        notifyListeners();
        return Result.ok(userCreated);

      case Failure(error: final e):
        return Result.error(e);
    }
  }

  Future<Result<User>> updateUser(User user) async {
    final result = await _repository.update(user);

    switch (result) {
      case Ok(value: final updated):
        final index = users.indexWhere((u) => u.id == updated.id);

        if (index != -1) {
          users[index] = updated;
          users = List.from(users);
        }

        notifyListeners();
        return Result.ok(updated);

      case Failure(error: final e):
        return Result.error(e);
    }
  }

  Future<Result<void>> deleteUser(int id) async {
    final result = await _repository.delete(id);

    switch (result) {
      case Ok():
        users.removeWhere((u) => u.id == id);
        notifyListeners();
        return Result.ok(null);

      case Failure(error: final e):
        return Result.error(e);
    }
  }
}
