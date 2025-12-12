import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/movimiento_caja.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firebase_service.dart';
import 'package:provider/provider.dart';

class CajaScreen extends StatefulWidget {
  const CajaScreen({super.key});

  @override
  CajaScreenState createState() => CajaScreenState();
}

class CajaScreenState extends State<CajaScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  void _showAddMovimientoDialog({required String tipo, required User user}) {
    final formKey = GlobalKey<FormState>();
    final montoController = TextEditingController();
    final descripcionController = TextEditingController();
    DateTime fechaSeleccionada = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nuevo ${tipo == 'ingreso' ? 'Ingreso' : 'Egreso'}'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: montoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Monto', prefixText: 'Bs. '),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'El monto es obligatorio';
                        if (double.tryParse(value) == null) return 'Ingrese un número válido';
                        if (double.parse(value) <= 0) return 'El monto debe ser positivo';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: descripcionController,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'La descripción es obligatoria';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: fechaSeleccionada,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null && picked != fechaSeleccionada) {
                          setState(() {
                            fechaSeleccionada = picked;
                          });
                        }
                      },
                      child: Text('Fecha: ${DateFormat('dd/MM/yyyy').format(fechaSeleccionada)}'),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final monto = double.parse(montoController.text);

                  if (tipo == 'egreso') {
                    final saldoActual = await _firebaseService.getSaldoCajaStream().first;
                    if (monto > saldoActual) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fondos insuficientes. El egreso excede el saldo actual.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return; 
                    }
                  }
                  _firebaseService.addMovimientoCaja(
                    tipo: tipo,
                    monto: double.parse(montoController.text),
                    descripcion: descripcionController.text,
                    fecha: fechaSeleccionada,
                    usuarioId: user.uid,
                    usuarioNombre: user.displayName ?? user.email ?? 'Desconocido',
                  );
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
    final currencyFormat = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs.', decimalDigits: 2);
    final user = Provider.of<AuthService>(context).user;

    return Scaffold(
      
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSaldoCard(currencyFormat),
                Expanded(child: _buildMovimientosList(currencyFormat, user)),
              ],
            ),
      floatingActionButton: user == null
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  onPressed: () => _showAddMovimientoDialog(tipo: 'ingreso', user: user),
                  label: const Text('Ingreso'),
                  icon: const Icon(Icons.add),
                  heroTag: 'ingreso_fab',
                  backgroundColor: Colors.green,
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  onPressed: () => _showAddMovimientoDialog(tipo: 'egreso', user: user),
                  label: const Text('Egreso'),
                  icon: const Icon(Icons.remove),
                  heroTag: 'egreso_fab',
                  backgroundColor: Colors.red,
                ),
              ],
            ),
    );
  }

  Widget _buildSaldoCard(NumberFormat currencyFormat) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<double>(
          stream: _firebaseService.getSaldoCajaStream(),
          builder: (context, snapshot) {
            final saldo = snapshot.hasData ? snapshot.data! : 0.0;
            return Column(
              children: [
                const Text('SALDO ACTUAL', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 10),
                Text(currencyFormat.format(saldo), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMovimientosList(NumberFormat currencyFormat, User user) {
    return StreamBuilder<List<MovimientoCaja>>(
      stream: _firebaseService.getMovimientosCajaStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay movimientos registrados.'));
        }

        final movimientos = snapshot.data!;
        return ListView.builder(
          itemCount: movimientos.length,
          itemBuilder: (context, index) {
            final movimiento = movimientos[index];
            final isIngreso = movimiento.tipo == 'ingreso';
            return Dismissible(
              key: Key(movimiento.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmar eliminación'),
                      content: const Text('¿Estás seguro de que quieres eliminar este movimiento?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (direction) {
                _firebaseService.deleteMovimientoCaja(
                  movimientoId: movimiento.id,
                  usuarioId: user.uid,
                  usuarioNombre: user.displayName ?? user.email ?? 'Desconocido',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Movimiento eliminado')),
                );
              },
              child: ListTile(
                leading: Icon(isIngreso ? Icons.arrow_upward : Icons.arrow_downward, color: isIngreso ? Colors.green : Colors.red),
                title: Text(movimiento.descripcion),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(movimiento.fecha)),
                trailing: Text(
                  '${isIngreso ? '+' : '-'}${currencyFormat.format(movimiento.monto)}',
                  style: TextStyle(color: isIngreso ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () => _showEditMovimientoDialog(movimiento, user),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditMovimientoDialog(MovimientoCaja movimiento, User user) {
    final formKey = GlobalKey<FormState>();
    final montoController = TextEditingController(text: movimiento.monto.toString());
    final descripcionController = TextEditingController(text: movimiento.descripcion);
    String tipoSeleccionado = movimiento.tipo;
    DateTime fechaSeleccionada = movimiento.fecha;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Movimiento'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: tipoSeleccionado,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: const [
                        DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                        DropdownMenuItem(value: 'egreso', child: Text('Egreso')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          tipoSeleccionado = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'El tipo es obligatorio';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: montoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Monto', prefixText: 'Bs. '),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'El monto es obligatorio';
                        if (double.tryParse(value) == null) return 'Ingrese un número válido';
                        if (double.parse(value) <= 0) return 'El monto debe ser positivo';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: descripcionController,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'La descripción es obligatoria';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: fechaSeleccionada,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null && picked != fechaSeleccionada) {
                          setState(() {
                            fechaSeleccionada = picked;
                          });
                        }
                      },
                      child: Text('Fecha: ${DateFormat('dd/MM/yyyy').format(fechaSeleccionada)}'),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _firebaseService.updateMovimientoCaja(
                    movimientoId: movimiento.id,
                    tipo: tipoSeleccionado,
                    monto: double.parse(montoController.text),
                    descripcion: descripcionController.text,
                    fecha: fechaSeleccionada,
                    usuarioId: user.uid,
                    usuarioNombre: user.displayName ?? user.email ?? 'Desconocido',
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }
}
