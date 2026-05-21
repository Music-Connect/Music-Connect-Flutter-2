import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  AuthStatus _status = AuthStatus.unknown;
  String? _error;

  UserModel? get user => _user;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.unknown;

  // ── Inicializar — verifica sessão salva ────────────────
  Future<void> initialize() async {
    try {
      final user = await AuthService.getSession();
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login ──────────────────────────────────────────────
  Future<bool> signIn(String email, String password) async {
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.signIn(
        email: email,
        password: password,
      );
      _user = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // ── Cadastro ───────────────────────────────────────────
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String tipoUsuario,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.signUp(
        name: name,
        email: email,
        password: password,
        tipoUsuario: tipoUsuario,
      );
      _user = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────
  Future<void> signOut() async {
    await AuthService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Atualizar usuário local (após editar perfil) ───────
  void updateUser(UserModel updated) {
    _user = updated;
    notifyListeners();
  }
}
