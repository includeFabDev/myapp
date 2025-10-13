import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/models/participante.dart';
import 'package:myapp/models/venta.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Métodos para Actividades
  Stream<List<Actividad>> getActividades() {
    return _db.collection('actividades').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Actividad.fromFirestore(doc)).toList());
  }

  Future<void> addActividad(Actividad actividad) {
    return _db.collection('actividades').add(actividad.toFirestore());
  }

  // Métodos para Participantes
  Stream<List<Participante>> getParticipantes() {
    return _db.collection('participantes').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Participante.fromFirestore(doc)).toList());
  }

  Future<void> addParticipante(Participante participante) {
    return _db.collection('participantes').add(participante.toFirestore());
  }

  // Métodos para Ventas
  Stream<List<Venta>> getVentas(String participanteId) {
    return _db
        .collection('ventas')
        .where('participanteId', isEqualTo: participanteId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Venta.fromFirestore(doc)).toList());
  }

  Future<void> addVenta(Venta venta, Participante participante) async {
    // Primero, añade el documento de la nueva venta
    await _db.collection('ventas').add(venta.toFirestore());

    // Luego, actualiza el campo 'llevo' del participante
    await _db.collection('participantes').doc(participante.id).update({
      'llevo': FieldValue.increment(venta.cantidad),
    });
  }

  // Método para Pagos
  Future<void> addPago(Participante participante, double monto) async {
    // Actualiza el campo 'pagos' del participante
    await _db.collection('participantes').doc(participante.id).update({
      'pagos': FieldValue.increment(monto),
    });
  }
}
