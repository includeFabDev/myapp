
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Error de inicio de sesión: ${e.message}');
      return null;
    }
  }

  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password.trim());
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Error de registro: ${e.message}');
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
      print('Error al enviar correo de recuperación: ${e.message}');
      rethrow;
    }
  }

  Future<void> setPersistence(bool rememberMe) async {
    if (kIsWeb) {
      try {
        if (rememberMe) {
          await _auth.setPersistence(Persistence.LOCAL);
        } else {
          await _auth.setPersistence(Persistence.SESSION);
        }
      } on FirebaseAuthException catch (e) {
        print('Error al configurar persistencia: ${e.message}');
        rethrow;
      }
    }
    // For mobile platforms, persistence is handled automatically
  }
}
