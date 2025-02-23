import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;

  String? get token => _token;
  String? get userId => _userId;

  void setAuthData(String token, String userId) {
    _token = token;
    _userId = userId;
    notifyListeners();
  }

  void clearAuthData() {
    _token = null;
    _userId = null;
    notifyListeners();
  }

}