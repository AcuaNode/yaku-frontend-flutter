import 'package:flutter/foundation.dart';
import '../domain/user.dart';
import '../utils/token_storage.dart';
import 'auth_service.dart' as svc;

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> tryRestoreSession() async {
    if (await TokenStorage.hasSession()) {
      final info = await TokenStorage.getUserInfo();
      final id = await TokenStorage.getUserId();
      _user = User(
        id: id ?? 0,
        username: info['username'] ?? '',
        firstName: info['firstName'] ?? '',
        lastName: info['lastName'] ?? '',
        email: info['email'] ?? '',
        role: info['role'] ?? 'ADMIN',
      );
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await svc.login(username, password);
      return true;
    } catch (e) {
      _error = 'Usuario o contraseña incorrectos';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    String? farmToken,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await svc.register(
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
        farmToken: farmToken,
      );
      return true;
    } catch (e) {
      _error = 'Error al registrar usuario';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await TokenStorage.clear();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
