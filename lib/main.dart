
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/widgets/auth_gate.dart'; // Importa el AuthGate
import 'package:flutter_localizations/flutter_localizations.dart'; // Import for localization
import 'package:intl/date_symbol_data_local.dart'; // Import for date formatting

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize date formatting for Spanish (Mexico) before running the app
  await initializeDateFormatting('es_MX', null); 
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // ignore: avoid_print
    print("Error al inicializar Firebase: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestión Financiera',
      
      // --- Localization Settings ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('es', 'MX'), // Spanish, Mexico
      ],
      locale: const Locale('es', 'MX'), // Set default locale to Spanish, Mexico
      // --- End Localization Settings ---

      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),

        // Estilo de tarjetas unificado
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        ),

        // Estilo de botones elevado
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),

        // Estilo del AppBar
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          backgroundColor: Colors.orange,
          iconTheme: IconThemeData(color: Colors.white)
        ),

        // Estilo de los FAB (Floating Action Button)
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
           backgroundColor: Colors.orange,
           foregroundColor: Colors.white,
        )
      ),
      home: const AuthGate(), // ¡El AuthGate es la nueva entrada a la aplicación!
    );
  }
}
