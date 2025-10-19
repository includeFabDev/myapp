import 'package:cloud_firestore/cloud_firestore.dart';

class LogCambio {
  final String id;
  final String tipoEntidad; // 'actividad', 'participante', 'venta', 'pago', 'gasto'
  final String entidadId;
  final String tipoCambio; // 'crear', 'actualizar', 'eliminar'
  final String usuarioId;
  final String usuarioNombre;
  final DateTime fecha;
  final String descripcion;
  final Map<String, dynamic>? valoresAnteriores;
  final Map<String, dynamic>? valoresNuevos;

  LogCambio({
    required this.id,
    required this.tipoEntidad,
    required this.entidadId,
    required this.tipoCambio,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.fecha,
    required this.descripcion,
    this.valoresAnteriores,
    this.valoresNuevos,
  });

  factory LogCambio.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LogCambio(
      id: doc.id,
      tipoEntidad: data['tipoEntidad'] ?? '',
      entidadId: data['entidadId'] ?? '',
      tipoCambio: data['tipoCambio'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      usuarioNombre: data['usuarioNombre'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      descripcion: data['descripcion'] ?? '',
      valoresAnteriores: data['valoresAnteriores'],
      valoresNuevos: data['valoresNuevos'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tipoEntidad': tipoEntidad,
      'entidadId': entidadId,
      'tipoCambio': tipoCambio,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'fecha': Timestamp.fromDate(fecha),
      'descripcion': descripcion,
      'valoresAnteriores': valoresAnteriores,
      'valoresNuevos': valoresNuevos,
    };
  }
}
