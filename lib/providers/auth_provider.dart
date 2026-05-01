import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    // validasi kosong
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Email dan password tidak boleh kosong';
      notifyListeners();
      return false;
    }

    // validasi format email
    if (!email.contains('@')) {
      _errorMessage = 'Format email tidak valid';
      notifyListeners();
      return false;
    }

    // validasi panjang password
    if (password.length < 6) {
      _errorMessage = 'Password minimal 6 karakter';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // simulasi API call (nanti ganti dengan http request ke backend)
    await Future.delayed(const Duration(seconds: 1));

    // simulasi login berhasil — nanti diganti response dari API
    _user = UserModel(
      name: 'Erik Smith',
      email: email,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}