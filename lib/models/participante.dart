import 'package:cloud_firestore/cloud_firestore.dart';

class Participante {
  String? id;
  final String nombre;
  final int meta;
  int llevo;
  final double pagoEfectivo;
  final double pagoQr;

  // Getter para calcular el total de pagos
  double get pagos => pagoEfectivo + pagoQr;

  Participante({
    this.id,
    required this.nombre,
    this.meta = 0, // Meta ya no es obligatoria
    this.llevo = 0,
    this.pagoEfectivo = 0.0,
    this.pagoQr = 0.0,
  });

  Participante copyWith({
    String? id,
    String? nombre,
    int? meta,
    int? llevo,
    double? pagoEfectivo,
    double? pagoQr,
  }) {
    return Participante(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      meta: meta ?? this.meta,
      llevo: llevo ?? this.llevo,
      pagoEfectivo: pagoEfectivo ?? this.pagoEfectivo,
      pagoQr: pagoQr ?? this.pagoQr,
    );
  }

  // Fábrica para crear un Participante desde un documento de Firestore
  factory Participante.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Participante(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      meta: data['meta'] ?? 0,
      llevo: data['llevo'] ?? 0,
      pagoEfectivo: (data['pagoEfectivo'] as num?)?.toDouble() ?? 0.0,
      pagoQr: (data['pagoQr'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Método para convertir un Participante a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'meta': meta,
      'llevo': llevo,
      'pagoEfectivo': pagoEfectivo,
      'pagoQr': pagoQr,
    };
  }
}
