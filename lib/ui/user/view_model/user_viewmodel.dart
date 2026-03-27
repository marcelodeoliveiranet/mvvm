import 'package:flutter/material.dart';
import 'package:mvvm/data/repositories/user/user_repository.dart';
import 'package:mvvm/domain/models/user/user.dart';
import 'package:mvvm/utils/result.dart';
import 'package:mvvm/utils/view_model_state.dart';

class UserViewModel extends ChangeNotifier {
  UserViewModel({required UserRepository userRepository})
    : _repository = userRepository;

  final UserRepository _repository;

  List<User> users = [];
  User? selectedUser;

  ViewModelState state = ViewModelState.idle;
  String? errorMessage;

  Future<void> loadUsers() async {
    state = ViewModelState.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _repository.getAll();

    switch (result) {
      case Ok(value: final data):
        state = ViewModelState.success;
        users = data;

      case Error(error: final e):
        state = ViewModelState.error;
        errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> getUserById(int id) async {
    state = ViewModelState.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _repository.getById(id);

    switch (result) {
      case Ok(value: final user):
        state = ViewModelState.success;
        selectedUser = user;

      case Error(error: final e):
        state = ViewModelState.error;
        errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> createUser(User user) async {
    state = ViewModelState.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _repository.create(user);

    switch (result) {
      case Ok(value: final created):
        state = ViewModelState.success;
        users.add(created);

      case Error(error: final e):
        state = ViewModelState.error;
        errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    state = ViewModelState.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _repository.update(user);

    switch (result) {
      case Ok(value: final updated):
        state = ViewModelState.success;
        final index = users.indexWhere((u) => u.id == updated.id);
        if (index != -1) {
          users[index] = updated;
          users = users.map((u) {
            return u.id == updated.id ? updated : u;
          }).toList();
        }

      case Error(error: final e):
        state = ViewModelState.error;
        errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> deleteUser(int id) async {
    state = ViewModelState.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _repository.delete(id);

    switch (result) {
      case Ok():
        state = ViewModelState.success;
        users.removeWhere((u) => u.id == id);

      case Error(error: final e):
        state = ViewModelState.error;
        errorMessage = e.toString();
    }

    notifyListeners();
  }
}
