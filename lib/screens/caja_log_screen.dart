import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/log_cambio.dart';
import '../services/firebase_service.dart';

class CajaLogScreen extends StatelessWidget {
  const CajaLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ¡La flecha que va DIRECTO a la Caja!
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Le decimos explícitamente a dónde ir, sin dejar lugar a dudas.
          onPressed: () => context.go('/home'), 
          tooltip: 'Volver a Caja',
        ),
        title: const Text('Historial de Movimiento en Caja'),
      ),
      body: StreamBuilder<List<LogCambio>>(
        stream: FirebaseService().getHistorialCaja(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay historial de cambios.'));
          }

          final logs = snapshot.data!;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(
                    _getIconForChangeType(log.tipoCambio),
                    color: _getColorForChangeType(log.tipoCambio),
                    size: 40,
                  ),
                  title: Text(
                    log.descripcion,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Por: ${log.usuarioNombre} - ${log.fecha.day}/${log.fecha.month}/${log.fecha.year} a las ${log.fecha.hour}:${log.fecha.minute}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    log.tipoCambio.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getColorForChangeType(log.tipoCambio),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIconForChangeType(String tipoCambio) {
    switch (tipoCambio) {
      case 'crear':
        return Icons.add_circle_outline;
      case 'actualizar':
        return Icons.edit_note;
      case 'eliminar':
        return Icons.delete_sweep_outlined;
      default:
        return Icons.history;
    }
  }

  Color _getColorForChangeType(String tipoCambio) {
    switch (tipoCambio) {
      case 'crear':
        return Colors.green;
      case 'actualizar':
        return Colors.orange;
      case 'eliminar':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
