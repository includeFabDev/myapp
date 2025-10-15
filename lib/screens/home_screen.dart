
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/screens/activity_details_screen.dart';
import 'package:myapp/screens/inversiones_screen.dart'; // Importa la nueva pantalla
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Cierre de Sesión'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres cerrar la sesión?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Cerrar Sesión'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Actividades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: _showLogoutConfirmationDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<Actividad>>(
        stream: _firebaseService.getActividades(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Aún no has creado ninguna actividad.\n¡Toca el botón + para empezar!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          final actividades = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: actividades.length,
            itemBuilder: (context, index) {
              final actividad = actividades[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        actividad.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text('Creada: ${DateFormat.yMd().add_jm().format(actividad.fecha)}'),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.people, color: Colors.deepPurple),
                            label: const Text('Participantes'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ActivityDetailsScreen(actividad: actividad),
                                ),
                              );
                            },
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.trending_up, color: Colors.green),
                            label: const Text('Inversiones'), // Nuevo botón
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InversionesScreen(actividad: actividad),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCrearActividad(context),
        tooltip: 'Nueva Actividad',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogoCrearActividad(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String nombre = '';
    double? precio;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nueva Actividad'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nombre de la actividad'),
                  validator: (value) => value == null || value.isEmpty ? 'Ingresa un nombre' : null,
                  onSaved: (value) => nombre = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Precio Unitario (₲)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingresa un precio';
                    if (double.tryParse(value) == null) return 'Ingresa un número válido';
                    return null;
                  },
                  onSaved: (value) => precio = double.parse(value!),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final nuevaActividad = Actividad(
                    nombre: nombre,
                    fecha: DateTime.now(),
                    precioChoripan: precio!,
                    descripcion: '', id: '',
                  );
                  _firebaseService.addActividad(nuevaActividad);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Actividad creada con éxito!')),
                  );
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }
}
