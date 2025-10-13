import 'package:cloud_firestore/cloud_firestore.dart';

class Participante {
  String? id;
  String nombre;
  String actividadId;
  int meta;
  int llevo;
  double pagos; // Añadido para registrar los pagos

  Participante({
    this.id,
    required this.nombre,
    required this.actividadId,
    this.meta = 0,
    this.llevo = 0,
    this.pagos = 0.0, // Inicializado en 0
  });

  factory Participante.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Participante(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      actividadId: data['actividad_id'] ?? '',
      meta: (data['meta'] as num?)?.toInt() ?? 0,
      llevo: (data['llevo'] as num?)?.toInt() ?? 0,
      pagos: (data['pagos'] as num?)?.toDouble() ?? 0.0, // Añadido
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'actividad_id': actividadId,
      'meta': meta,
      'llevo': llevo,
      'pagos': pagos, // Añadido
    };
  }
   double calcularDeuda(double precioChoripan) {
    final totalRecaudado = llevo * precioChoripan;
    return totalRecaudado - pagos;
  }
}
