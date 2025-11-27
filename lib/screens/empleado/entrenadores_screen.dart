import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';
import '../../services/firestore_service.dart';

class EntrenadoresScreen extends StatefulWidget {
  const EntrenadoresScreen({super.key});

  @override
  State<EntrenadoresScreen> createState() => _EntrenadoresScreenState();
}

class _EntrenadoresScreenState extends State<EntrenadoresScreen> {
  final FirestoreService _firestore = FirestoreService();

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
          'ENTRENADORES',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () => _mostrarDialogoAgregarEntrenador(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.streamCollection(
          'entrenadores',
          queryBuilder: (q) => q.orderBy('nombre'),
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
                  Text('Error al cargar entrenadores: ${snapshot.error}'),
                ],
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return _buildListaVacia();
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildEntrenadorCard(doc.id, data);
            },
          );
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
            Icons.fitness_center,
            size: 80,
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No hay entrenadores registrados',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Presiona + para agregar el primer entrenador',
            style: AppTextStyles.contactText.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildEntrenadorCard(String id, Map<String, dynamic> data) {
    final nombre = (data['nombre'] ?? '-').toString();
    final apellido = (data['apellido'] ?? '-').toString();
    final dni = (data['dni'] ?? '-').toString();
    final celular = (data['celular'] ?? '-').toString();
    final correo = (data['correo'] ?? '-').toString();
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
          child: Icon(Icons.fitness_center, color: AppColors.primary, size: 24),
        ),
        title: Text(
          '$nombre $apellido',
          style: AppTextStyles.mainText.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DNI: $dni',
                style: AppTextStyles.contactText.copyWith(fontSize: 14),
              ),
              Text(
                'Celular: $celular',
                style: AppTextStyles.contactText.copyWith(fontSize: 14),
              ),
              Text(
                'Email: $correo',
                style: AppTextStyles.contactText.copyWith(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.primary),
          onSelected: (value) {
            switch (value) {
              case 'ver':
                _mostrarDialogoVerEntrenador(data);
                break;
              case 'editar':
                _mostrarDialogoEditarEntrenador(id, data);
                break;
              case 'eliminar':
                _mostrarDialogoEliminarEntrenador(id, nombre, apellido);
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

  void _mostrarDialogoAgregarEntrenador() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddEditEntrenadorDialog(
        firestore: _firestore,
        esEdicion: false,
      ),
    );

    if (result == true) {
      _mostrarMensaje('Entrenador agregado correctamente', Colors.green);
    }
  }

  void _mostrarDialogoEditarEntrenador(String id, Map<String, dynamic> data) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddEditEntrenadorDialog(
        firestore: _firestore,
        esEdicion: true,
        id: id,
        data: data,
      ),
    );

    if (result == true) {
      _mostrarMensaje('Entrenador actualizado correctamente', Colors.orange);
    }
  }

  void _mostrarDialogoVerEntrenador(Map<String, dynamic> data) {
    final nombre = (data['nombre'] ?? '-').toString();
    final apellido = (data['apellido'] ?? '-').toString();
    final dni = (data['dni'] ?? '-').toString();
    final celular = (data['celular'] ?? '-').toString();
    final correo = (data['correo'] ?? '-').toString();
    final contrasena = (data['contrasena'] ?? '').toString();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.visibility, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'Detalles del Entrenador',
              style: AppTextStyles.mainText.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCampoDetalle('Nombre Completo:', '$nombre $apellido'),
              _buildCampoDetalle('DNI:', dni),
              _buildCampoDetalle('Celular:', celular),
              _buildCampoDetalle('Correo:', correo),
              _buildCampoDetalle('Contraseña:', '•' * contrasena.length),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoDetalle(String label, String valor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.mainText.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(valor, style: AppTextStyles.contactText.copyWith(fontSize: 14)),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminarEntrenador(
    String id,
    String nombre,
    String apellido,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
          '¿Estás seguro de que deseas eliminar al entrenador "$nombre $apellido"? Esta acción no se puede deshacer.',
          style: AppTextStyles.contactText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.deleteDocument('entrenadores', id);
                // cerrar y mostrar mensaje desde la pantalla padre
                // ignore: use_build_context_synchronously
                Navigator.of(dialogContext).pop();
                _mostrarMensaje(
                  'Entrenador eliminado correctamente',
                  Colors.red,
                );
              } catch (e) {
                // ignore: use_build_context_synchronously
                Navigator.of(dialogContext).pop();
                _mostrarMensaje('Error: $e', Colors.red);
              }
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

/// Dialogo separado y stateful para evitar problemas con context/ANR y manejar loading
class AddEditEntrenadorDialog extends StatefulWidget {
  final FirestoreService firestore;
  final bool esEdicion;
  final String? id;
  final Map<String, dynamic>? data;

  const AddEditEntrenadorDialog({
    super.key,
    required this.firestore,
    required this.esEdicion,
    this.id,
    this.data,
  });

  @override
  State<AddEditEntrenadorDialog> createState() => _AddEditEntrenadorDialogState();
}

class _AddEditEntrenadorDialogState extends State<AddEditEntrenadorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController dniController;
  late final TextEditingController nombreController;
  late final TextEditingController apellidoController;
  late final TextEditingController celularController;
  late final TextEditingController correoController;
  late final TextEditingController contrasenaController;

  bool mostrarContrasena = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    dniController = TextEditingController(text: (widget.data?['dni'] ?? '').toString());
    nombreController = TextEditingController(text: (widget.data?['nombre'] ?? '').toString());
    apellidoController = TextEditingController(text: (widget.data?['apellido'] ?? '').toString());
    celularController = TextEditingController(text: (widget.data?['celular'] ?? '').toString());
    correoController = TextEditingController(text: (widget.data?['correo'] ?? '').toString());
    contrasenaController = TextEditingController(text: (widget.data?['contrasena'] ?? '').toString());
  }

  @override
  void dispose() {
    dniController.dispose();
    nombreController.dispose();
    apellidoController.dispose();
    celularController.dispose();
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _onCancel() async {
    if (!mounted) return;
    Navigator.of(context).pop(false);
  }

  Future<void> _onSave() async {
 
final Map<String, dynamic> entrenadorData = {
  'dni': dniController.text.trim(),
  'nombre': nombreController.text.trim(),
  'apellido': apellidoController.text.trim(),
  'celular': celularController.text.trim(),
  'correo': correoController.text.trim(),
  'contrasena': contrasenaController.text,
};

// Solo agregar creadoEn si es nuevo registro
if (!widget.esEdicion) {
  // No hagas cast a String. FieldValue.serverTimestamp() se guarda como Timestamp en Firestore.
  entrenadorData['creadoEn'] = FieldValue.serverTimestamp();
}

    try {
      if (widget.esEdicion && widget.id != null) {
        await widget.firestore.updateDocument('entrenadores', widget.id!, entrenadorData);
      } else {
        await widget.firestore.addDocument('entrenadores', entrenadorData);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      // Cerrar dialogo y mostrar mensaje desde la pantalla padre
      Navigator.of(context).pop(false);
      // Pasamos el error al padre mostrando un SnackBar tras cerrar el diálogo
      final parentContext = ScaffoldMessenger.maybeOf(context);
      // En caso de no poder mostrar aquí, el padre puede mostrar su propio mensaje.
      parentContext?.showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.esEdicion ? Icons.edit : Icons.person_add,
            color: widget.esEdicion ? Colors.orange : Colors.green,
          ),
          SizedBox(width: 8),
          Text(
            widget.esEdicion ? 'Editar Entrenador' : 'Agregar Entrenador',
            style: AppTextStyles.mainText.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.esEdicion ? Colors.orange : Colors.green,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // DNI
              TextFormField(
                controller: dniController,
                decoration: InputDecoration(
                  labelText: 'DNI',
                  prefixIcon: Icon(Icons.credit_card, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingresa el DNI';
                  if (value.length < 8) return 'El DNI debe tener 8 dígitos';
                  return null;
                },
              ),
              SizedBox(height: 12),

              // Nombre
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingresa el nombre';
                  return null;
                },
              ),
              SizedBox(height: 12),

              // Apellido
              TextFormField(
                controller: apellidoController,
                decoration: InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingresa el apellido';
                  return null;
                },
              ),
              SizedBox(height: 12),

              // Celular
              TextFormField(
                controller: celularController,
                decoration: InputDecoration(
                  labelText: 'Celular',
                  prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingresa el celular';
                  if (value.length != 9) return 'El celular debe tener 9 dígitos';
                  return null;
                },
              ),
              SizedBox(height: 12),

              // Correo
              TextFormField(
                controller: correoController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icon(Icons.email, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingresa el correo';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Ingresa un correo válido';
                  return null;
                },
              ),
              SizedBox(height: 12),

              // Contraseña
              TextFormField(
                controller: contrasenaController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(mostrarContrasena ? Icons.visibility : Icons.visibility_off, color: AppColors.primary),
                    onPressed: () => setState(() => mostrarContrasena = !mostrarContrasena),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                obscureText: !mostrarContrasena,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingresa la contraseña';
                  if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _onCancel,
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.esEdicion ? Colors.orange : Colors.green,
          ),
          child: _isLoading
              ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(widget.esEdicion ? 'Actualizar' : 'Agregar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}