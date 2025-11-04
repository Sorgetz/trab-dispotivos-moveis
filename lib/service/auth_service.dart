// lib/auth/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// 👤 Interface para o serviço de autenticação
abstract class BaseAuthService {
  User? get currentUser;
  Future<UserCredential> signInWithGoogle();
  // Você pode adicionar mais métodos aqui: signInWithEmail, signUp, signOut, etc.
}

class AuthService implements BaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      // 1. Inicia o fluxo de autenticação do Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Usuário cancelou o login
        throw Exception('Login com Google cancelado pelo usuário.');
      }

      // 2. Obtém os detalhes de autenticação do Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Cria uma credencial do Firebase a partir do token do Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Faz login no Firebase com a credencial
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // Lidar com erros específicos do Firebase
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception(
          'Uma conta já existe com o mesmo e-mail, mas usando outro provedor.',
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
