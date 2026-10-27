import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Retorna o usuário atualmente logado ou null
  User? get currentUser => _auth.currentUser;

  //aqui é onde vamos ouvir as mudanças no estado de autenticação do usuário
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Realiza o cadastro de um novo usuário com E-mail e Senha
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_translateAuthError(e.code));
    }
  }

  //Realiza o login de um usuário existente
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_translateAuthError(e.code));
    }
  }

  // Encerra a sessão do usuário ativo
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // aqui vai traduzir os códigos de erro do Firebase Auth para mensagens em português
  String _translateAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Nenhum usuário encontrado com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso por outra conta.';
      case 'invalid-email':
        return 'Endereço de e-mail inválido.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      default:
        return 'Ocorreu um erro na autenticação ($code).';
    }
  }
}