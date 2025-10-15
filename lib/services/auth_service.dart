
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para escuchar los cambios en el estado de autenticación (login/logout)
  Stream<User?> get user => _auth.authStateChanges();

  // Método para iniciar sesión con email y contraseña
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Podemos manejar errores específicos aquí si queremos
      print('Error de inicio de sesión: ${e.message}');
      return null;
    }
  }

  // Método para registrar un nuevo usuario
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password.trim());
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Error de registro: ${e.message}');
      return null;
    }
  }

  // Método para cerrar la sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
