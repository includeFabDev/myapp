import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/participante.dart';
import 'package:myapp/services/firebase_service.dart';
import 'package:myapp/models/actividad.dart';

class HomeScreen extends StatefulWidget {
  final Actividad actividad;

  const HomeScreen({super.key, required this.actividad});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  void _showAddParticipanteDialog() {
    final nombreController = TextEditingController();
    final metaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir Participante'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: metaController,
                decoration: const InputDecoration(labelText: 'Meta de venta'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nombreController.text.isNotEmpty) {
                  final nuevoParticipante = Participante(
                    nombre: nombreController.text,
                    actividadId: widget.actividad.id!,
                    meta: int.tryParse(metaController.text) ?? 0,
                  );
                  _firebaseService.addParticipante(nuevoParticipante);
                  Navigator.pop(context);
                }
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.actividad.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            onPressed: () {
              context.push('/reportes/${widget.actividad.id}', extra: widget.actividad);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Participante>>(
        stream: _firebaseService.getParticipantes().map(
              (participantes) => participantes
                  .where((p) => p.actividadId == widget.actividad.id)
                  .toList(),
            ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
           if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay participantes. Añade uno para comenzar.'));
          }

          final participantes = snapshot.data!;

          return ListView.builder(
            itemCount: participantes.length,
            itemBuilder: (context, index) {
              final participante = participantes[index];
              final double deuda = participante.calcularDeuda(widget.actividad.precioChoripan);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ListTile(
                  title: Text(participante.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Meta: ${participante.meta} / Llevo: ${participante.llevo}'),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(
                        value: participante.meta > 0 ? participante.llevo / participante.meta : 0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          (participante.llevo / participante.meta) >= 1 ? Colors.green : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    'Debe: \$${deuda.toStringAsFixed(2)}',
                    style: TextStyle(color: deuda > 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    context.push(
                      '/participante/${participante.id}',
                       extra: {'participante': participante, 'actividad': widget.actividad},
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddParticipanteDialog,
        tooltip: 'Añadir Participante',
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
