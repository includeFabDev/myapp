import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Mientras el servicio está determinando el estado de autenticación,
        // mostramos una pantalla de carga. Esto es crucial para el arranque.
        if (authService.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si hay un usuario, vamos a la pantalla principal.
        if (authService.user != null) {
          return const HomeScreen();
        }

        // ¡Esta es la línea que faltaba! Si no está cargando y no hay usuario,
        // entonces mostramos la pantalla de login.
        return const LoginScreen();
      },
    );
  }
}
