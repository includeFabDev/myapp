import 'package:cloud_firestore/cloud_firestore.dart';

class Actividad {
  String? id;
  String nombre;
  String descripcion;
  DateTime fecha;
  double precioChoripan; // Precio por unidad para los cálculos

  Actividad({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.fecha,
    this.precioChoripan = 0.0,
  });

  // Conversión de un Documento de Firestore a un objeto Actividad
  factory Actividad.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Actividad(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      // El campo 'fecha' se almacena como Timestamp en Firestore
      fecha: (data['fecha'] as Timestamp).toDate(),
      precioChoripan: (data['precioChoripan'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Conversión de un objeto Actividad a un Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'fecha': Timestamp.fromDate(fecha),
      'precioChoripan': precioChoripan,
    };
  }
}
