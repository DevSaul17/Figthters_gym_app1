import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../../services/firestore_service.dart';

class AgregarHorarioCitaScreen extends StatefulWidget {
  const AgregarHorarioCitaScreen({super.key});

  @override
  State<AgregarHorarioCitaScreen> createState() =>
      _AgregarHorarioCitaScreenState();
}

class _AgregarHorarioCitaScreenState extends State<AgregarHorarioCitaScreen> {
  // Firestore service
  final FirestoreService _firestore = FirestoreService();
  int _reloadKey = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80.0,
        title: Text(
          'HORARIOS DE CITAS',
          style: AppTextStyles.appBarTitle.copyWith(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        key: ValueKey(_reloadKey),
        stream: _firestore.streamCollection(
          'citas',
          // Order by the appointment `fecha` so documents with a `fecha` field
          // (Timestamp) are listed by appointment date/time. Using 'fecha'
          // is safer because some documents may not have `creadoEn` set.
          queryBuilder: (q) => q.orderBy('fecha', descending: false),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final err = snapshot.error;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error al cargar citas',
                      style: AppTextStyles.mainText.copyWith(color: Colors.red),
                    ),
                    SizedBox(height: 8),
                    Text(
                      err?.toString() ?? 'Error desconocido',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => setState(() => _reloadKey++),
                      child: Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final cita = {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              };
              return _buildCitaItem(cita, index, doc);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarAAgregarCita,
        backgroundColor: Colors.grey[400],
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No hay citas programadas',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Presiona el botón + para agregar una nueva cita',
            style: AppTextStyles.contactText.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCitaItem(
    Map<String, dynamic> cita,
    int index,
    DocumentSnapshot doc,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono de calendario
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          // Información de la cita
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatFecha(cita['fecha']),
                  style: AppTextStyles.mainText.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  // Some documents may not include `tipoServicio` (see screenshot).
                  // Provide a safe fallback so the Text widget never receives null.
                  (cita['tipoServicio'] as String?) ?? 'Cita general',
                  style: AppTextStyles.contactText.copyWith(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Botones de acción
          Row(
            children: [
              IconButton(
                onPressed: () => _editarCitaDoc(doc),
                icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              SizedBox(width: 8),
              IconButton(
                onPressed: () => _eliminarCitaDoc(doc),
                icon: Icon(Icons.delete, color: Colors.red, size: 20),
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navegarAAgregarCita() {
    DateTime? fechaSeleccionada;
    TimeOfDay? horaSeleccionada;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Agregar Nueva Cita',
            style: AppTextStyles.mainText.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Seleccionar fecha
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final DateTime? fecha = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                        helpText: 'Seleccionar fecha de la cita',
                        cancelText: 'Cancelar',
                        confirmText: 'Confirmar',
                      );
                      if (fecha != null) {
                        setDialogState(() {
                          fechaSeleccionada = fecha;
                        });
                      }
                    },
                    icon: Icon(Icons.calendar_today),
                    label: Text(
                      fechaSeleccionada != null
                          ? '${fechaSeleccionada!.day.toString().padLeft(2, '0')}/${fechaSeleccionada!.month.toString().padLeft(2, '0')}/${fechaSeleccionada!.year}'
                          : 'Seleccionar Fecha',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Seleccionar hora
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final TimeOfDay? hora = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        helpText: 'Seleccionar hora de la cita',
                        cancelText: 'Cancelar',
                        confirmText: 'Confirmar',
                      );
                      if (hora != null) {
                        setDialogState(() {
                          horaSeleccionada = hora;
                        });
                      }
                    },
                    icon: Icon(Icons.access_time),
                    label: Text(
                      horaSeleccionada != null
                          ? horaSeleccionada!.format(context)
                          : 'Seleccionar Hora',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: fechaSeleccionada != null && horaSeleccionada != null
                  ? () async {
                      // Construir datos de la cita
                      // Combinar fecha y hora en un único DateTime y guardar como Timestamp
                      final combined = DateTime(
                        fechaSeleccionada!.year,
                        fechaSeleccionada!.month,
                        fechaSeleccionada!.day,
                        horaSeleccionada!.hour,
                        horaSeleccionada!.minute,
                      );

                      final nuevaCita = {
                        // Guardar sólo los campos mínimos requeridos por Firestore
                        // vista: `fecha`, `disponible`, `prospectoId`.
                        // `fecha` se guarda en UTC para evitar discrepancias.
                        'fecha': Timestamp.fromDate(combined.toUtc()),
                        'disponible': true,
                        'prospectoId': null,
                      };

                      try {
                        // Guardar en Firestore en la colección 'citas'
                        await _firestore.addDocument('citas', nuevaCita);

                        // La lista se actualiza automáticamente desde Firestore (stream)

                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Cita agregada exitosamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        // Manejar error
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al agregar cita: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _editarCitaDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Convertir la fecha de string a DateTime
    // Read Timestamp from Firestore and convert to DateTime/TimeOfDay
    DateTime existingFecha;
    final rawFecha = data['fecha'];
    if (rawFecha is Timestamp) {
      existingFecha = rawFecha.toDate();
    } else if (rawFecha is DateTime) {
      existingFecha = rawFecha;
    } else {
      existingFecha = DateTime.now();
    }
    DateTime? fechaSeleccionada = DateTime(
      existingFecha.year,
      existingFecha.month,
      existingFecha.day,
    );
    TimeOfDay? horaSeleccionada = TimeOfDay(
      hour: existingFecha.hour,
      minute: existingFecha.minute,
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Editar Cita',
            style: AppTextStyles.mainText.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Información actual
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    // ignore: deprecated_member_use
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cita actual:',
                        style: AppTextStyles.contactText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: 4),
                      // Show the formatted fecha using our helper so timezone
                      // conversion is handled consistently (we stored UTC above).
                      Text(
                        _formatFecha(data['fecha']),
                        style: AppTextStyles.contactText.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        data['tipoServicio'] ?? 'Cita general',
                        style: AppTextStyles.contactText.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Selecciona nueva fecha y hora:',
                  style: AppTextStyles.contactText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                // Seleccionar nueva fecha
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final DateTime? fecha = await showDatePicker(
                        context: context,
                        initialDate: fechaSeleccionada ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                        helpText: 'Seleccionar nueva fecha',
                        cancelText: 'Cancelar',
                        confirmText: 'Confirmar',
                      );
                      if (fecha != null) {
                        setDialogState(() {
                          fechaSeleccionada = fecha;
                        });
                      }
                    },
                    icon: Icon(Icons.calendar_today),
                    label: Text(
                      fechaSeleccionada != null
                          ? '${fechaSeleccionada!.day.toString().padLeft(2, '0')}/${fechaSeleccionada!.month.toString().padLeft(2, '0')}/${fechaSeleccionada!.year}'
                          : 'Seleccionar Fecha',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // Seleccionar nueva hora
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final TimeOfDay? hora = await showTimePicker(
                        context: context,
                        initialTime: horaSeleccionada ?? TimeOfDay.now(),
                        helpText: 'Seleccionar nueva hora',
                        cancelText: 'Cancelar',
                        confirmText: 'Confirmar',
                      );
                      if (hora != null) {
                        setDialogState(() {
                          horaSeleccionada = hora;
                        });
                      }
                    },
                    icon: Icon(Icons.access_time),
                    label: Text(
                      horaSeleccionada != null
                          ? horaSeleccionada!.format(context)
                          : 'Seleccionar Hora',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: fechaSeleccionada != null && horaSeleccionada != null
                  ? () async {
                      final combined = DateTime(
                        fechaSeleccionada!.year,
                        fechaSeleccionada!.month,
                        fechaSeleccionada!.day,
                        horaSeleccionada!.hour,
                        horaSeleccionada!.minute,
                      );

                      try {
                        await _firestore.updateDocument('citas', doc.id, {
                          'fecha': Timestamp.fromDate(combined),
                        });

                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Cita actualizada exitosamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al actualizar cita: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  void _eliminarCitaDoc(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Cita'),
        content: Text('¿Estás seguro de que quieres eliminar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _firestore.deleteDocument('citas', doc.id);
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cita eliminada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar cita: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatFecha(dynamic rawFecha) {
    if (rawFecha == null) return '-';
    DateTime dt;
    if (rawFecha is Timestamp) {
      dt = rawFecha.toDate();
    } else if (rawFecha is DateTime) {
      dt = rawFecha;
    } else if (rawFecha is String) {
      try {
        dt = DateTime.parse(rawFecha);
      } catch (e) {
        return rawFecha.toString();
      }
    } else {
      return rawFecha.toString();
    }

    try {
      final df = DateFormat("d 'de' MMMM 'de' y, h:mm a", 'es');
      return df.format(dt.toLocal());
    } catch (e) {
      return dt.toLocal().toString();
    }
  }
}
