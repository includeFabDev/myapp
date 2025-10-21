import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Enum para un control de estado más claro y robusto.
enum AuthStatus { unknown, authenticated, unauthenticated }

// Instancia global para un acceso único y centralizado.
final AuthService authService = AuthService();

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  // 1. Añadimos el estado de carga, inicializado en true.
  bool _isLoading = true;
  late StreamSubscription<User?> _authSubscription;

  AuthService() {
    // Escuchamos los cambios y actualizamos el estado.
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // 2. Método separado para manejar el cambio de estado.
  void _onAuthStateChanged(User? user) {
    _user = user;
    // 3. Tan pronto como recibimos el primer evento, la carga inicial ha terminado.
    if (_isLoading) {
      _isLoading = false;
    }
    notifyListeners();
  }

  User? get user => _user;

  // 4. Getter para el estado de carga. El AuthWrapper lo usará.
  bool get isLoading => _isLoading;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error de inicio de sesión: ${e.message}');
      return null;
    }
  }

  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password.trim());
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error de registro: ${e.message}');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      debugPrint('Error al enviar correo de recuperación: ${e.message}');
      rethrow;
    }
  }

  Future<void> setPersistence(bool rememberMe) async {
    if (kIsWeb) {
      try {
        await _auth.setPersistence(rememberMe ? Persistence.LOCAL : Persistence.SESSION);
      } on FirebaseAuthException catch (e) {
        debugPrint('Error al configurar persistencia: ${e.message}');
        rethrow;
      }
    }
  }

  // Es buena práctica limpiar la suscripción cuando el servicio ya no se use.
  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
