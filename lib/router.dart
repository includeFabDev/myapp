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
import 'package:myapp/screens/participantes_activos_screen.dart';
import 'package:myapp/screens/register_screen.dart';
import 'package:myapp/screens/reportes_screen.dart';
import 'package:myapp/services/auth_service.dart'; 
import 'package:myapp/widgets/auth_wrapper.dart'; // Importamos el Wrapper

// La instancia del servicio de autenticación sigue siendo necesaria.
final AuthService authService = AuthService();

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// --- Nueva configuración del Router ---
final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  // 1. La ruta inicial ahora es la raíz, que mostrará el AuthWrapper.
  initialLocation: '/',
  
  // 2. Ya NO necesitamos `redirect` ni `refreshListenable`. El Wrapper se encarga de todo.

  routes: [
    // 3. La ruta raíz (/) ahora apunta a nuestro AuthWrapper.
    // Él decidirá qué pantalla mostrar (Login o Home).
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthWrapper(),
    ),
    // 4. Mantenemos las rutas específicas para que `context.go()` siga funcionando.
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        // Las sub-rutas se mantienen igual.
        GoRoute(
          path: 'actividad/:id',
          builder: (context, state) {
            final actividad = state.extra as Actividad?;
            if (actividad == null) return const HomeScreen();
            return ActivityDetailsScreen(actividad: actividad);
          },
        ),
         GoRoute(
          path: 'caja/log', // Ruta para el historial de caja
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
      path: '/participantes_activos',
      builder: (context, state) => const ParticipantesActivosScreen(),
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
