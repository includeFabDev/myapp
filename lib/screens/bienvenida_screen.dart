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

  void _showAddActivityDialog() async {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final precioController = TextEditingController();
    DateTime? fechaSeleccionada = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Crear Nueva Actividad"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: "Nombre de la Actividad"),
                ),
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: "Descripción"),
                ),
                TextField(
                  controller: precioController,
                  decoration: const InputDecoration(labelText: "Precio de Producto a Vender"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: fechaSeleccionada ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        fechaSeleccionada = picked;
                      });
                    }
                  },
                  child: Text(
                    'Fecha: ${DateFormat('yMd').format(fechaSeleccionada ?? DateTime.now())}',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nombreController.text.isNotEmpty &&
                    precioController.text.isNotEmpty) {
                  final nuevaActividad = Actividad(
                    nombre: nombreController.text,
                    descripcion: descripcionController.text,
                    fecha: fechaSeleccionada ?? DateTime.now(),
                    precioChoripan: double.tryParse(precioController.text) ?? 0.0,
                    id: '',
                  );
                  _firebaseService.addActividad(nuevaActividad);
                  Navigator.pop(context);
                }
              },
              child: const Text("Crear"),
            ),
          ],
        );
      },
    );
  }

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
                child: Column(
                  children: [
                    ListTile(
                      title: Text(actividad.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${actividad.descripcion}\n${DateFormat('EEE, d MMM yyyy').format(actividad.fecha)}'),
                      isThreeLine: true,
                      onTap: () {
                        context.push('/home/actividad/${actividad.id}', extra: actividad);
                      },
                    ),
                    // Botones debajo del recuadro de actividad
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              context.push('/home/actividad/${actividad.id}', extra: actividad);
                            },
                            icon: const Icon(Icons.people),
                            label: const Text('Participantes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.push('/home/inversiones/${actividad.id}', extra: actividad);
                            },
                            icon: const Icon(Icons.attach_money),
                            label: const Text('Inversiones'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.push('/home/reportes/${actividad.id}', extra: actividad);
                            },
                            icon: const Icon(Icons.bar_chart),
                            label: const Text('Reportes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddActivityDialog,
        tooltip: 'Crear Actividad',
        child: const Icon(Icons.add),
      ),
    );
  }
}
