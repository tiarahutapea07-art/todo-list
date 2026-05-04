import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get errorMessage => _errorMessage;
  String? get token => _token;

  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _errorMessage = 'Username dan password tidak boleh kosong';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://dummyjson.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = data['accessToken'];

        _user = UserModel(
          name: '${data['firstName']} ${data['lastName']}',
          email: data['email'],
        );

        return true;
      } else {
        _errorMessage = data['message'] ?? 'Login gagal';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Tidak bisa terhubung ke API';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    _token = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
