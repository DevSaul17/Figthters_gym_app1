import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';
import '../../models/models.dart';

class EntrenamientosPersonalizadosScreen extends StatefulWidget {
  final String nombreUsuario;

  const EntrenamientosPersonalizadosScreen({
    super.key,
    required this.nombreUsuario,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EntrenamientosPersonalizadosScreenState createState() =>
      _EntrenamientosPersonalizadosScreenState();
}

class _EntrenamientosPersonalizadosScreenState
    extends State<EntrenamientosPersonalizadosScreen> {
  final TextEditingController _ejercicioController = TextEditingController();

  // Variables para rutina semanal
  final List<String> _diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
  ];
  final Map<String, List<String>> _rutinaSemanal = {
    'Lunes': [],
    'Martes': [],
    'Miércoles': [],
    'Jueves': [],
    'Viernes': [],
    'Sábado': [],
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _ejercicioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ENTRENAMIENTOS',
          style: AppTextStyles.appBarTitle.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      body: _buildCrearRutina(),
    );
  }

  Widget _buildCrearRutina() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          // Mensaje de bienvenida con gradiente
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  // ignore: deprecated_member_use
                  AppColors.primary.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    size: 45,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '¡Hola ${widget.nombreUsuario}!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Organiza tu rutina de entrenamientos',
                  style: TextStyle(
                    fontSize: 14,
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          // Botón para rellenar rutina con efecto mejorado
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _mostrarDialogoRutinaSemanal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                // ignore: deprecated_member_use
                shadowColor: AppColors.primary.withOpacity(0.4),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_calendar, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Rellenar Rutina Semanal',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
          // Título de rutina guardada
          Row(
            children: [
              Container(
                width: 5,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Mi Rutina Semanal',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          // Mostrar días con ejercicios guardados desde Firebase
          _buildRutinaGuardada(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // Eliminada la función _buildMisEntrenamientos()

  Future<String?> _obtenerClienteId() async {
    try {
      final db = FirebaseFirestore.instance;
      final snapshot = await db
          .collection('credenciales')
          .where('usuario', isEqualTo: widget.nombreUsuario)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.get('clienteId');
      }
    } catch (e) {
      print('Error obteniendo clienteId: $e');
    }
    return null;
  }

  Widget _buildRutinaGuardada() {
    return FutureBuilder<String?>(
      future: _obtenerClienteId(),
      builder: (context, clienteSnapshot) {
        if (clienteSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!clienteSnapshot.hasData) {
          return SizedBox.shrink();
        }

        final clienteId = clienteSnapshot.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('entrenamientos')
              .where('clienteId', isEqualTo: clienteId)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  'Sin rutina guardada aún',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final data =
                snapshot.data!.docs.first.data() as Map<String, dynamic>;
            final rutina = data['rutinaSemanal'] as Map<String, dynamic>? ?? {};

            return Column(
              children: _diasSemana.map((dia) {
                final ejerciciosDelDia = rutina[dia] as List<dynamic>? ?? [];

                if (ejerciciosDelDia.isEmpty) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            dia,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Vacío',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  margin: EdgeInsets.only(bottom: 14),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        // ignore: deprecated_member_use
                        AppColors.primary.withOpacity(0.08),
                        // ignore: deprecated_member_use
                        AppColors.primary.withOpacity(0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: AppColors.primary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              dia,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${ejerciciosDelDia.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      ...ejerciciosDelDia.map((ejercicio) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                // ignore: deprecated_member_use
                                color: AppColors.primary.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    ejercicio,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Future<void> _mostrarDialogoRutinaSemanal() async {
    // Cargar la rutina existente antes de mostrar el diálogo
    await _cargarRutinaExistente();

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rellenar Rutina Semanal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _diasSemana.map((dia) {
                return _buildDiaRutinaItem(dia);
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _guardarRutinaEnFirestore();
              if (mounted) {
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaRutinaItem(String dia) {
    final ejerciciosDelDia = _rutinaSemanal[dia] ?? [];
    final controllerEjercicio = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  dia,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${ejerciciosDelDia.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        // Lista de ejercicios para el día
        if (ejerciciosDelDia.isNotEmpty)
          Column(
            children: ejerciciosDelDia.asMap().entries.map((entry) {
              final index = entry.key;
              final ejercicio = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '• $ejercicio',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _rutinaSemanal[dia]!.removeAt(index);
                          });
                        },
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        SizedBox(height: 10),
        // Campo para agregar ejercicio
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controllerEjercicio,
                decoration: InputDecoration(
                  hintText: 'Agregar ejercicio',
                  hintStyle: TextStyle(fontSize: 12),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      if (controllerEjercicio.text.isNotEmpty) {
                        setState(() {
                          _rutinaSemanal[dia]!.add(
                            controllerEjercicio.text.trim(),
                          );
                          controllerEjercicio.clear();
                        });
                      }
                    },
                    child: Icon(Icons.add, color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }

  Future<void> _cargarRutinaExistente() async {
    try {
      final clienteId = await _obtenerClienteId();
      if (clienteId == null) return;

      final db = FirebaseFirestore.instance;
      final snapshot = await db
          .collection('entrenamientos')
          .where('clienteId', isEqualTo: clienteId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final rutina = data['rutinaSemanal'] as Map<String, dynamic>? ?? {};

        setState(() {
          for (var dia in _diasSemana) {
            _rutinaSemanal[dia] = List<String>.from(rutina[dia] ?? []);
          }
        });
      } else {
        // Si no hay rutina, limpiar el estado local
        setState(() {
          for (var dia in _diasSemana) {
            _rutinaSemanal[dia] = [];
          }
        });
      }
    } catch (e) {
      print('Error cargando rutina existente: $e');
    }
  }

  Future<void> _guardarRutinaEnFirestore() async {
    try {
      final db = FirebaseFirestore.instance;

      // Obtener clienteId desde credenciales
      final credencialesSnapshot = await db
          .collection('credenciales')
          .where('usuario', isEqualTo: widget.nombreUsuario)
          .get();

      if (credencialesSnapshot.docs.isNotEmpty) {
        final clienteId = credencialesSnapshot.docs.first.get('clienteId');

        // Obtener datos del cliente
        final clienteSnapshot = await db
            .collection('clientes')
            .doc(clienteId)
            .get();

        if (clienteSnapshot.exists) {
          final nombreCliente = clienteSnapshot.get('nombre') ?? '';
          final apellidosCliente = clienteSnapshot.get('apellidos') ?? '';

          // Verificar si ya existe un documento para este cliente
          final entrenamientoSnapshot = await db
              .collection('entrenamientos')
              .where('clienteId', isEqualTo: clienteId)
              .limit(1)
              .get();

          // Crear modelo Entrenamiento
          final entrenamiento = Entrenamiento(
            id: entrenamientoSnapshot.docs.isNotEmpty
                ? entrenamientoSnapshot.docs.first.id
                : '',
            clienteId: clienteId,
            nombreRutina: 'Rutina de $nombreCliente',
            rutinasPorDia: _rutinaSemanal,
            fechaCreacion: entrenamientoSnapshot.docs.isNotEmpty
                ? (entrenamientoSnapshot.docs.first.get('fechaCreacion')
                          as Timestamp)
                      .toDate()
                : DateTime.now(),
            fechaActualizacion: DateTime.now(),
          );

          // Convertir a JSON y agregar campos adicionales por compatibilidad
          final datosEntrenamiento = entrenamiento.toJson();
          datosEntrenamiento['nombreCliente'] =
              '$nombreCliente $apellidosCliente'.trim();
          datosEntrenamiento['rutinaSemanal'] = _rutinaSemanal;
          datosEntrenamiento['activo'] = true;

          if (entrenamientoSnapshot.docs.isNotEmpty) {
            // Actualizar documento existente
            await db
                .collection('entrenamientos')
                .doc(entrenamiento.id)
                .update(datosEntrenamiento);
          } else {
            // Crear nuevo documento
            await db.collection('entrenamientos').add(datosEntrenamiento);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Rutina guardada correctamente'),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error guardando rutina: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la rutina'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
