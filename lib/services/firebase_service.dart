import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/models/archivo_adjunto.dart';
import 'package:myapp/models/comentario.dart';
import 'package:myapp/models/gasto.dart';
import 'package:myapp/models/log_cambio.dart';
import 'package:myapp/models/movimiento_caja.dart';
import 'package:myapp/models/participante.dart';
import 'package:myapp/models/venta.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // MÉTODOS PARA ACTIVIDADES
  //----------------------------------------------------------------

  Stream<List<Actividad>> getActividades() {
    return _db
        .collection('actividades')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
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

  Future<void> addParticipante(String actividadId, Participante participante, String usuarioId, String usuarioNombre) {
    return _db.runTransaction((transaction) async {
      final participanteRef = _db
          .collection('actividades')
          .doc(actividadId)
          .collection('participantes')
          .doc();

      transaction.set(participanteRef, participante.toFirestore());

      final log = LogCambio(
        id: '',
        tipoEntidad: 'participante',
        entidadId: actividadId,
        tipoCambio: 'crear',
        usuarioId: usuarioId,
        usuarioNombre: usuarioNombre,
        fecha: DateTime.now(),
        descripcion: 'Se añadió a la actividad al participante ${participante.nombre}',
      );

      final logRef = _db.collection('logs_cambios').doc();
      transaction.set(logRef, log.toFirestore());
    });
  }

  Future<void> updateParticipante(String actividadId, Participante participante, String usuarioId, String usuarioNombre) {
    return _db.runTransaction((transaction) async {
      final participanteRef = _db
          .collection('actividades')
          .doc(actividadId)
          .collection('participantes')
          .doc(participante.id);

      final participanteSnapshot = await transaction.get(participanteRef);
      if (!participanteSnapshot.exists) {
        throw Exception('Participante no encontrado');
      }

      final participanteActual = Participante.fromFirestore(participanteSnapshot);

      transaction.update(participanteRef, participante.toFirestore());

      // Log for name change
      if (participanteActual.nombre != participante.nombre) {
        final log = LogCambio(
          id: '',
          tipoEntidad: 'participante',
          entidadId: actividadId,
          tipoCambio: 'actualizar',
          usuarioId: usuarioId,
          usuarioNombre: usuarioNombre,
          fecha: DateTime.now(),
          descripcion: 'Se actualizó el nombre del participante de "${participanteActual.nombre}" a "${participante.nombre}"',
        );
        final logRef = _db.collection('logs_cambios').doc();
        transaction.set(logRef, log.toFirestore());
      }

      // Log for sales change
      if (participanteActual.llevo != participante.llevo) {
        final log = LogCambio(
          id: '',
          tipoEntidad: 'venta',
          entidadId: actividadId,
          tipoCambio: 'actualizar',
          usuarioId: usuarioId,
          usuarioNombre: usuarioNombre,
          fecha: DateTime.now(),
          descripcion: 'Cantidad vendida de ${participante.nombre} actualizada de ${participanteActual.llevo} a ${participante.llevo}',
        );
        final logRef = _db.collection('logs_cambios').doc();
        transaction.set(logRef, log.toFirestore());
      }

      // Log for efectivo payment change
      if (participanteActual.pagoEfectivo != participante.pagoEfectivo) {
        final log = LogCambio(
          id: '',
          tipoEntidad: 'pago',
          entidadId: actividadId,
          tipoCambio: 'actualizar',
          usuarioId: usuarioId,
          usuarioNombre: usuarioNombre,
          fecha: DateTime.now(),
          descripcion: 'Pago en efectivo de ${participante.nombre} actualizado de ${participanteActual.pagoEfectivo} a ${participante.pagoEfectivo}',
        );
        final logRef = _db.collection('logs_cambios').doc();
        transaction.set(logRef, log.toFirestore());
      }

      // Log for QR payment change
      if (participanteActual.pagoQr != participante.pagoQr) {
        final log = LogCambio(
          id: '',
          tipoEntidad: 'pago',
          entidadId: actividadId,
          tipoCambio: 'actualizar',
          usuarioId: usuarioId,
          usuarioNombre: usuarioNombre,
          fecha: DateTime.now(),
          descripcion: 'Pago con QR de ${participante.nombre} actualizado de ${participanteActual.pagoQr} a ${participante.pagoQr}',
        );
        final logRef = _db.collection('logs_cambios').doc();
        transaction.set(logRef, log.toFirestore());
      }
    });
  }

  Future<void> deleteParticipante(String actividadId, String participanteId, String usuarioId, String usuarioNombre) {
    return _db.runTransaction((transaction) async {
      final participanteRef = _db
          .collection('actividades')
          .doc(actividadId)
          .collection('participantes')
          .doc(participanteId);

      final participanteSnapshot = await transaction.get(participanteRef);
      if (!participanteSnapshot.exists) {
        throw Exception('Participante no encontrado');
      }

      final participante = Participante.fromFirestore(participanteSnapshot);

      transaction.delete(participanteRef);

      final log = LogCambio(
        id: '',
        tipoEntidad: 'participante',
        entidadId: actividadId,
        tipoCambio: 'eliminar',
        usuarioId: usuarioId,
        usuarioNombre: usuarioNombre,
        fecha: DateTime.now(),
        descripcion: 'Se ha eliminado al participante ${participante.nombre}',
      );

      final logRef = _db.collection('logs_cambios').doc();
      transaction.set(logRef, log.toFirestore());
    });
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

  Future<void> addVenta(String actividadId, String participanteId, Venta venta, String usuarioId, String usuarioNombre) {
    return _db.runTransaction((transaction) async {
      final participanteRef = _db
          .collection('actividades')
          .doc(actividadId)
          .collection('participantes')
          .doc(participanteId);
      final ventaRef = participanteRef.collection('ventas').doc();

      final participanteSnapshot = await transaction.get(participanteRef);
      if (!participanteSnapshot.exists) {
        throw Exception('Participante no encontrado');
      }
      final participante = Participante.fromFirestore(participanteSnapshot);
      final cantidadAnterior = participante.llevo;

      transaction.update(participanteRef, {'llevo': FieldValue.increment(venta.cantidad)});
      transaction.set(ventaRef, venta.toFirestore());

      final log = LogCambio(
        id: '',
        tipoEntidad: 'venta',
        entidadId: actividadId,
        tipoCambio: 'crear',
        usuarioId: usuarioId,
        usuarioNombre: usuarioNombre,
        fecha: DateTime.now(),
        descripcion: 'Cantidad vendida de ${participante.nombre} de $cantidadAnterior a ${cantidadAnterior + venta.cantidad}',
      );

      final logRef = _db.collection('logs_cambios').doc();
      transaction.set(logRef, log.toFirestore());
    });
  }

  Future<void> updateVenta(String actividadId, String participanteId, Venta ventaOriginal, int nuevaCantidad, String usuarioId, String usuarioNombre) {
    return _db.runTransaction((transaction) async {
      final participanteRef = _db
          .collection('actividades')
          .doc(actividadId)
          .collection('participantes')
          .doc(participanteId);
      final ventaRef = participanteRef.collection('ventas').doc(ventaOriginal.id);

      final participanteSnapshot = await transaction.get(participanteRef);
      if (!participanteSnapshot.exists) {
        throw Exception('Participante no encontrado');
      }
      final participante = Participante.fromFirestore(participanteSnapshot);
      final cantidadAnterior = participante.llevo;

      final diferencia = nuevaCantidad - ventaOriginal.cantidad;
      transaction.update(participanteRef, {'llevo': FieldValue.increment(diferencia)});
      transaction.update(ventaRef, {'cantidad': nuevaCantidad});

      final log = LogCambio(
        id: '',
        tipoEntidad: 'venta',
        entidadId: actividadId,
        tipoCambio: 'actualizar',
        usuarioId: usuarioId,
        usuarioNombre: usuarioNombre,
        fecha: DateTime.now(),
        descripcion: 'Cantidad vendida de ${participante.nombre} actualizada de $cantidadAnterior a ${cantidadAnterior + diferencia}',
      );

      final logRef = _db.collection('logs_cambios').doc();
      transaction.set(logRef, log.toFirestore());
    });
  }

  Future<void> deleteVenta(String actividadId, String participanteId, Venta venta, String usuarioId, String usuarioNombre) {
    return _db.runTransaction((transaction) async {
      final participanteRef = _db
          .collection('actividades')
          .doc(actividadId)
          .collection('participantes')
          .doc(participanteId);
      final ventaRef = participanteRef.collection('ventas').doc(venta.id);

      final participanteSnapshot = await transaction.get(participanteRef);
      if (!participanteSnapshot.exists) {
        throw Exception('Participante no encontrado');
      }
      final participante = Participante.fromFirestore(participanteSnapshot);
      final cantidadAnterior = participante.llevo;

      transaction.update(participanteRef, {'llevo': FieldValue.increment(-venta.cantidad)});
      transaction.delete(ventaRef);

      final log = LogCambio(
        id: '',
        tipoEntidad: 'venta',
        entidadId: actividadId,
        tipoCambio: 'eliminar',
        usuarioId: usuarioId,
        usuarioNombre: usuarioNombre,
        fecha: DateTime.now(),
        descripcion: 'Cantidad vendida de ${participante.nombre} eliminada de $cantidadAnterior a ${cantidadAnterior - venta.cantidad}',
      );

      final logRef = _db.collection('logs_cambios').doc();
      transaction.set(logRef, log.toFirestore());
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

  // MÉTODOS PARA CONTROL DE CAJA
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
    required String usuarioId,
    required String usuarioNombre,
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

      final nuevoMovimientoRef = _db.collection('movimientos_caja').doc();
      final nuevoMovimiento = MovimientoCaja(
        id: nuevoMovimientoRef.id,
        tipo: tipo,
        monto: monto,
        descripcion: descripcion,
        fecha: fecha,
        relacionActividad: relacionActividad,
        saldoResultante: nuevoSaldo,
      );

      transaction.set(nuevoMovimientoRef, nuevoMovimiento.toFirestore());
      transaction.set(saldoRef, {'saldoTotal': nuevoSaldo}, SetOptions(merge: true));

      final log = LogCambio(
        id: '',
        tipoEntidad: 'caja',
        entidadId: nuevoMovimientoRef.id,
        tipoCambio: 'crear',
        usuarioId: usuarioId,
        usuarioNombre: usuarioNombre,
        fecha: DateTime.now(),
        descripcion: 'Se creó un $tipo de Bs. $monto: "$descripcion"',
      );

      final logRef = _db.collection('logs_caja').doc();
      transaction.set(logRef, log.toFirestore());
    });
  }

  Future<void> updateMovimientoCaja({
    required String movimientoId,
    required String tipo,
    required double monto,
    required String descripcion,
    required DateTime fecha,
    String? relacionActividad,
    required String usuarioId,
    required String usuarioNombre,
  }) {
    final movimientoRef = _db.collection('movimientos_caja').doc(movimientoId);
    final saldoRef = _db.collection('caja_resumen').doc('saldo_actual');

    return _db.runTransaction((transaction) async {
      final movimientoSnapshot = await transaction.get(movimientoRef);
      if (!movimientoSnapshot.exists) {
        throw Exception('Movimiento no encontrado');
      }
      final movimientoActual = MovimientoCaja.fromFirestore(movimientoSnapshot);

      final saldoSnapshot = await transaction.get(saldoRef);
      double saldoActual = 0.0;
      if (saldoSnapshot.exists && saldoSnapshot.data() != null) {
        saldoActual = (saldoSnapshot.data()!['saldoTotal'] ?? 0.0).toDouble();
      }

      double saldoRevertido;
      if (movimientoActual.tipo == 'ingreso') {
        saldoRevertido = saldoActual - movimientoActual.monto;
      } else {
        saldoRevertido = saldoActual + movimientoActual.monto;
      }

      double nuevoSaldo;
      if (tipo == 'ingreso') {
        nuevoSaldo = saldoRevertido + monto;
      } else {
        nuevoSaldo = saldoRevertido - monto;
      }

      final movimientoActualizado = MovimientoCaja(
        id: movimientoId,
        tipo: tipo,
        monto: monto,
        descripcion: descripcion,
        fecha: fecha,
        relacionActividad: relacionActividad,
        saldoResultante: nuevoSaldo,
      );

      transaction.update(movimientoRef, movimientoActualizado.toFirestore());
      transaction.set(saldoRef, {'saldoTotal': nuevoSaldo}, SetOptions(merge: true));

      final log = LogCambio(
        id: '',
        tipoEntidad: 'caja',
        entidadId: movimientoId,
        tipoCambio: 'actualizar',
        usuarioId: usuarioId,
        usuarioNombre: usuarioNombre,
        fecha: DateTime.now(),
        descripcion: 'Se actualizó un movimiento. Antes: ${movimientoActual.tipo} Bs. ${movimientoActual.monto}. Ahora: $tipo Bs. $monto: "$descripcion"',
      );
      final logRef = _db.collection('logs_caja').doc();
      transaction.set(logRef, log.toFirestore());
    });
  }

  Future<void> deleteMovimientoCaja({
    required String movimientoId,
    required String usuarioId,
    required String usuarioNombre,
  }) {
    final movimientoRef = _db.collection('movimientos_caja').doc(movimientoId);
    final saldoRef = _db.collection('caja_resumen').doc('saldo_actual');

    return _db.runTransaction((transaction) async {
      final movimientoSnapshot = await transaction.get(movimientoRef);
      if (!movimientoSnapshot.exists) {
        throw Exception('Movimiento no encontrado');
      }
      final movimiento = MovimientoCaja.fromFirestore(movimientoSnapshot);

      final saldoSnapshot = await transaction.get(saldoRef);
      double saldoActual = 0.0;
      if (saldoSnapshot.exists && saldoSnapshot.data() != null) {
        saldoActual = (saldoSnapshot.data()!['saldoTotal'] ?? 0.0).toDouble();
      }

      double nuevoSaldo;
      if (movimiento.tipo == 'ingreso') {
        nuevoSaldo = saldoActual - movimiento.monto;
      } else {
        nuevoSaldo = saldoActual + movimiento.monto;
      }

      transaction.delete(movimientoRef);
      transaction.set(saldoRef, {'saldoTotal': nuevoSaldo}, SetOptions(merge: true));

      final log = LogCambio(
        id: '',
        tipoEntidad: 'caja',
        entidadId: movimientoId,
        tipoCambio: 'eliminar',
        usuarioId: usuarioId,
        usuarioNombre: usuarioNombre,
        fecha: DateTime.now(),
        descripcion: 'Se eliminó el movimiento de ${movimiento.tipo} de Bs. ${movimiento.monto}: "${movimiento.descripcion}"',
      );
      final logRef = _db.collection('logs_caja').doc();
      transaction.set(logRef, log.toFirestore());
    });
  }


  // MÉTODOS PARA LOGS DE CAMBIOS (AUDITORÍA)
  //----------------------------------------------------------------
   Stream<List<LogCambio>> getHistorialCaja() {
    return _db
        .collection('logs_caja')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LogCambio.fromFirestore(doc)).toList());
  }

  Future<void> addLogCambio(LogCambio log) {
    return _db.collection('logs_cambios').add(log.toFirestore());
  }

  Stream<List<LogCambio>> getLogsCambios(String actividadId) {
    return _db
        .collection('logs_cambios')
        .where('entidadId', isEqualTo: actividadId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LogCambio.fromFirestore(doc)).toList());
  }

  // MÉTODOS PARA COMENTARIOS
  //----------------------------------------------------------------

  Stream<List<Comentario>> getComentarios(String actividadId) {
    return _db
        .collection('actividades')
        .doc(actividadId)
        .collection('comentarios')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Comentario.fromFirestore(doc)).toList());
  }

  Future<void> addComentario(String actividadId, Comentario comentario, String usuarioId, String usuarioNombre) {
    return _db.runTransaction((transaction) async {
      final comentarioRef = _db
          .collection('actividades')
          .doc(actividadId)
          .collection('comentarios')
          .doc();

      transaction.set(comentarioRef, comentario.toFirestore());

      final log = LogCambio(
        id: '',
        tipoEntidad: 'comentario',
        entidadId: actividadId,
        tipoCambio: 'crear',
        usuarioId: usuarioId,
        usuarioNombre: usuarioNombre,
        fecha: DateTime.now(),
        descripcion: 'Comentario agregado: ${comentario.texto}',
      );

      final logRef = _db.collection('logs_cambios').doc();
      transaction.set(logRef, log.toFirestore());
    });
  }

  // MÉTODOS PARA ARCHIVOS ADJUNTOS
  //----------------------------------------------------------------

  Stream<List<ArchivoAdjunto>> getArchivosAdjuntos(String actividadId) {
    return _db
        .collection('actividades')
        .doc(actividadId)
        .collection('archivos_adjuntos')
        .orderBy('fechaSubida', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ArchivoAdjunto.fromFirestore(doc))
            .toList());
  }

  Future<void> addArchivoAdjunto(String actividadId, ArchivoAdjunto archivo) {
    return _db
        .collection('actividades')
        .doc(actividadId)
        .collection('archivos_adjuntos')
        .add(archivo.toFirestore());
  }

  Future<void> deleteArchivoAdjunto(String actividadId, String archivoId) {
    return _db
        .collection('actividades')
        .doc(actividadId)
        .collection('archivos_adjuntos')
        .doc(archivoId)
        .delete();
  }

  Stream<List<Map<String, dynamic>>>? getParticipantesUnicos() {
    return null;
  }
}
