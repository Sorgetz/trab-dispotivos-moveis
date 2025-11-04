import 'package:exdb/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final BaseAuthService _authService;

  // 📦 ESTADO
  bool _isLoading = false;
  String? _errorMessage;
  User? _user; // Armazena o usuário logado

  // 💡 GETTERS
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  LoginViewModel({required BaseAuthService authService})
    : _authService = authService {
    // Verifica o estado de login inicial (se já estiver logado)
    _user = _authService.currentUser;
  }

  // ----------------------------------------
  // ⚙️ AÇÕES DE AUTENTICAÇÃO
  // ----------------------------------------

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signInWithGoogle();
      _user = userCredential.user;

      if (_user != null) {
        _errorMessage = null;
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('Bem-vindo, ${_user!.displayName ?? 'Usuário'}!'),
          ),
        );
      }
    } on Exception catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// Chave global para acesso ao contexto (necessário para o snackbar em VM, não é ideal, mas simplifica)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
