import 'package:go_router/go_router.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/screens/activity_details_screen.dart';
import 'package:myapp/screens/caja_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/inversiones_screen.dart';
import 'package:myapp/screens/inversiones_selector_screen.dart';
import 'package:myapp/screens/reportes_generales_caja_screen.dart';
import 'package:myapp/screens/reportes_selector_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/participantes_activos_screen.dart';
import 'package:myapp/screens/register_screen.dart';
import 'package:myapp/screens/reportes_screen.dart';
import 'package:myapp/widgets/auth_gate.dart';

final GoRouter router = GoRouter(
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthGate(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
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
      path: '/caja',
      builder: (context, state) => const CajaScreen(),
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
