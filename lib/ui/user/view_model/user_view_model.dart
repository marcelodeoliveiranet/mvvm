import 'package:flutter/material.dart';
import 'package:mvvm/data/repositories/user/user_repository.dart';
import 'package:mvvm/domain/models/user/user.dart';
import 'package:mvvm/utils/result.dart';

class UserViewModel extends ChangeNotifier {
  UserViewModel(UserRepository repository) : _repository = repository;

  final UserRepository _repository;

  List<User> users = [];
  User? selectedUser;

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadUsers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _repository.getAll();

    switch (result) {
      case Ok(value: final data):
        users = data;

      case Error(error: final e):
        errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> getUserById(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _repository.getById(id);

    switch (result) {
      case Ok(value: final user):
        selectedUser = user;

      case Error(error: final e):
        errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> createUser(User user) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _repository.create(user);

    switch (result) {
      case Ok(value: final created):
        users.add(created);
      case Error(error: final e):
        errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _repository.update(user);

    switch (result) {
      case Ok(value: final updated):
        final index = users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          users[index] = updated;
        }

      case Error(error: final e):
        errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteUser(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _repository.delete(id);

    switch (result) {
      case Ok():
        users.removeWhere((u) => u.id == id);

      case Error(error: final e):
        errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
