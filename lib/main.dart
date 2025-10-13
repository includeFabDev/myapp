import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/screens/bienvenida_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/activity_details_screen.dart';
import 'package:myapp/screens/reportes_screen.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/models/participante.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Error al inicializar Firebase: $e");
  }
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BienvenidaScreen(),
    ),
    GoRoute(
      path: '/actividad/:actividadId',
      builder: (context, state) {
        final actividad = state.extra as Actividad?;
        if (actividad != null) {
          return HomeScreen(actividad: actividad);
        }
        return const Center(child: Text('Actividad no encontrada'));
      },
    ),
    GoRoute(
      path: '/participante/:participanteId',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final participante = extra?['participante'] as Participante?;
        final actividad = extra?['actividad'] as Actividad?;

        if (participante != null && actividad != null) {
          return ActivityDetailsScreen(participante: participante, actividad: actividad,);
        }
        return const Center(child: Text('Error: No se pudieron cargar los datos del participante.'));
      },
    ),
    GoRoute(
      path: '/reportes/:actividadId',
      builder: (context, state) {
        final actividad = state.extra as Actividad?;
        if (actividad != null) {
          return ReportesScreen(actividad: actividad);
        }
        return const Center(child: Text('Actividad no encontrada'));
      },
    ),
  ],
   errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error de Navegación')),
    body: Center(
      child: Text('No se pudo encontrar la ruta: ${state.uri}\nError: ${state.error}'),
    ),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Gestión Choripanes',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
         cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
