import 'package:cloud_firestore/cloud_firestore.dart';

class Inversion {
  String? id;
  final String descripcion;
  final double monto;
  final DateTime fecha;

  Inversion({
    this.id,
    required this.descripcion,
    required this.monto,
    required this.fecha,
  });

  factory Inversion.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Inversion(
      id: doc.id,
      descripcion: data['descripcion'] ?? '',
      monto: (data['monto'] ?? 0.0).toDouble(),
      fecha: (data['fecha'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'descripcion': descripcion,
      'monto': monto,
      'fecha': Timestamp.fromDate(fecha),
    };
  }
}
