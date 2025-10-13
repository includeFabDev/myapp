import 'package:flutter/material.dart';
import 'package:myapp/models/participante.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/services/firebase_service.dart';

class ReportesScreen extends StatelessWidget {
  final Actividad actividad;
  final FirebaseService _firebaseService = FirebaseService();

  ReportesScreen({super.key, required this.actividad});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de la Actividad'),
      ),
      body: StreamBuilder<List<Participante>>(
        stream: _firebaseService.getParticipantes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay datos para generar reportes.'));
          }

          final participantes = snapshot.data!;

          // Cálculos de totales corregidos
          final totalVendido = participantes.fold(0, (sum, item) => sum + item.llevo);
          final totalRecaudado = participantes.fold(0.0, (sum, item) => sum + item.pagos);
          final totalDeuda = participantes.fold(0.0, (sum, item) => sum + item.calcularDeuda(actividad.precioChoripan));

          // Rankings
          final rankingVentas = List<Participante>.from(participantes)..sort((a, b) => b.llevo.compareTo(a.llevo));
          final rankingDeudas = List<Participante>.from(participantes)..sort((a, b) => b.calcularDeuda(actividad.precioChoripan).compareTo(a.calcularDeuda(actividad.precioChoripan)));

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTotalsCard(totalVendido, totalRecaudado, totalDeuda),
              const SizedBox(height: 20),
              _buildRankingCard('Ranking de Ventas', rankingVentas, (p) => '${p.llevo} vendidos'),
              const SizedBox(height: 20),
              _buildRankingCard('Ranking de Deudas', rankingDeudas, (p) => 'Debe: \$${p.calcularDeuda(actividad.precioChoripan).toStringAsFixed(2)}'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalsCard(int totalVendido, double totalRecaudado, double totalDeuda) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Totales Generales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.blue),
              title: const Text('Total Vendido'),
              trailing: Text('$totalVendido unidades', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.green),
              title: const Text('Total Recaudado'),
              trailing: Text('\$${totalRecaudado.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ListTile(
              leading: const Icon(Icons.money_off, color: Colors.red),
              title: const Text('Total Deuda Pendiente'),
              trailing: Text('\$${totalDeuda.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingCard(String title, List<Participante> participantes, String Function(Participante) subtitle) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: participantes.length > 5 ? 5 : participantes.length, // Limitar a los 5 primeros
              itemBuilder: (context, index) {
                final participante = participantes[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(participante.nombre),
                  trailing: Text(subtitle(participante), style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
