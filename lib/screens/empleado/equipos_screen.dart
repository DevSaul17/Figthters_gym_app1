import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EquiposScreen extends StatefulWidget {
  const EquiposScreen({super.key});

  @override
  State<EquiposScreen> createState() => _EquiposScreenState();
}

class _EquiposScreenState extends State<EquiposScreen>
    with TickerProviderStateMixin {
  final FirestoreService _firestore = FirestoreService();
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _tipoSeleccionado = 'Cardio'; // Tipo por defecto
  bool _activo = true;
  String? _equipoEditandoId;
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  final List<String> _tipos = [
    'Cardio',
    'Pesas',
    'Máquinas',
    'Accesorios',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _descripcionController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Sección de formulario
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: _buildFormulario(),
          ),
          SizedBox(height: 12),
          // TabBar para filtrar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: 'Activos'),
                Tab(text: 'Inactivos'),
              ],
            ),
          ),
          // Sección de listado
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListadoEquipos(activo: true),
                _buildListadoEquipos(activo: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _equipoEditandoId == null ? 'Agregar Equipo' : 'Editar Equipo',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16),
          // Campo Nombre
          TextFormField(
            controller: _nombreController,
            decoration: InputDecoration(
              labelText: 'Nombre del equipo',
              hintText: 'Ej. Cinta de correr',
              prefixIcon: Icon(Icons.fitness_center, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el nombre del equipo';
              }
              return null;
            },
          ),
          SizedBox(height: 12),
          // Fila: Tipo y Cantidad
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _tipoSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Tipo',
                    prefixIcon: Icon(Icons.category, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  items: _tipos
                      .map(
                        (tipo) =>
                            DropdownMenuItem(value: tipo, child: Text(tipo)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _tipoSeleccionado = value ?? 'Cardio';
                    });
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cantidadController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    prefixIcon: Icon(Icons.numbers, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Cantidad requerida';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Número válido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Switch Activo/Inactivo
          Row(
            children: [
              Icon(Icons.toggle_on, color: AppColors.primary),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  _activo ? 'Equipo Activo' : 'Equipo Inactivo',
                  style: AppTextStyles.contactText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Switch(
                value: _activo,
                onChanged: (value) {
                  setState(() {
                    _activo = value;
                  });
                },
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          SizedBox(height: 12),
          // Campo Descripción (solo si está inactivo)
          if (!_activo)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Motivo de inactividad',
                    hintText: 'Ej. En reparación, dañado, etc.',
                    prefixIcon: Icon(Icons.note, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (!_activo && (value == null || value.isEmpty)) {
                      return 'Debes indicar el motivo de inactividad';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
              ],
            ),
          SizedBox(height: 4),
          // Botones
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _guardarEquipo,
                  icon: Icon(
                    _equipoEditandoId == null ? Icons.add_circle : Icons.save,
                  ),
                  label: Text(
                    _equipoEditandoId == null ? 'Agregar' : 'Actualizar',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (_equipoEditandoId != null) ...[
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _cancelarEdicion,
                    icon: Icon(Icons.cancel),
                    label: Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[500],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListadoEquipos({required bool activo}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.streamCollection(
          'equipos',
          queryBuilder: (q) => q.where('activo', isEqualTo: activo),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 12),
                  Text('Error al cargar equipos: ${snapshot.error}'),
                ],
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          // Ordenar en cliente por nombre
          docs.sort((a, b) {
            final nameA = (a.data() as Map<String, dynamic>)['nombre'] ?? '';
            final nameB = (b.data() as Map<String, dynamic>)['nombre'] ?? '';
            return nameA.toString().compareTo(nameB.toString());
          });

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 48, color: Colors.grey[300]),
                  SizedBox(height: 12),
                  Text(
                    activo
                        ? 'No hay equipos activos'
                        : 'No hay equipos inactivos',
                    style: AppTextStyles.contactText,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final id = doc.id;

              final nombre = data['nombre'] ?? '-';
              final tipo = data['tipo'] ?? '-';
              final cantidad = data['cantidad'] ?? 0;
              final activo = data['activo'] ?? true;
              final descripcion = data['descripcion'] ?? '-';

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activo ? Colors.green[200]! : Colors.red[200]!,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: nombre y estado
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nombre,
                                  style: AppTextStyles.mainText.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tipo,
                                    style: AppTextStyles.contactText.copyWith(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: activo ? Colors.green[50] : Colors.red[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              activo ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: activo
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Cantidad
                      Row(
                        children: [
                          Icon(
                            Icons.inventory,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Cantidad: $cantidad',
                            style: AppTextStyles.contactText,
                          ),
                        ],
                      ),
                      // Descripción (solo si está inactivo)
                      if (!activo) ...[
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Motivo de inactividad:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                descripcion,
                                style: AppTextStyles.contactText.copyWith(
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 12),
                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _editarEquipo(id, data),
                              icon: Icon(Icons.edit, size: 16),
                              label: Text('Editar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _eliminarEquipo(id, nombre),
                              icon: Icon(Icons.delete, size: 16),
                              label: Text('Eliminar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red),
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
    );
  }

  void _guardarEquipo() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreController.text.trim();
    final cantidad = int.tryParse(_cantidadController.text) ?? 0;
    final descripcion = _descripcionController.text.trim();

    final data = {
      'nombre': nombre,
      'tipo': _tipoSeleccionado,
      'cantidad': cantidad,
      'activo': _activo,
      'descripcion': _activo ? '' : descripcion,
      'creadoEn': FieldValue.serverTimestamp(),
    };

    try {
      if (_equipoEditandoId == null) {
        // Crear nuevo
        await _firestore.addDocument('equipos', data);
        _mostrarSnackBar('Equipo agregado correctamente', Colors.green);
      } else {
        // Actualizar existente
        data.remove('creadoEn'); // No actualizar creación
        await _firestore.updateDocument('equipos', _equipoEditandoId!, data);
        _mostrarSnackBar('Equipo actualizado correctamente', Colors.green);
      }
      _limpiarFormulario();
    } catch (e) {
      _mostrarSnackBar('Error al guardar equipo: $e', Colors.red);
    }
  }

  void _editarEquipo(String id, Map<String, dynamic> data) {
    setState(() {
      _equipoEditandoId = id;
      _nombreController.text = data['nombre'] ?? '';
      _tipoSeleccionado = data['tipo'] ?? 'Cardio';
      _cantidadController.text = (data['cantidad'] ?? 0).toString();
      _activo = data['activo'] ?? true;
      _descripcionController.text = data['descripcion'] ?? '';
    });

    // Desplazar hacia arriba para ver el formulario
    _scrollToTop();
  }

  void _cancelarEdicion() {
    setState(() {
      _equipoEditandoId = null;
    });
    _limpiarFormulario();
  }

  void _eliminarEquipo(String id, String nombre) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Eliminar Equipo'),
        content: Text('¿Eliminar "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.deleteDocument('equipos', id);
                _mostrarSnackBar('Equipo eliminado', Colors.green);
              } catch (e) {
                _mostrarSnackBar('Error al eliminar: $e', Colors.red);
              }
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _cantidadController.clear();
    _descripcionController.clear();
    _tipoSeleccionado = 'Cardio';
    _activo = true;
    _equipoEditandoId = null;
  }

  void _scrollToTop() {
    // En caso de tener un ScrollController, hacer scroll hacia arriba
    // Por ahora es visual (el formulario está arriba)
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
