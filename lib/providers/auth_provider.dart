import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get errorMessage => _errorMessage;
  String? get token => _token;

  AuthProvider() {
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('saved_user_profile');
      if (userJson != null) {
        _user = UserModel.fromJson(userJson);
        notifyListeners();
        return;
      }

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        _user = UserModel(
          name: currentUser.displayName ??
              currentUser.email?.split('@').first ??
              'User',
          email: currentUser.email ?? '',
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user session: $e');
    }
  }

  Future<void> _saveUserSession(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_user_profile', user.toJson());
    } catch (e) {
      debugPrint('Error saving user session: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Email dan password tidak boleh kosong';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser != null) {
        // Cek jika ada profil tersimpan sebelumnya untuk email ini
        final prefs = await SharedPreferences.getInstance();
        final savedJson = prefs.getString('saved_user_profile');
        if (savedJson != null) {
          final savedModel = UserModel.fromJson(savedJson);
          if (savedModel.email.toLowerCase() == email.toLowerCase()) {
            _user = savedModel;
          } else {
            _user = UserModel(
              name: firebaseUser.displayName ??
                  firebaseUser.email?.split('@').first ??
                  'User',
              email: firebaseUser.email ?? email,
            );
          }
        } else {
          _user = UserModel(
            name: firebaseUser.displayName ??
                firebaseUser.email?.split('@').first ??
                'User',
            email: firebaseUser.email ?? email,
          );
        }

        await _saveUserSession(_user!);
        _token = await firebaseUser.getIdToken();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Login gagal';
      return false;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Akun belum terdaftar. Silakan daftar terlebih dahulu.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          _errorMessage = 'Email atau password salah';
          break;
        case 'invalid-email':
          _errorMessage = 'Format email tidak valid';
          break;
        case 'too-many-requests':
          _errorMessage = 'Terlalu banyak percobaan login, coba lagi nanti';
          break;
        case 'network-request-failed':
          _errorMessage = 'Gagal terhubung ke jaringan. Periksa koneksi internet Anda.';
          break;
        default:
          _errorMessage = e.message ?? 'Login gagal';
      }
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty) {
      _errorMessage = 'Nama lengkap harus diisi';
      notifyListeners();
      return false;
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      _errorMessage = 'Format email tidak valid';
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      _errorMessage = 'Password minimal 6 karakter';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        try {
          await firebaseUser.updateDisplayName(name.trim());
        } catch (_) {}

        _user = UserModel(
          name: name.trim(),
          email: email.trim(),
        );

        await _saveUserSession(_user!);
        _token = await firebaseUser.getIdToken();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Pendaftaran gagal';
      return false;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = 'Email sudah terdaftar. Silakan login.';
          break;
        case 'invalid-email':
          _errorMessage = 'Format email tidak valid';
          break;
        case 'weak-password':
          _errorMessage = 'Password terlalu lemah (minimal 6 karakter)';
          break;
        case 'network-request-failed':
          _errorMessage = 'Gagal terhubung ke jaringan';
          break;
        default:
          _errorMessage = e.message ?? 'Pendaftaran gagal';
      }
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Demo Login instan untuk kemudahan testing / presentasi
  Future<bool> quickDemoLogin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    // Cek apakah ada session yang disimpan
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getString('saved_user_profile');

    if (savedJson != null) {
      _user = UserModel.fromJson(savedJson);
    } else {
      _user = UserModel(
        name: 'Alex Johnson',
        email: 'alex.johnson@taskflow.dev',
        phone: '+62 812-3456-7890',
        bio: 'Mobile App Developer & Tech Enthusiast',
        avatarUrl: 'avatar:dimas',
      );
      await _saveUserSession(_user!);
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Update profil user yang tersinkronisasi dan disimpan lokal
  Future<bool> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? bio,
    String? avatarUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = UserModel(
        name: name.trim(),
        email: email.trim(),
        phone: (phone ?? _user?.phone ?? '').trim(),
        bio: (bio ?? _user?.bio ?? '').trim(),
        avatarUrl: avatarUrl ?? _user?.avatarUrl ?? 'https://i.pravatar.cc/150?img=3',
      );

      await _saveUserSession(_user!);

      // Update Firebase Auth profile jika sedang login di Firebase
      try {
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          await currentUser.updateDisplayName(name.trim());
        }
      } catch (e) {
        debugPrint('Catatan update Firebase: $e');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyimpan profil: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      _errorMessage = 'Masukkan email untuk reset password';
      notifyListeners();
      return false;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengirim email reset: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_user_profile');

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
