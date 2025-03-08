import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  int? _tokenTimestamp;

  String? get token => _token;
  String? get userId => _userId;

  void setAuthData(String token, String userId) {
    _token = token;
    _userId = userId;
    _tokenTimestamp = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  void clearAuthData() {
    _token = null;
    _userId = null;
    _tokenTimestamp = null;
    notifyListeners();
  }

  bool get isTokenExpired {
    if (_tokenTimestamp == null) return true;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final tokenAge = currentTime - _tokenTimestamp!;
    return tokenAge > 3600 * 1000;
  }

  bool get isAuthenticated {
    return _token != null && _userId != null && !isTokenExpired;
  }
}