import 'package:cloud_firestore/cloud_firestore.dart';

class Actividad {
  final String id; // Corregido: El ID nunca es nulo
  String nombre;
  String descripcion;
  DateTime fecha;
  double precioChoripan;

  Actividad({
    required this.id, // Corregido: Se requiere en el constructor
    required this.nombre,
    required this.descripcion,
    required this.fecha,
    this.precioChoripan = 0.0,
  });

  // Fábrica para crear una Actividad desde un documento de Firestore
  factory Actividad.fromFirestore(DocumentSnapshot doc) { // Se quita el tipo genérico innecesario
    final data = doc.data() as Map<String, dynamic>; // Se hace el casteo aquí

    return Actividad(
      id: doc.id, // Siempre habrá un ID
      nombre: data['nombre'] as String? ?? '',
      descripcion: data['descripcion'] as String? ?? '',
      // El campo 'fecha' en Firestore es un Timestamp, hay que convertirlo a DateTime
      fecha: (data['fecha'] as Timestamp).toDate(),
      // Se lee el precio, con un valor por defecto de 0.0 si no existe
      precioChoripan: (data['precioChoripan'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Método para convertir una Actividad a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      // Se convierte el DateTime a un Timestamp de Firestore para guardarlo
      'fecha': Timestamp.fromDate(fecha),
      'precioChoripan': precioChoripan,
    };
  }
}
