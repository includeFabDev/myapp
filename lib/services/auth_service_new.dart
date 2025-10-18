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

  // Método para enviar correo de recuperación de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      print('Error al enviar correo de recuperación: ${e.message}');
      throw e;
    }
  }

  // Método para configurar la persistencia de sesión ("Recordarme")
  Future<void> setPersistence(bool rememberMe) async {
    try {
      if (rememberMe) {
        await _auth.setPersistence(Persistence.LOCAL);
      } else {
        await _auth.setPersistence(Persistence.NONE);
      }
    } on FirebaseAuthException catch (e) {
      print('Error al configurar persistencia: ${e.message}');
      throw e;
    }
  }
}
