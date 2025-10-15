import 'package:flutter/material.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/models/participante.dart';
import 'package:myapp/screens/reportes_screen.dart';
import 'package:myapp/services/firebase_service.dart';
import 'package:intl/intl.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final Actividad actividad;

  const ActivityDetailsScreen({
    super.key,
    required this.actividad,
  });

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs.', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.actividad.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Ver Reportes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportesScreen(actividad: widget.actividad),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Añadir Participante',
            onPressed: () => _mostrarDialogoNuevoParticipante(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Participante>>(
        stream: _firebaseService.getParticipantes(widget.actividad.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay participantes todavía.\nToca el botón + para añadir uno.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final participantes = snapshot.data!;
          return ListView.builder(
            itemCount: participantes.length,
            itemBuilder: (context, index) {
              final participante = participantes[index];
              final deuda = (participante.llevo * widget.actividad.precioChoripan) - participante.pagos;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(participante.nombre.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(participante.nombre, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    'Vendido: ${participante.llevo}',
                  ),
                  trailing: Text(
                    'Deuda: ${currencyFormat.format(deuda)}',
                    style: TextStyle(
                      color: deuda > 0.1 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => _mostrarDialogoEditarVentas(context, participante),
                  onLongPress: () => _confirmDeleteParticipante(context, participante),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _mostrarDialogoNuevoParticipante(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String nombre = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Participante'),
          content: Form(
            key: formKey,
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) => value == null || value.isEmpty ? 'Ingresa un nombre' : null,
              onSaved: (value) => nombre = value!,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final nuevoParticipante = Participante(nombre: nombre);
                  _firebaseService.addParticipante(widget.actividad.id, nuevoParticipante);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEditarVentas(BuildContext context, Participante participante) {
    final formKey = GlobalKey<FormState>();
    int llevo = participante.llevo;
    double pagoEfectivo = participante.pagoEfectivo;
    double pagoQr = participante.pagoQr;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Registrar para ${participante.nombre}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: llevo.toString(),
                  decoration: const InputDecoration(labelText: 'Cantidad Vendida', prefixIcon: Icon(Icons.shopping_cart)),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => llevo = int.tryParse(value ?? '0') ?? 0,
                ),
                TextFormField(
                  initialValue: pagoEfectivo.toString(),
                  decoration: const InputDecoration(labelText: 'Pago en Efectivo', prefixText: 'Bs.', prefixIcon: Icon(Icons.money)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onSaved: (value) => pagoEfectivo = double.tryParse(value ?? '0') ?? 0,
                ),
                 TextFormField(
                  initialValue: pagoQr.toString(),
                  decoration: const InputDecoration(labelText: 'Pago con QR', prefixText: 'Bs.', prefixIcon: Icon(Icons.qr_code)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onSaved: (value) => pagoQr = double.tryParse(value ?? '0') ?? 0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final participanteActualizado = participante.copyWith(
                    llevo: llevo,
                    pagoEfectivo: pagoEfectivo,
                    pagoQr: pagoQr,
                  );
                  _firebaseService.updateParticipante(
                    widget.actividad.id,
                    participanteActualizado,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteParticipante(BuildContext context, Participante participante) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar Eliminación'),
            content: Text('¿Estás seguro de que deseas eliminar a ${participante.nombre}?\nEsta acción no se puede deshacer.'),
            actions: <Widget>[
              TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(context).pop()),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Eliminar'),
                  onPressed: () {
                     // ¡CORREGIDO! La llamada a la función ya está activa.
                     if (participante.id != null) {
                       _firebaseService.deleteParticipante(widget.actividad.id, participante.id!);
                     }
                     Navigator.of(context).pop();
                     ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Participante eliminado'), 
                          backgroundColor: Colors.green,
                        )
                     );
                  }
              ),
            ],
          );
        });
  }
}
