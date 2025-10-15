import 'package:flutter/material.dart';
import 'package:myapp/services/firebase_service.dart';
import 'package:myapp/widgets/app_drawer.dart';

class ParticipantesActivosScreen extends StatefulWidget {
  const ParticipantesActivosScreen({super.key});

  @override
  _ParticipantesActivosScreenState createState() => _ParticipantesActivosScreenState();
}

class _ParticipantesActivosScreenState extends State<ParticipantesActivosScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participantes Activos'),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firebaseService.getParticipantesUnicos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay participantes con actividad aún.'),
            );
          }

          final participantes = snapshot.data!;

          return ListView.builder(
            itemCount: participantes.length,
            itemBuilder: (context, index) {
              final participante = participantes[index];
              return ListTile(
                title: Text(participante['nombre'] ?? 'Sin nombre'),
                subtitle: Text('ID: ${participante['id']}'),
              );
            },
          );
        },
      ),
    );
  }
}
