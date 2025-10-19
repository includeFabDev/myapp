import 'package:cloud_firestore/cloud_firestore.dart';

class ArchivoAdjunto {
  final String id;
  final String nombre;
  final String url;
  final String tipo; // 'imagen', 'pdf', 'documento', etc.
  final int tamanoBytes;
  final String usuarioId;
  final String usuarioNombre;
  final DateTime fechaSubida;

  ArchivoAdjunto({
    required this.id,
    required this.nombre,
    required this.url,
    required this.tipo,
    required this.tamanoBytes,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.fechaSubida,
  });

  factory ArchivoAdjunto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArchivoAdjunto(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      url: data['url'] ?? '',
      tipo: data['tipo'] ?? '',
      tamanoBytes: data['tamanoBytes'] ?? 0,
      usuarioId: data['usuarioId'] ?? '',
      usuarioNombre: data['usuarioNombre'] ?? '',
      fechaSubida: (data['fechaSubida'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'url': url,
      'tipo': tipo,
      'tamanoBytes': tamanoBytes,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'fechaSubida': Timestamp.fromDate(fechaSubida),
    };
  }
}
