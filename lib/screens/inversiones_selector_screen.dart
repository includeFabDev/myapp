import 'package:flutter/material.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/screens/inversiones_screen.dart';
import 'package:myapp/services/firebase_service.dart';
import 'package:myapp/widgets/app_drawer.dart';

class InversionesSelectorScreen extends StatefulWidget {
  const InversionesSelectorScreen({super.key});

  @override
  _InversionesSelectorScreenState createState() => _InversionesSelectorScreenState();
}

class _InversionesSelectorScreenState extends State<InversionesSelectorScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Actividad - Inversiones'),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<Actividad>>(
        stream: _firebaseService.getActividades(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay actividades disponibles.'),
            );
          }

          final actividades = snapshot.data!;

          return ListView.builder(
            itemCount: actividades.length,
            itemBuilder: (context, index) {
              final actividad = actividades[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(actividad.nombre),
                  subtitle: Text(actividad.descripcion),
                  trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InversionesScreen(actividad: actividad),
                            ),
                          );
                        },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
