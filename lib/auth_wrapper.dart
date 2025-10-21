import 'package:flutter/material.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    // Usamos el nuevo enum para decidir qué mostrar.
    switch (auth.status) {
      case AuthStatus.unknown:
        // Mientras Firebase verifica, mostramos una pantalla de carga.
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.authenticated:
        // Si el usuario está autenticado, lo llevamos a la pantalla principal.
        return const HomeScreen(); 
      case AuthStatus.unauthenticated:
        // Si no lo está, a la pantalla de login.
        return const LoginScreen();
    }
  }
}
