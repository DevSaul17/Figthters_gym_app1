import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';

class PlanMembresia {
  final String? id;
  final String nombre;
  final String descripcion;
  final DateTime? creadoEn;
  final DateTime? actualizadoEn;
  final bool activo;

  PlanMembresia({
    this.id,
    required this.nombre,
    required this.descripcion,
    this.creadoEn,
    this.actualizadoEn,
    this.activo = true,
  });

  // Convertir desde Firestore
  factory PlanMembresia.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlanMembresia(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      creadoEn: (data['creado_en'] as Timestamp?)?.toDate(),
      actualizadoEn: (data['actualizado_en'] as Timestamp?)?.toDate(),
      activo: data['activo'] ?? true,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
      'actualizado_en': FieldValue.serverTimestamp(),
    };
  }

  // Para crear nuevo plan
  Map<String, dynamic> toFirestoreCreate() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
      'creado_en': FieldValue.serverTimestamp(),
      'actualizado_en': FieldValue.serverTimestamp(),
    };
  }
}

class GestionarPlanesScreen extends StatefulWidget {
  const GestionarPlanesScreen({super.key});

  @override
  State<GestionarPlanesScreen> createState() => _GestionarPlanesScreenState();
}

class _GestionarPlanesScreenState extends State<GestionarPlanesScreen> {
  List<PlanMembresia> _planes = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _cargarPlanes();
  }

  Future<void> _cargarPlanes() async {
    try {
      setState(() {
        _isLoading = true;
      });


      // Primero intentamos obtener todos los documentos de la colección planes
      final querySnapshot = await FirebaseFirestore.instance
          .collection('planes')
          .get();


      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          print('📄 Datos: ${doc.data()}');
        }
      }

      // Filtrar solo los planes activos
      final planes = querySnapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['activo'] == true || data['activo'] == null;
          })
          .map((doc) => PlanMembresia.fromFirestore(doc))
          .toList();

      print('✅ Planes activos cargados: ${planes.length}');

      if (mounted) {
        setState(() {
          _planes = planes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error al cargar planes: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _mostrarMensaje('Error al cargar planes: $e', Colors.red);
      }
    }
  }

  Future<void> _refrescarPlanes() async {
    setState(() {
      _isRefreshing = true;
    });
    await _cargarPlanes();
    setState(() {
      _isRefreshing = false;
    });
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
        title: Text(
          'GESTIONAR PLANES',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 24),
            onPressed: _isRefreshing ? null : _refrescarPlanes,
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: _mostrarDialogoAgregarPlan,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Cargando planes...', style: AppTextStyles.contactText),
                ],
              ),
            )
          : _planes.isEmpty
          ? _buildListaVacia()
          : RefreshIndicator(
              onRefresh: _refrescarPlanes,
              color: AppColors.primary,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _planes.length,
                itemBuilder: (context, index) {
                  return _buildPlanCard(_planes[index]);
                },
              ),
            ),
    );
  }

  Widget _buildListaVacia() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_membership,
            size: 80,
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No hay planes registrados',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Presiona + para agregar el primer plan',
            style: AppTextStyles.contactText.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(PlanMembresia plan) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.card_membership,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          plan.nombre,
          style: AppTextStyles.mainText.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            plan.descripcion,
            style: AppTextStyles.contactText.copyWith(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.primary),
          onSelected: (value) {
            switch (value) {
              case 'ver':
                _mostrarDialogoVerPlan(plan);
                break;
              case 'editar':
                _mostrarDialogoEditarPlan(plan);
                break;
              case 'eliminar':
                _mostrarDialogoEliminarPlan(plan);
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'ver',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Ver Detalles'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'editar',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'eliminar',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoAgregarPlan() {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.add_box, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Agregar Plan',
                style: AppTextStyles.mainText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Plan',
                    prefixIcon: Icon(
                      Icons.card_membership,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el nombre del plan';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(
                      Icons.description,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una descripción';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          final nuevoPlan = PlanMembresia(
                            nombre: nombreController.text.trim(),
                            descripcion: descripcionController.text.trim(),
                          );

                          print(
                            '💾 Intentando guardar plan: ${nuevoPlan.nombre}',
                          );
                          print(
                            '💾 Datos a guardar: ${nuevoPlan.toFirestoreCreate()}',
                          );

                          // Usar FirebaseFirestore directamente para mejor debugging
                          final docRef = await FirebaseFirestore.instance
                              .collection('planes')
                              .add(nuevoPlan.toFirestoreCreate());

                          print('✅ Plan guardado con ID: ${docRef.id}');

                          if (context.mounted) {
                            Navigator.pop(context);
                            _mostrarMensaje(
                              'Plan "${nuevoPlan.nombre}" agregado correctamente',
                              Colors.green,
                            );
                          }
                          await _cargarPlanes();
                        } catch (e) {
                          print('❌ Error al agregar plan: $e');
                          if (context.mounted) {
                            _mostrarMensaje(
                              'Error al agregar plan: $e',
                              Colors.red,
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('Agregar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoVerPlan(PlanMembresia plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.visibility, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'Detalles del Plan',
              style: AppTextStyles.mainText.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nombre:', plan.nombre),
            SizedBox(height: 12),
            _buildDetailRow('Descripción:', plan.descripcion),
            if (plan.creadoEn != null) ...[
              SizedBox(height: 12),
              _buildDetailRow(
                'Creado:',
                '${plan.creadoEn!.day}/${plan.creadoEn!.month}/${plan.creadoEn!.year}',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.mainText.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 4),
        Text(value, style: AppTextStyles.contactText.copyWith(fontSize: 15)),
      ],
    );
  }

  void _mostrarDialogoEditarPlan(PlanMembresia plan) {
    final nombreController = TextEditingController(text: plan.nombre);
    final descripcionController = TextEditingController(text: plan.descripcion);
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Editar Plan',
                style: AppTextStyles.mainText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Plan',
                    prefixIcon: Icon(
                      Icons.card_membership,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el nombre del plan';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(
                      Icons.description,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una descripción';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          final planActualizado = PlanMembresia(
                            id: plan.id,
                            nombre: nombreController.text.trim(),
                            descripcion: descripcionController.text.trim(),
                            creadoEn: plan.creadoEn,
                            activo: plan.activo,
                          );

                          print('🔄 Actualizando plan ID: ${plan.id}');
                          print(
                            '🔄 Nuevos datos: ${planActualizado.toFirestore()}',
                          );

                          await FirebaseFirestore.instance
                              .collection('planes')
                              .doc(plan.id!)
                              .update(planActualizado.toFirestore());

                          print('✅ Plan actualizado exitosamente');

                          if (context.mounted) {
                            Navigator.pop(context);
                            _mostrarMensaje(
                              'Plan "${planActualizado.nombre}" actualizado correctamente',
                              Colors.orange,
                            );
                          }
                          await _cargarPlanes();
                        } catch (e) {
                          print('❌ Error al actualizar plan: $e');
                          if (context.mounted) {
                            _mostrarMensaje(
                              'Error al actualizar plan: $e',
                              Colors.red,
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('Actualizar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoEliminarPlan(PlanMembresia plan) {
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text(
                '¡Atención!',
                style: AppTextStyles.mainText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Estás seguro de que deseas eliminar el plan "${plan.nombre}"?',
                style: AppTextStyles.contactText.copyWith(fontSize: 16),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  // ignore: deprecated_member_use
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'El plan se desactivará y no estará disponible para nuevas suscripciones.',
                        style: AppTextStyles.contactText.copyWith(
                          fontSize: 13,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        print('🗑️ Eliminando plan ID: ${plan.id}');

                        await FirebaseFirestore.instance
                            .collection('planes')
                            .doc(plan.id!)
                            .update({
                              'activo': false,
                              'eliminado_en': FieldValue.serverTimestamp(),
                            });

                        print('✅ Plan marcado como inactivo');

                        if (context.mounted) {
                          Navigator.pop(context);
                          _mostrarMensaje(
                            'Plan "${plan.nombre}" eliminado correctamente',
                            Colors.red,
                          );
                        }
                        await _cargarPlanes();
                      } catch (e) {
                        print('❌ Error al eliminar plan: $e');
                        if (context.mounted) {
                          _mostrarMensaje(
                            'Error al eliminar plan: $e',
                            Colors.red,
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
