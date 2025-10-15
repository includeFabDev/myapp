import 'package:go_router/go_router.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/screens/activity_details_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/inversiones_screen.dart';
import 'package:myapp/screens/reportes_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
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
  ],
);
