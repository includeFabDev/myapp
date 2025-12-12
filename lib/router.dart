import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/screens/activity_details_screen.dart';
import 'package:myapp/screens/caja_log_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/inversiones_screen.dart';
import 'package:myapp/screens/inversiones_selector_screen.dart';
import 'package:myapp/screens/reportes_generales_caja_screen.dart';
import 'package:myapp/screens/reportes_selector_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/register_screen.dart';
import 'package:myapp/screens/reportes_screen.dart';
import 'package:myapp/services/auth_service.dart';

// 1. La instancia del servicio de autenticación.
final AuthService authService = AuthService();

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// --- Configuración Definitiva del Router ---
final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home', // Intentamos ir a /home primero
  
  // 2. El router ahora "escucha" los cambios en el AuthService.
  // Cada vez que el usuario inicie o cierre sesión, el router se actualizará.
  refreshListenable: authService,

  // 3. La lógica de redirección, ahora sí, de forma segura.
  redirect: (BuildContext context, GoRouterState state) {
    final bool isLoggedIn = authService.user != null;
    final bool isLoading = authService.isLoading;

    // Mientras está cargando, no hacemos nada.
    if (isLoading) {
      return null; 
    }

    // Definimos las rutas que no necesitan autenticación.
    final bool isPublicRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    // Si el usuario no está logueado e intenta acceder a una ruta protegida, lo mandamos al login.
    if (!isLoggedIn && !isPublicRoute) {
      return '/login';
    }

    // Si el usuario ya está logueado e intenta ir al login/register, lo llevamos a home.
    if (isLoggedIn && isPublicRoute) {
      return '/home';
    }

    // En cualquier otro caso, dejamos que continúe.
    return null;
  },

  routes: [
    // 4. La ruta raíz (/) y /home ahora apuntan a la misma pantalla.
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'actividad/:id',
          builder: (context, state) {
            final actividad = state.extra as Actividad?;
            if (actividad == null) return const HomeScreen();
            return ActivityDetailsScreen(actividad: actividad);
          },
        ),
         GoRoute(
          path: 'caja/log', 
          builder: (context, state) => const CajaLogScreen(),
        ),
        GoRoute(
          path: 'inversiones/:id',
          builder: (context, state) {
            final actividad = state.extra as Actividad?;
            if (actividad == null) return const HomeScreen();
            return InversionesScreen(actividad: actividad);
          },
        ),
        GoRoute(
          path: 'reportes/:id',
          builder: (context, state) {
            final actividad = state.extra as Actividad?;
            if (actividad == null) return const HomeScreen();
            return ReportesScreen(actividad: actividad);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/actividades',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/inversiones',
      builder: (context, state) => const InversionesSelectorScreen(),
    ),
    GoRoute(
      path: '/reportes',
      builder: (context, state) => const ReportesSelectorScreen(),
    ),
    GoRoute(
      path: '/reportes_generales',
      builder: (context, state) => const ReportesGeneralesCajaScreen(),
    ),
  ],
);
