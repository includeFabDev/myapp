import 'package:cloud_firestore/cloud_firestore.dart';

class Comentario {
  final String id;
  final String usuarioId;
  final String usuarioNombre;
  final DateTime fecha;
  final String texto;

  Comentario({
    required this.id,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.fecha,
    required this.texto,
  });

  factory Comentario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comentario(
      id: doc.id,
      usuarioId: data['usuarioId'] ?? '',
      usuarioNombre: data['usuarioNombre'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      texto: data['texto'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'fecha': Timestamp.fromDate(fecha),
      'texto': texto,
    };
  }
}
