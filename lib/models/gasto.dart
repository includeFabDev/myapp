
import 'package:cloud_firestore/cloud_firestore.dart';

class Gasto {
  final String id;
  final String descripcion;
  final double monto;
  final DateTime fecha;

  Gasto({
    required this.id,
    required this.descripcion,
    required this.monto,
    required this.fecha,
  });

  // Factory constructor to create a Gasto from a Firestore document
  factory Gasto.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Gasto(
      id: doc.id,
      descripcion: data['descripcion'] ?? '',
      monto: (data['monto'] ?? 0.0).toDouble(),
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Method to convert a Gasto instance to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'descripcion': descripcion,
      'monto': monto,
      'fecha': Timestamp.fromDate(fecha),
    };
  }
}

