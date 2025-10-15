import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/models/gasto.dart';
import 'package:myapp/models/movimiento_caja.dart';
import 'package:myapp/models/participante.dart';
import 'package:myapp/models/venta.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // MÉTODOS PARA ACTIVIDADES
  //----------------------------------------------------------------

  Stream<List<Actividad>> getActividades() {
    return _db.collection('actividades').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Actividad.fromFirestore(doc)).toList());
  }

  Future<void> addActividad(Actividad actividad) {
    return _db.collection('actividades').add(actividad.toFirestore());
  }

  // MÉTODOS PARA PARTICIPANTES
  //----------------------------------------------------------------

  Stream<List<Participante>> getParticipantes(String actividadId) {
    return _db
        .collection('actividades')
        .doc(actividadId)
        .collection('participantes')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Participante.fromFirestore(doc))
            .toList());
  }

  Stream<Participante> getParticipanteStream(String actividadId, String participanteId) {
    return _db
        .collection('actividades')
        .doc(actividadId)
        .collection('participantes')
        .doc(participanteId)
        .snapshots()
        .map((doc) => Participante.fromFirestore(doc));
  }

  Future<void> addParticipante(String actividadId, Participante participante) {
    return _db
        .collection('actividades')
        .doc(actividadId)
        .collection('participantes')
        .add(participante.toFirestore());
  }

  Future<void> updateParticipante(String actividadId, Participante participante) {
    return _db
        .collection('actividades')
        .doc(actividadId)
        .collection('participantes')
        .doc(participante.id)
        .update(participante.toFirestore());
  }

  Future<void> deleteParticipante(String actividadId, String participanteId) {
    return _db
        .collection('actividades')
        .doc(actividadId)
        .collection('participantes')
        .doc(participanteId)
        .delete();
  }

  // MÉTODOS PARA VENTAS
  //----------------------------------------------------------------

  Stream<List<Venta>> getVentas(String actividadId, String participanteId) {
    return _db
        .collection('actividades')
        .doc(actividadId)
        .collection('participantes')
        .doc(participanteId)
        .collection('ventas')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Venta.fromFirestore(doc)).toList());
  }

  Future<void> addVenta(String actividadId, String participanteId, Venta venta) {
    return _db.runTransaction((transaction) async {
      final participanteRef = _db
          .collection('actividades')
          .doc(actividadId)
          .collection('participantes')
          .doc(participanteId);
      final ventaRef = participanteRef.collection('ventas').doc();

      transaction.update(participanteRef, {'llevo': FieldValue.increment(venta.cantidad)});
      transaction.set(ventaRef, venta.toFirestore());
    });
  }

  Future<void> updateVenta(String actividadId, String participanteId, Venta ventaOriginal, int nuevaCantidad) {
    return _db.runTransaction((transaction) async {
      final participanteRef = _db
          .collection('actividades')
          .doc(actividadId)
          .collection('participantes')
          .doc(participanteId);
      final ventaRef = participanteRef.collection('ventas').doc(ventaOriginal.id);

      final diferencia = nuevaCantidad - ventaOriginal.cantidad;
      transaction.update(participanteRef, {'llevo': FieldValue.increment(diferencia)});
      transaction.update(ventaRef, {'cantidad': nuevaCantidad});
    });
  }

  Future<void> deleteVenta(String actividadId, String participanteId, Venta venta) {
    return _db.runTransaction((transaction) async {
      final participanteRef = _db
          .collection('actividades')
          .doc(actividadId)
          .collection('participantes')
          .doc(participanteId);
      final ventaRef = participanteRef.collection('ventas').doc(venta.id);

      transaction.update(participanteRef, {'llevo': FieldValue.increment(-venta.cantidad)});
      transaction.delete(ventaRef);
    });
  }

  // MÉTODOS PARA PAGOS
  //----------------------------------------------------------------

  Future<void> addPago(String actividadId, String participanteId, double monto) {
    return _db
        .collection('actividades')
        .doc(actividadId)
        .collection('participantes')
        .doc(participanteId)
        .update({'pagos': FieldValue.increment(monto)});
  }

  // MÉTODOS PARA GASTOS (INVERSIONES)
  //----------------------------------------------------------------

  Stream<List<Gasto>> getGastos(String actividadId) {
    return _db
        .collection('actividades')
        .doc(actividadId)
        .collection('inversiones')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Gasto.fromFirestore(doc)).toList());
  }

  Future<void> addGasto(String actividadId, Gasto gasto) {
    return _db
        .collection('actividades')
        .doc(actividadId)
        .collection('inversiones')
        .add(gasto.toFirestore());
  }

  Future<void> updateGasto(String actividadId, Gasto gasto) {
    return _db
        .collection('actividades')
        .doc(actividadId)
        .collection('inversiones')
        .doc(gasto.id)
        .update(gasto.toFirestore());
  }

  Future<void> deleteGasto(String actividadId, String gastoId) {
    return _db
        .collection('actividades')
        .doc(actividadId)
        .collection('inversiones')
        .doc(gastoId)
        .delete();
  }

  // MÉTODOS PARA CONTROL DE CAJA (CORREGIDO)
  //----------------------------------------------------------------

  Stream<double> getSaldoCajaStream() {
    return _db
        .collection('caja_resumen')
        .doc('saldo_actual')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return 0.0;
      }
      final data = snapshot.data() as Map<String, dynamic>;
      return (data['saldoTotal'] ?? 0.0).toDouble();
    });
  }

  Stream<List<MovimientoCaja>> getMovimientosCajaStream() {
    return _db
        .collection('movimientos_caja')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MovimientoCaja.fromFirestore(doc))
            .toList());
  }

  Future<void> addMovimientoCaja({
    required String tipo,
    required double monto,
    required String descripcion,
    required DateTime fecha,
    String? relacionActividad,
  }) {
    final saldoRef = _db.collection('caja_resumen').doc('saldo_actual');

    return _db.runTransaction((transaction) async {
      final saldoSnapshot = await transaction.get(saldoRef);

      double saldoAnterior = 0.0;
      if (saldoSnapshot.exists && saldoSnapshot.data() != null) {
        final data = saldoSnapshot.data() as Map<String, dynamic>;
        saldoAnterior = (data['saldoTotal'] ?? 0.0).toDouble();
      }

      final double nuevoSaldo;
      if (tipo == 'ingreso') {
        nuevoSaldo = saldoAnterior + monto;
      } else {
        nuevoSaldo = saldoAnterior - monto;
      }

      final nuevoMovimiento = MovimientoCaja(
        id: '',
        tipo: tipo,
        monto: monto,
        descripcion: descripcion,
        fecha: fecha, // Usamos la fecha proporcionada
        relacionActividad: relacionActividad,
        saldoResultante: nuevoSaldo,
      );

      final nuevoMovimientoRef = _db.collection('movimientos_caja').doc();
      transaction.set(nuevoMovimientoRef, nuevoMovimiento.toFirestore());

      transaction.set(saldoRef, {'saldoTotal': nuevoSaldo}, SetOptions(merge: true));
    });
  }
}
