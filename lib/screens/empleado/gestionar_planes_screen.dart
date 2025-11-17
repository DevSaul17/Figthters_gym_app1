import 'package:flutter/material.dart';
import '../../constants.dart';

class PlanMembresia {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final List<String> beneficios;

  PlanMembresia({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.precio = 0.0,
    this.beneficios = const [],
  });
}

class GestionarPlanesScreen extends StatefulWidget {
  const GestionarPlanesScreen({super.key});

  @override
  State<GestionarPlanesScreen> createState() => _GestionarPlanesScreenState();
}

class _GestionarPlanesScreenState extends State<GestionarPlanesScreen> {
  final List<PlanMembresia> _planes = [
    PlanMembresia(
      id: 1,
      nombre: 'Fitness Musculacion',
      descripcion:
          'Plan enfocado en desarrollo muscular y acondicionamiento físico general',
      precio: 120.0,
     
    ),
    PlanMembresia(
      id: 2,
      nombre: 'Hibrido',
      descripcion: 'Combinación de entrenamiento funcional, pesas y cardio',
      precio: 180.0,
     
    ),
    PlanMembresia(
      id: 3,
      nombre: 'Artes Marciales',
      descripcion:
          'Plan especializado en disciplinas de combate y defensa personal',
      precio: 200.0,

    ),
  ];

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
            icon: Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: _mostrarDialogoAgregarPlan,
          ),
        ],
      ),
      body: _planes.isEmpty
          ? _buildListaVacia()
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _planes.length,
              itemBuilder: (context, index) {
                return _buildPlanCard(_planes[index]);
              },
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  prefixIcon: Icon(Icons.description, color: AppColors.primary),
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
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  _planes.add(
                    PlanMembresia(
                      id: DateTime.now().millisecondsSinceEpoch,
                      nombre: nombreController.text,
                      descripcion: descripcionController.text,
                    ),
                  );
                });
                Navigator.pop(context);
                _mostrarMensaje('Plan agregado correctamente', Colors.green);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
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
            Text(
              'Nombre:',
              style: AppTextStyles.mainText.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              plan.nombre,
              style: AppTextStyles.contactText.copyWith(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Descripción:',
              style: AppTextStyles.mainText.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              plan.descripcion,
              style: AppTextStyles.contactText.copyWith(fontSize: 14),
            ),
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

  void _mostrarDialogoEditarPlan(PlanMembresia plan) {
    final nombreController = TextEditingController(text: plan.nombre);
    final descripcionController = TextEditingController(text: plan.descripcion);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  prefixIcon: Icon(Icons.description, color: AppColors.primary),
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
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  int index = _planes.indexWhere((p) => p.id == plan.id);
                  if (index != -1) {
                    _planes[index] = PlanMembresia(
                      id: plan.id,
                      nombre: nombreController.text,
                      descripcion: descripcionController.text,
                    );
                  }
                });
                Navigator.pop(context);
                _mostrarMensaje(
                  'Plan actualizado correctamente',
                  Colors.orange,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Actualizar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminarPlan(PlanMembresia plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
        content: Text(
          '¿Estás seguro de que deseas eliminar el plan "${plan.nombre}"? Esta acción no se puede deshacer.',
          style: AppTextStyles.contactText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _planes.removeWhere((p) => p.id == plan.id);
              });
              Navigator.pop(context);
              _mostrarMensaje('Plan eliminado correctamente', Colors.red);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
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
