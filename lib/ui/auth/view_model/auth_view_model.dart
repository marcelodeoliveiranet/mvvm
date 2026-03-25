import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoggedIn = false;

  void setLoggedIn() {
    isLoggedIn = true;
    notifyListeners();
  }

  void setLoggedOut() {
    isLoggedIn = false;
    notifyListeners();
  }
}
