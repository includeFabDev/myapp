import 'package:flutter/material.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/models/participante.dart';
import 'package:myapp/models/venta.dart';
import 'package:myapp/services/firebase_service.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final Participante participante;
  final Actividad actividad;

  const ActivityDetailsScreen({
    super.key,
    required this.participante,
    required this.actividad,
  });

  @override
  _ActivityDetailsScreenState createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  void _showAddVentaDialog() {
    final cantidadController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Venta'),
        content: TextField(
          controller: cantidadController,
          decoration: const InputDecoration(labelText: 'Cantidad vendida'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final cantidad = int.tryParse(cantidadController.text);
              if (cantidad != null && cantidad > 0) {
                final venta = Venta(
                  participanteId: widget.participante.id!,
                  cantidad: cantidad,
                  fecha: DateTime.now(),
                );
                // Llama al método corregido en el servicio
                _firebaseService.addVenta(venta, widget.participante);

                // Actualiza el estado local para reflejar el cambio al instante
                setState(() {
                  widget.participante.llevo += cantidad;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _showAddPagoDialog() {
    final montoController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Pago'),
        content: TextField(
          controller: montoController,
          decoration: const InputDecoration(labelText: 'Monto pagado'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final monto = double.tryParse(montoController.text);
              if (monto != null && monto > 0) {
                // Llama al método corregido en el servicio
                _firebaseService.addPago(widget.participante, monto);

                // Actualiza el estado local para reflejar el cambio al instante
                setState(() {
                  widget.participante.pagos += monto;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Recalcula la deuda y el progreso en cada build para tener datos actualizados
    final double deuda = widget.participante.calcularDeuda(widget.actividad.precioChoripan);
    final double progreso = widget.participante.meta > 0 ? widget.participante.llevo / widget.participante.meta : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.participante.nombre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meta de venta: ${widget.participante.meta}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text('Choripanes vendidos: ${widget.participante.llevo}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progreso, minHeight: 10),
            const SizedBox(height: 20),
            Text('Total recaudado: \$${widget.participante.llevo * widget.actividad.precioChoripan}', style: Theme.of(context).textTheme.titleMedium),
            Text('Total pagado: \$${widget.participante.pagos.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            Text(
              'Deuda actual: \$${deuda.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: deuda > 0 ? Colors.red : Colors.green,
                  ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Venta'),
                  onPressed: _showAddVentaDialog,
                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.attach_money),
                  label: const Text('Pago'),
                  onPressed: _showAddPagoDialog,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Historial de Ventas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
             Expanded(
              child: StreamBuilder<List<Venta>>(
                stream: _firebaseService.getVentas(widget.participante.id!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final ventas = snapshot.data!;
                  if (ventas.isEmpty) {
                    return const Center(child: Text('Aún no hay ventas registradas.'));
                  }
                  return ListView.builder(
                    itemCount: ventas.length,
                    itemBuilder: (context, index) {
                      final venta = ventas[index];
                      return ListTile(
                        title: Text('Vendió ${venta.cantidad} choripanes'),
                        subtitle: Text(venta.fecha.toLocal().toString()),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
