import 'package:cloud_firestore/cloud_firestore.dart';

class MovimientoCaja {
  final String id;
  final String tipo; // 'ingreso' | 'egreso'
  final double monto;
  final String descripcion;
  final DateTime fecha;
  final String? relacionActividad;
  final double saldoResultante;

  MovimientoCaja({
    required this.id,
    required this.tipo,
    required this.monto,
    required this.descripcion,
    required this.fecha,
    this.relacionActividad,
    required this.saldoResultante,
  });

  factory MovimientoCaja.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MovimientoCaja(
      id: doc.id,
      tipo: data['tipo'] ?? 'ingreso',
      monto: (data['monto'] ?? 0.0).toDouble(),
      descripcion: data['descripcion'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      relacionActividad: data['relacion_actividad'],
      saldoResultante: (data['saldo_resultante'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tipo': tipo,
      'monto': monto,
      'descripcion': descripcion,
      'fecha': Timestamp.fromDate(fecha),
      if (relacionActividad != null) 'relacion_actividad': relacionActividad,
      'saldo_resultante': saldoResultante,
    };
  }
}
