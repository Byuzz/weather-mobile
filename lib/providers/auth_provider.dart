import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  // Inisialisasi Secure Storage
  final _storage = const FlutterSecureStorage();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;

  // Cek status login saat aplikasi dibuka
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Baca data dari Secure Storage
      final isLoggedIn = await _storage.read(key: 'is_logged_in');
      final username = await _storage.read(key: 'username');

      if (isLoggedIn == 'true' && username != null) {
        _isAuthenticated = true;
        _user = {'username': username};
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulasi delay request network
      await Future.delayed(const Duration(seconds: 2));

      // VALIDASI LOGIN SEMENTARA
      if (username.isNotEmpty && password.length >= 6) {
        _isAuthenticated = true;
        _user = {'username': username};
        
        // SIMPAN KE SECURE STORAGE (Persisten walau cache dihapus)
        await _storage.write(key: 'is_logged_in', value: 'true');
        await _storage.write(key: 'username', value: username);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid username or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _user = null;
    
    // HAPUS SEMUA DATA DARI SECURE STORAGE
    await _storage.deleteAll();
    
    notifyListeners();
  }
  
  Future<bool> register(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _isLoading = false;
    notifyListeners();
    return true; 
  }
}