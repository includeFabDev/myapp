import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/services/firebase_service.dart';

class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  _BienvenidaScreenState createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Text('No hay actividades. ¡Crea una para empezar!'),
            );
          }

          final actividades = snapshot.data!;

          return ListView.builder(
            itemCount: actividades.length,
            itemBuilder: (context, index) {
              final actividad = actividades[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(actividad.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${actividad.descripcion}\n${DateFormat('EEE, d MMM yyyy').format(actividad.fecha)}'),
                  isThreeLine: true,
                  onTap: () {
                    context.push('/actividad/${actividad.id}', extra: actividad);
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
