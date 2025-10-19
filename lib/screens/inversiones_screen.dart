
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/models/gasto.dart';
import 'package:myapp/services/firebase_service.dart';

class InversionesScreen extends StatefulWidget {
  final Actividad actividad;

  const InversionesScreen({super.key, required this.actividad});

  @override
  _InversionesScreenState createState() => _InversionesScreenState();
}

class _InversionesScreenState extends State<InversionesScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inversiones de ${widget.actividad.nombre}'),
        backgroundColor: Colors.blueGrey, // Tono más formal
      ),
      body: Column(
        children: [
          _buildTotalCard(),
          Expanded(child: _buildGastosList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGastoDialog(),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Añadir Gasto',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTotalCard() {
    return StreamBuilder<List<Gasto>>(
      stream: _firebaseService.getGastos(widget.actividad.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final gastos = snapshot.data!;
        final total = gastos.fold<double>(0, (sum, item) => sum + item.monto);

        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Inversión Total:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  NumberFormat.currency(locale: 'es_BO', symbol: 'Bs.').format(total),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGastosList() {
    return StreamBuilder<List<Gasto>>(
      stream: _firebaseService.getGastos(widget.actividad.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final gastos = snapshot.data!;
        if (gastos.isEmpty) {
          return const Center(child: Text('Aún no hay gastos registrados.'));
        }

        return ListView.builder(
          itemCount: gastos.length,
          itemBuilder: (context, index) {
            final gasto = gastos[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(gasto.descripcion, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(gasto.fecha)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NumberFormat.currency(locale: 'es_BO', symbol: 'Bs.').format(gasto.monto),
                      style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showGastoDialog(gasto: gasto),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(gasto),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showGastoDialog({Gasto? gasto}) {
    final descripcionController = TextEditingController(text: gasto?.descripcion ?? '');
    final montoController = TextEditingController(text: gasto?.monto.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(gasto == null ? 'Añadir Gasto' : 'Editar Gasto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                textCapitalization: TextCapitalization.sentences,
              ),
              TextField(
                controller: montoController,
                decoration: const InputDecoration(labelText: 'Monto', prefixText: 'Bs.'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final descripcion = descripcionController.text.trim();
                final monto = double.tryParse(montoController.text) ?? 0.0;

                if (descripcion.isNotEmpty && monto > 0) {
                  final nuevoGasto = Gasto(
                    id: gasto?.id ?? '', // El ID será ignorado al añadir, pero necesario para actualizar
                    descripcion: descripcion,
                    monto: monto,
                    fecha: gasto?.fecha ?? DateTime.now(),
                  );

                  if (gasto == null) {
                    _firebaseService.addGasto(widget.actividad.id, nuevoGasto);
                  } else {
                    _firebaseService.updateGasto(widget.actividad.id, nuevoGasto);
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, complete todos los campos.')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(Gasto gasto) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar el gasto "${gasto.descripcion}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                _firebaseService.deleteGasto(widget.actividad.id, gasto.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gasto eliminado correctamente.'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
