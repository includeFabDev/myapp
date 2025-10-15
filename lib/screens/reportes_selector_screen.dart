import 'package:flutter/material.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/screens/reportes_generales_caja_screen.dart';
import 'package:myapp/screens/reportes_screen.dart';
import 'package:myapp/services/firebase_service.dart';
import 'package:myapp/widgets/app_drawer.dart';

class ReportesSelectorScreen extends StatefulWidget {
  const ReportesSelectorScreen({super.key});

  @override
  _ReportesSelectorScreenState createState() => _ReportesSelectorScreenState();
}

class _ReportesSelectorScreenState extends State<ReportesSelectorScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Actividad - Reportes'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Gráficos generales de caja
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.blue),
              title: const Text('Reportes Generales de Caja'),
              subtitle: const Text('Gráficos de ingresos y egresos mensuales'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Navegar a reportes generales de caja
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportesGeneralesCajaScreen(),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Reportes por Actividad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Actividad>>(
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
                              builder: (context) => ReportesScreen(actividad: actividad),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
