import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../constants.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  String _filtroEstado =
      'todos'; // 'todos', 'activas', 'inactivas', 'completadas'

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    try {
      await initializeDateFormatting('es_ES', null);
    } catch (e) {
      // Ignore error if localization fails
      debugPrint('Error initializing date formatting: $e');
    }
  }

  // Método para determinar si una cita es activa o inactiva
  bool _esCitaActiva(Map<String, dynamic> data) {
    final rawCita = data['citaFecha'];

    // Si no tiene fecha, es inactiva
    if (rawCita == null) {
      return false;
    }

    // Convertir la fecha a DateTime
    DateTime? citaDateTime;
    if (rawCita is Timestamp) {
      citaDateTime = rawCita.toDate();
    } else if (rawCita is DateTime) {
      citaDateTime = rawCita;
    } else if (rawCita is String) {
      try {
        citaDateTime = DateTime.parse(rawCita);
      } catch (e) {
        return false;
      }
    }

    if (citaDateTime == null) {
      return false;
    }

    // Obtener la fecha actual (sin hora)
    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);

    // Obtener la fecha de la cita (sin hora)
    final fechaCita = DateTime(
      citaDateTime.year,
      citaDateTime.month,
      citaDateTime.day,
    );

    // Es activa si la fecha es hoy o en el futuro
    return fechaCita.isAtSameMomentAs(hoy) || fechaCita.isAfter(hoy);
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar los prospectos como tarjetas tipo cita
    return Column(
      children: [
        // Filtros
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFiltroButton('Todos', 'todos'),
                SizedBox(width: 12),
                _buildFiltroButton('Activas', 'activas'),
                SizedBox(width: 12),
                _buildFiltroButton('Inactivas', 'inactivas'),
                SizedBox(width: 12),
                _buildFiltroButton('Citas Completadas', 'completadas'),
              ],
            ),
          ),
        ),
        // Lista de citas
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('prospectos')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'Error al cargar prospectos',
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                // Obtener y ordenar documentos en el cliente
                final allDocs = snapshot.data?.docs ?? [];
                final docs = allDocs.toList();

                // Filtrar según estado
                final docsFiltered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final esCompletada = data['completada'] == true;

                  // Filtrar por citas completadas
                  if (_filtroEstado == 'completadas') {
                    return esCompletada;
                  }

                  // Excluir citas completadas de otros filtros
                  if (esCompletada) {
                    return false;
                  }

                  final esActiva = _esCitaActiva(data);

                  if (_filtroEstado == 'activas') {
                    return esActiva;
                  } else if (_filtroEstado == 'inactivas') {
                    return !esActiva;
                  }
                  return true; // 'todos'
                }).toList();

                // Ordenar por fecha de cita (más cercanas primero)
                docsFiltered.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aCita = aData['citaFecha'];
                  final bCita = bData['citaFecha'];

                  // Convertir a DateTime para comparación
                  DateTime? aDateTime;
                  DateTime? bDateTime;

                  if (aCita is Timestamp) {
                    aDateTime = aCita.toDate();
                  } else if (aCita is String) {
                    try {
                      aDateTime = DateTime.parse(aCita);
                    } catch (e) {
                      aDateTime = null;
                    }
                  } else if (aCita is DateTime) {
                    aDateTime = aCita;
                  }

                  if (bCita is Timestamp) {
                    bDateTime = bCita.toDate();
                  } else if (bCita is String) {
                    try {
                      bDateTime = DateTime.parse(bCita);
                    } catch (e) {
                      bDateTime = null;
                    }
                  } else if (bCita is DateTime) {
                    bDateTime = bCita;
                  }

                  // Priorizar registros con cita sobre los que no tienen
                  if (aDateTime == null && bDateTime == null) {
                    // Si ambos no tienen cita, ordenar por fecha de creación
                    final aCreado = aData['creadoEn'] as Timestamp?;
                    final bCreado = bData['creadoEn'] as Timestamp?;
                    if (aCreado == null && bCreado == null) return 0;
                    if (aCreado == null) return 1;
                    if (bCreado == null) return -1;
                    return aCreado.compareTo(bCreado);
                  }
                  if (aDateTime == null) return 1; // Sin cita va al final
                  if (bDateTime == null) return -1; // Con cita va al principio

                  // Ambos tienen cita, ordenar por fecha más cercana
                  return aDateTime.compareTo(bDateTime);
                });

                if (docsFiltered.isEmpty) {
                  return Center(
                    child: Text(
                      _filtroEstado == 'activas'
                          ? 'No hay citas activas'
                          : _filtroEstado == 'inactivas'
                          ? 'No hay citas inactivas'
                          : 'No hay prospectos registrados',
                      style: AppTextStyles.contactText,
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: docsFiltered.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = docsFiltered[index];
                    final data = doc.data() as Map<String, dynamic>;

                    // Nombre y teléfono - usando toString() para evitar errores de tipo
                    final nombre = (data['nombre'] ?? '').toString();
                    final apellidos = (data['apellidos'] ?? '').toString();
                    final celular = (data['celular'] ?? '').toString();

                    // Fecha de la cita enlazada (si existe)
                    String citaTexto = 'Sin cita';
                    final rawCita = data['citaFecha'];
                    if (rawCita != null) {
                      DateTime dt;
                      if (rawCita is Timestamp) {
                        dt = rawCita.toDate();
                      } else if (rawCita is DateTime) {
                        // ignore: curly_braces_in_flow_control_structures
                        dt = rawCita;
                      } else if (rawCita is String) {
                        try {
                          dt = DateTime.parse(rawCita);
                        } catch (e) {
                          dt = DateTime.now();
                        }
                      } else {
                        dt = DateTime.now();
                      }
                      try {
                        // Formato mejorado: fecha completa + hora en 24h
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final citaDate = DateTime(dt.year, dt.month, dt.day);

                        if (citaDate == today) {
                          // Si es hoy, mostrar solo "Hoy" + hora
                          citaTexto = "Hoy ${DateFormat('HH:mm').format(dt)}";
                        } else {
                          // Si es otro día, mostrar fecha + hora
                          citaTexto =
                              "${DateFormat('dd/MM/yyyy').format(dt)} ${DateFormat('HH:mm').format(dt)}";
                        }
                      } catch (e) {
                        citaTexto = dt.toLocal().toString();
                      }
                    }

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header con icono y info principal
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.event_available,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$nombre $apellidos',
                                        style: AppTextStyles.mainText.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Prospecto',
                                        style: AppTextStyles.contactText
                                            .copyWith(
                                              color: AppColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _esCitaActiva(data)
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _esCitaActiva(data) ? 'ACTIVO' : 'INACTIVO',
                                    style: TextStyle(
                                      color: _esCitaActiva(data)
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16),

                            // Información de contacto
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: Colors.blue.shade600,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    celular,
                                    style: AppTextStyles.contactText.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 12),

                            // Información de la cita
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    color: Colors.orange.shade600,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      citaTexto,
                                      style: AppTextStyles.contactText.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16),

                            // Botones de acción
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // Mostrar todos los datos del prospecto en un diálogo
                                      showDialog(
                                        context: context,
                                        builder: (_) {
                                          // Helper local para formatear fechas (Timestamp/DateTime/String)
                                          String formatDate(dynamic raw) {
                                            if (raw == null) return '-';
                                            DateTime dt;
                                            if (raw is Timestamp) {
                                              dt = raw.toDate();
                                            } else if (raw is DateTime) {
                                              // ignore: curly_braces_in_flow_control_structures
                                              dt = raw;
                                            } else if (raw is String) {
                                              try {
                                                dt = DateTime.parse(raw);
                                              } catch (e) {
                                                return raw.toString();
                                              }
                                            } else {
                                              return raw.toString();
                                            }
                                            try {
                                              return DateFormat(
                                                "d 'de' MMMM 'de' y, h:mm a",
                                                'es',
                                              ).format(dt.toLocal());
                                            } catch (e) {
                                              return dt.toLocal().toString();
                                            }
                                          }

                                          final creadoEnRaw = data['creadoEn'];
                                          final creadoEn = formatDate(
                                            creadoEnRaw,
                                          );
                                          final citaFechaRaw =
                                              data['citaFecha'];
                                          final citaFecha = formatDate(
                                            citaFechaRaw,
                                          );

                                          return AlertDialog(
                                            title: Text('$nombre $apellidos'),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  _detailRow('Nombre', nombre),
                                                  _detailRow(
                                                    'Apellidos',
                                                    apellidos,
                                                  ),
                                                  _detailRow(
                                                    'Celular',
                                                    celular,
                                                  ),
                                                  _detailRow(
                                                    'Edad',
                                                    (data['edad']?.toString() ??
                                                        '-'),
                                                  ),
                                                  _detailRow(
                                                    'Género',
                                                    (data['genero'] ?? '-'),
                                                  ),
                                                  _detailRow(
                                                    'Objetivo',
                                                    (data['objetivo'] ?? '-'),
                                                  ),
                                                  _detailRow(
                                                    'Peso',
                                                    (data['peso']?.toString() ??
                                                        '-'),
                                                  ),
                                                  _detailRow(
                                                    'Talla',
                                                    (data['talla']
                                                            ?.toString() ??
                                                        '-'),
                                                  ),
                                                  _detailRow(
                                                    'Cita Fecha',
                                                    citaFecha,
                                                  ),
                                                  _detailRow(
                                                    'Creado En',
                                                    creadoEn,
                                                  ),
                                                  if (data['fechaAtencion'] !=
                                                      null)
                                                    _detailRow(
                                                      'Fecha Atención',
                                                      formatDate(
                                                        data['fechaAtencion'],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text('Cerrar'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      'Ver Detalles',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      _showEditDialog(context, doc.id, data);
                                    },
                                    icon: Icon(Icons.edit, color: Colors.white),
                                    label: Text(
                                      'Editar',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: data['completada'] == true
                                      ? ElevatedButton.icon(
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Confirmar'),
                                                  content: Text(
                                                    '¿Estás seguro de que deseas desmarcar esta cita como completada?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: Text('Cancelar'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.orange,
                                                          ),
                                                      child: Text(
                                                        'Sí, desmarcar',
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (confirm == true) {
                                              try {
                                                await FirebaseFirestore.instance
                                                    .collection('prospectos')
                                                    .doc(doc.id)
                                                    .update({
                                                      'completada': false,
                                                      'fechaAtencion': null,
                                                    });
                                                // ignore: use_build_context_synchronously
                                                _showSnackBar(
                                                  'Cita desmarcada',
                                                  Colors.orange,
                                                );
                                              } catch (e) {
                                                // ignore: use_build_context_synchronously
                                                _showSnackBar(
                                                  'Error al desmarcar cita: $e',
                                                  Colors.red,
                                                );
                                              }
                                            }
                                          },
                                          icon: Icon(
                                            Icons.cancel,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            ' Desmarcar',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        )
                                      : ElevatedButton.icon(
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Confirmar'),
                                                  content: Text(
                                                    '¿Estás seguro de que deseas marcar esta cita como completada?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: Text('Cancelar'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.green,
                                                          ),
                                                      child: Text('Sí, marcar'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (confirm == true) {
                                              try {
                                                await FirebaseFirestore.instance
                                                    .collection('prospectos')
                                                    .doc(doc.id)
                                                    .update({
                                                      'completada': true,
                                                      'fechaAtencion':
                                                          Timestamp.now(),
                                                    });
                                                // ignore: use_build_context_synchronously
                                                _showSnackBar(
                                                  'Cita marcada como completada',
                                                  Colors.green,
                                                );
                                              } catch (e) {
                                                // ignore: use_build_context_synchronously
                                                _showSnackBar(
                                                  'Error al completar cita: $e',
                                                  Colors.red,
                                                );
                                              }
                                            }
                                          },
                                          icon: Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            ' Marcar',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltroButton(String label, String value) {
    final isSelected = _filtroEstado == value;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _filtroEstado = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final nombreController = TextEditingController(text: data['nombre'] ?? '');
    final apellidosController = TextEditingController(
      text: data['apellidos'] ?? '',
    );
    final celularController = TextEditingController(
      text: data['celular'] ?? '',
    );
    final edadController = TextEditingController(
      text: data['edad']?.toString() ?? '',
    );
    final generoController = TextEditingController(text: data['genero'] ?? '');
    final objetivoController = TextEditingController(
      text: data['objetivo'] ?? '',
    );
    final pesoController = TextEditingController(
      text: data['peso']?.toString() ?? '',
    );
    final tallaController = TextEditingController(
      text: data['talla']?.toString() ?? '',
    );

    DateTime? citaFecha = data['citaFecha'] is Timestamp
        ? (data['citaFecha'] as Timestamp).toDate()
        : data['citaFecha'] is DateTime
        ? data['citaFecha']
        : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Editar Cita'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(labelText: 'Nombre'),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: apellidosController,
                      decoration: InputDecoration(labelText: 'Apellidos'),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: celularController,
                      decoration: InputDecoration(labelText: 'Celular'),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: edadController,
                      decoration: InputDecoration(labelText: 'Edad'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: generoController,
                      decoration: InputDecoration(labelText: 'Género'),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: objetivoController,
                      decoration: InputDecoration(labelText: 'Objetivo'),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: pesoController,
                      decoration: InputDecoration(labelText: 'Peso'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: tallaController,
                      decoration: InputDecoration(labelText: 'Talla'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: citaFecha ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          final time = await showTimePicker(
                            // ignore: use_build_context_synchronously
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              citaFecha ?? DateTime.now(),
                            ),
                          );
                          if (time != null) {
                            setState(() {
                              citaFecha = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                citaFecha != null
                                    ? DateFormat(
                                        "d 'de' MMMM 'de' y, h:mm a",
                                        'es',
                                      ).format(citaFecha!)
                                    : 'Seleccionar fecha',
                                style: TextStyle(
                                  color: citaFecha != null
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
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
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('prospectos')
                          .doc(docId)
                          .update({
                            'nombre': nombreController.text,
                            'apellidos': apellidosController.text,
                            'celular': celularController.text,
                            'edad': int.tryParse(edadController.text) ?? 0,
                            'genero': generoController.text,
                            'objetivo': objetivoController.text,
                            'peso': double.tryParse(pesoController.text) ?? 0,
                            'talla': double.tryParse(tallaController.text) ?? 0,
                            'citaFecha': citaFecha ?? Timestamp.now(),
                          });

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cita actualizada correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al actualizar: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
