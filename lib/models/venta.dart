import 'package:cloud_firestore/cloud_firestore.dart';

class Venta {
  String? id;
  final String participanteId;
  final int cantidad;
  final DateTime fecha;

  Venta({
    this.id,
    required this.participanteId,
    required this.cantidad,
    required this.fecha,
  });

  // Fábrica para crear una Venta desde un documento de Firestore
  factory Venta.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Venta(
      id: doc.id,
      participanteId: data['participanteId'] ?? '',
      cantidad: (data['cantidad'] as num?)?.toInt() ?? 0,
      fecha: (data['fecha'] as Timestamp).toDate(),
    );
  }

  // Método para convertir una Venta a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'participanteId': participanteId,
      'cantidad': cantidad,
      'fecha': Timestamp.fromDate(fecha),
    };
  }
}
