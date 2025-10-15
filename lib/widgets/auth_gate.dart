
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/screens/home_screen.dart'; // Corregido: Importa HomeScreen
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/services/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().user, // Escucha los cambios de estado de autenticación
      builder: (context, snapshot) {
        // El usuario no ha iniciado sesión
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // El usuario ha iniciado sesión, muestra la pantalla principal
        return const HomeScreen(); // Corregido: Usa HomeScreen
      },
    );
  }
}
