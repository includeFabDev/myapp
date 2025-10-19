import 'package:flutter/material.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/models/archivo_adjunto.dart';
import 'package:myapp/models/comentario.dart';
import 'package:myapp/models/log_cambio.dart';
import 'package:myapp/models/participante.dart';
import 'package:myapp/screens/reportes_screen.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firebase_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final Actividad actividad;

  const ActivityDetailsScreen({
    super.key,
    required this.actividad,
  });

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> with TickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs.', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.actividad.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Ver Reportes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportesScreen(actividad: widget.actividad),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Añadir Participante',
            onPressed: () => _mostrarDialogoNuevoParticipante(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Participantes', icon: Icon(Icons.people)),
            Tab(text: 'Historial', icon: Icon(Icons.history)),
            Tab(text: 'Comentarios', icon: Icon(Icons.comment)),
            Tab(text: 'Archivos', icon: Icon(Icons.attach_file)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de Participantes
          StreamBuilder<List<Participante>>(
            stream: _firebaseService.getParticipantes(widget.actividad.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay participantes todavía.\nToca el botón + para añadir uno.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              final participantes = snapshot.data!;
              return ListView.builder(
                itemCount: participantes.length,
                itemBuilder: (context, index) {
                  final participante = participantes[index];
                  final deuda = (participante.llevo * widget.actividad.precioChoripan) - participante.pagos;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(participante.nombre.isNotEmpty ? participante.nombre.substring(0, 1).toUpperCase() : '?'),
                      ),
                      title: Text(participante.nombre, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        'Vendido: ${participante.llevo}',
                      ),
                      trailing: Text(
                        'Deuda: ${currencyFormat.format(deuda)}',
                        style: TextStyle(
                          color: deuda > 0.1 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _mostrarDialogoEditarVentas(context, participante),
                      onLongPress: () => _confirmDeleteParticipante(context, participante),
                    ),
                  );
                },
              );
            },
          ),
          // Pestaña de Historial
          StreamBuilder<List<LogCambio>>(
            stream: _firebaseService.getLogsCambios(widget.actividad.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay cambios registrados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              final logs = snapshot.data!;
              return ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        log.tipoCambio == 'crear' ? Icons.add_circle :
                        log.tipoCambio == 'actualizar' ? Icons.edit :
                        Icons.delete,
                        color: log.tipoCambio == 'eliminar' ? Colors.red : Colors.blue,
                      ),
                      title: Text(log.descripcion),
                      subtitle: Text(
                        '${log.usuarioNombre} - ${DateFormat('dd/MM/yyyy HH:mm').format(log.fecha)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Pestaña de Comentarios
          StreamBuilder<List<Comentario>>(
            stream: _firebaseService.getComentarios(widget.actividad.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final comentarios = snapshot.data ?? [];
              return Column(
                children: [
                  Expanded(
                    child: comentarios.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay comentarios.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: comentarios.length,
                            itemBuilder: (context, index) {
                              final comentario = comentarios[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(comentario.usuarioNombre.isNotEmpty ? comentario.usuarioNombre.substring(0, 1).toUpperCase() : '?'),
                                  ),
                                  title: Text(comentario.usuarioNombre),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(comentario.texto),
                                      Text(
                                        DateFormat('dd/MM/yyyy HH:mm').format(comentario.fecha),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Escribe un comentario...',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (texto) => _agregarComentario(texto),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () => _agregarComentario(_commentController.text),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          // Pestaña de Archivos
          StreamBuilder<List<ArchivoAdjunto>>(
            stream: _firebaseService.getArchivosAdjuntos(widget.actividad.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay archivos adjuntos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              final archivos = snapshot.data!;
              return ListView.builder(
                itemCount: archivos.length,
                itemBuilder: (context, index) {
                  final archivo = archivos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        archivo.tipo == 'imagen' ? Icons.image :
                        archivo.tipo == 'pdf' ? Icons.picture_as_pdf :
                        Icons.insert_drive_file,
                      ),
                      title: Text(archivo.nombre),
                      subtitle: Text(
                        '${archivo.usuarioNombre} - ${DateFormat('dd/MM/yyyy HH:mm').format(archivo.fechaSubida)}',
                      ),
                      trailing: Text('${(archivo.tamanoBytes / 1024).round()} KB'),
                      onTap: () => _abrirArchivo(archivo),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoNuevoParticipante(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String nombre = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Participante'),
          content: Form(
            key: formKey,
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) => value == null || value.isEmpty ? 'Ingresa un nombre' : null,
              onSaved: (value) => nombre = value!,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final nuevoParticipante = Participante(nombre: nombre);
                  final authService = Provider.of<AuthService>(context, listen: false);
                  final user = authService.user;
                  if (user != null) {
                    await _firebaseService.addParticipante(widget.actividad.id, nuevoParticipante, user.uid, user.displayName ?? user.email ?? 'Usuario');
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEditarVentas(BuildContext context, Participante participante) {
    final formKey = GlobalKey<FormState>();
    int llevo = participante.llevo;
    double pagoEfectivo = participante.pagoEfectivo;
    double pagoQr = participante.pagoQr;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Registrar para ${participante.nombre}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: llevo.toString(),
                  decoration: const InputDecoration(labelText: 'Cantidad Vendida', prefixIcon: Icon(Icons.shopping_cart)),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => llevo = int.tryParse(value ?? '0') ?? 0,
                ),
                TextFormField(
                  initialValue: pagoEfectivo.toString(),
                  decoration: const InputDecoration(labelText: 'Pago en Efectivo', prefixText: 'Bs.', prefixIcon: Icon(Icons.money)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onSaved: (value) => pagoEfectivo = double.tryParse(value ?? '0') ?? 0,
                ),
                 TextFormField(
                  initialValue: pagoQr.toString(),
                  decoration: const InputDecoration(labelText: 'Pago con QR', prefixText: 'Bs.', prefixIcon: Icon(Icons.qr_code)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onSaved: (value) => pagoQr = double.tryParse(value ?? '0') ?? 0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final participanteActualizado = participante.copyWith(
                    llevo: llevo,
                    pagoEfectivo: pagoEfectivo,
                    pagoQr: pagoQr,
                  );
                  final authService = Provider.of<AuthService>(context, listen: false);
                  final user = authService.user;
                  if (user != null) {
                    await _firebaseService.updateParticipante(
                      widget.actividad.id,
                      participanteActualizado,
                      user.uid,
                      user.displayName ?? user.email ?? 'Usuario',
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteParticipante(BuildContext context, Participante participante) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar Eliminación'),
            content: Text('¿Estás seguro de que deseas eliminar a ${participante.nombre}?\nEsta acción no se puede deshacer.'),
            actions: <Widget>[
              TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(context).pop()),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Eliminar'),
                  onPressed: () async {
                     // ¡CORREGIDO! La llamada a la función ya está activa.
                     if (participante.id != null) {
                       final authService = Provider.of<AuthService>(context, listen: false);
                       final user = authService.user;
                       if (user != null) {
                         await _firebaseService.deleteParticipante(widget.actividad.id, participante.id!, user.uid, user.displayName ?? user.email ?? 'Usuario');
                       }
                     }
                     Navigator.of(context).pop();
                     ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Participante eliminado'),
                          backgroundColor: Colors.green,
                        )
                     );
                  }
              ),
            ],
          );
        });
  }

  void _agregarComentario(String texto) async {
    if (texto.trim().isEmpty) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    if (user == null) return;

    final comentario = Comentario(
      id: '',
      usuarioId: user.uid,
      usuarioNombre: user.displayName ?? user.email ?? 'Usuario',
      fecha: DateTime.now(),
      texto: texto.trim(),
    );

    await _firebaseService.addComentario(widget.actividad.id, comentario, user.uid, user.displayName ?? user.email ?? 'Usuario');
    _commentController.clear();
  }

  void _abrirArchivo(ArchivoAdjunto archivo) {
    // Implementar apertura de archivo (por ejemplo, usando url_launcher para abrir en navegador)
    // Por ahora, mostrar un snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abriendo ${archivo.nombre}')),
    );
  }
}
