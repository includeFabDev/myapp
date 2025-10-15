
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/participante.dart';
import 'package:myapp/models/venta.dart';
import 'package:myapp/services/firebase_service.dart';

class ParticipantDetailsScreen extends StatefulWidget {
  final String actividadId;
  final Participante participante;

  const ParticipantDetailsScreen({
    super.key,
    required this.actividadId,
    required this.participante,
  });

  @override
  _ParticipantDetailsScreenState createState() => _ParticipantDetailsScreenState();
}

class _ParticipantDetailsScreenState extends State<ParticipantDetailsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  void _showVentaDialog({Venta? venta}) {
    final formKey = GlobalKey<FormState>();
    int? cantidad;
    final isEditing = venta != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Venta' : 'Añadir Venta'),
          content: Form(
            key: formKey,
            child: TextFormField(
              initialValue: isEditing ? venta.cantidad.toString() : '',
              decoration: const InputDecoration(labelText: 'Cantidad Vendida'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Ingresa una cantidad';
                if (int.tryParse(value) == null) return 'Ingresa un número válido';
                return null;
              },
              onSaved: (value) => cantidad = int.parse(value!),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  if (isEditing) {
                    _firebaseService.updateVenta(widget.actividadId, widget.participante.id!, venta, cantidad!);
                  } else {
                    final nuevaVenta = Venta(
                      id: '',
                      cantidad: cantidad!,
                      fecha: DateTime.now(), participanteId: '',
                    );
                    _firebaseService.addVenta(widget.actividadId, widget.participante.id!, nuevaVenta);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Guardar' : 'Añadir'),
            ),
          ],
        );
      },
    );
  }

  void _showEditNameDialog(Participante participante) {
    final formKey = GlobalKey<FormState>();
    String nuevoNombre = participante.nombre;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Nombre'),
          content: Form(
            key: formKey,
            child: TextFormField(
              initialValue: nuevoNombre,
              decoration: const InputDecoration(labelText: 'Nombre del Participante'),
              validator: (value) => value == null || value.isEmpty ? 'El nombre no puede estar vacío' : null,
              onSaved: (value) => nuevoNombre = value!,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final updatedParticipante = participante.copyWith(nombre: nuevoNombre);
                  _firebaseService.updateParticipante(widget.actividadId, updatedParticipante);
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
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
        title: StreamBuilder<Participante>(
          stream: _firebaseService.getParticipanteStream(widget.actividadId, widget.participante.id!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text(widget.participante.nombre);
            }
            final participante = snapshot.data!;
            return Text(participante.nombre);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditNameDialog(widget.participante),
            tooltip: 'Editar Nombre',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressCard(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Historial de Ventas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(child: _buildVentasList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVentaDialog(),
        tooltip: 'Añadir Venta',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProgressCard() {
    return StreamBuilder<Participante>(
      stream: _firebaseService.getParticipanteStream(widget.actividadId, widget.participante.id!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final participante = snapshot.data!;
        final progress = participante.meta > 0 ? (participante.llevo / participante.meta) : 0.0;
        final restante = participante.meta - participante.llevo;

        return Card(
          margin: const EdgeInsets.all(16.0),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Vendido: ${participante.llevo}'),
                    Text('Meta: ${participante.meta}'),
                    Text('Faltan: $restante', style: TextStyle(fontWeight: FontWeight.bold, color: restante > 0 ? Colors.red : Colors.green)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVentasList() {
    return StreamBuilder<List<Venta>>(
      stream: _firebaseService.getVentas(widget.actividadId, widget.participante.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay ventas registradas.'));
        }
        final ventas = snapshot.data!;
        return ListView.builder(
          itemCount: ventas.length,
          itemBuilder: (context, index) {
            final venta = ventas[index];
            return ListTile(
              title: Text('Cantidad: ${venta.cantidad}'),
              subtitle: Text(DateFormat.yMMMd('es').add_jm().format(venta.fecha)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showVentaDialog(venta: venta),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _firebaseService.deleteVenta(widget.actividadId, widget.participante.id!, venta);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
