import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';

class Entrenador {
  final int id;
  final String dni;
  final String nombre;
  final String apellido;
  final String celular;
  final String correo;
  final String contrasena;

  Entrenador({
    required this.id,
    required this.dni,
    required this.nombre,
    required this.apellido,
    required this.celular,
    required this.correo,
    required this.contrasena,
  });
}

class EntrenadoresScreen extends StatefulWidget {
  const EntrenadoresScreen({super.key});

  @override
  State<EntrenadoresScreen> createState() => _EntrenadoresScreenState();
}

class _EntrenadoresScreenState extends State<EntrenadoresScreen> {
  final List<Entrenador> _entrenadores = [
    Entrenador(
      id: 1,
      dni: '12345678',
      nombre: 'Carlos',
      apellido: 'Rodriguez',
      celular: '987654321',
      correo: 'carlos@gym.com',
      contrasena: '123456',
    ),
    Entrenador(
      id: 2,
      dni: '87654321',
      nombre: 'Maria',
      apellido: 'Lopez',
      celular: '912345678',
      correo: 'maria@gym.com',
      contrasena: 'abcdef',
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
          'ENTRENADORES',
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
            onPressed: _mostrarDialogoAgregarEntrenador,
          ),
        ],
      ),
      body: _entrenadores.isEmpty
          ? _buildListaVacia()
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _entrenadores.length,
              itemBuilder: (context, index) {
                return _buildEntrenadorCard(_entrenadores[index]);
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

  Widget _buildEntrenadorCard(Entrenador entrenador) {
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
          '${entrenador.nombre} ${entrenador.apellido}',
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
                'DNI: ${entrenador.dni}',
                style: AppTextStyles.contactText.copyWith(fontSize: 14),
              ),
              Text(
                'Celular: ${entrenador.celular}',
                style: AppTextStyles.contactText.copyWith(fontSize: 14),
              ),
              Text(
                'Email: ${entrenador.correo}',
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
                _mostrarDialogoVerEntrenador(entrenador);
                break;
              case 'editar':
                _mostrarDialogoEditarEntrenador(entrenador);
                break;
              case 'eliminar':
                _mostrarDialogoEliminarEntrenador(entrenador);
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

  void _mostrarDialogoAgregarEntrenador() {
    _mostrarDialogoEntrenador();
  }

  void _mostrarDialogoEditarEntrenador(Entrenador entrenador) {
    _mostrarDialogoEntrenador(entrenador: entrenador);
  }

  void _mostrarDialogoEntrenador({Entrenador? entrenador}) {
    final formKey = GlobalKey<FormState>();
    final dniController = TextEditingController(text: entrenador?.dni ?? '');
    final nombreController = TextEditingController(
      text: entrenador?.nombre ?? '',
    );
    final apellidoController = TextEditingController(
      text: entrenador?.apellido ?? '',
    );
    final celularController = TextEditingController(
      text: entrenador?.celular ?? '',
    );
    final correoController = TextEditingController(
      text: entrenador?.correo ?? '',
    );
    final contrasenaController = TextEditingController(
      text: entrenador?.contrasena ?? '',
    );
    bool mostrarContrasena = false;
    bool esEdicion = entrenador != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Row(
            children: [
              Icon(
                esEdicion ? Icons.edit : Icons.person_add,
                color: esEdicion ? Colors.orange : Colors.green,
              ),
              SizedBox(width: 8),
              Text(
                esEdicion ? 'Editar Entrenador' : 'Agregar Entrenador',
                style: AppTextStyles.mainText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: esEdicion ? Colors.orange : Colors.green,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // DNI
                  TextFormField(
                    controller: dniController,
                    decoration: InputDecoration(
                      labelText: 'DNI',
                      prefixIcon: Icon(
                        Icons.credit_card,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el DNI';
                      }
                      if (value.length < 8) {
                        return 'El DNI debe tener 8 dígitos';
                      }
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el nombre';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),

                  // Apellido
                  TextFormField(
                    controller: apellidoController,
                    decoration: InputDecoration(
                      labelText: 'Apellido',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el apellido';
                      }
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el celular';
                      }
                      if (value.length != 9) {
                        return 'El celular debe tener 9 dígitos';
                      }
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el correo';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Ingresa un correo válido';
                      }
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
                        icon: Icon(
                          mostrarContrasena
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          setStateDialog(() {
                            mostrarContrasena = !mostrarContrasena;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    obscureText: !mostrarContrasena,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                ],
              ),
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
                  if (esEdicion) {
                    setState(() {
                      int index = _entrenadores.indexWhere(
                        (e) => e.id == entrenador.id,
                      );
                      if (index != -1) {
                        _entrenadores[index] = Entrenador(
                          id: entrenador.id,
                          dni: dniController.text,
                          nombre: nombreController.text,
                          apellido: apellidoController.text,
                          celular: celularController.text,
                          correo: correoController.text,
                          contrasena: contrasenaController.text,
                        );
                      }
                    });
                    Navigator.pop(context);
                    _mostrarMensaje(
                      'Entrenador actualizado correctamente',
                      Colors.orange,
                    );
                  } else {
                    setState(() {
                      _entrenadores.add(
                        Entrenador(
                          id: DateTime.now().millisecondsSinceEpoch,
                          dni: dniController.text,
                          nombre: nombreController.text,
                          apellido: apellidoController.text,
                          celular: celularController.text,
                          correo: correoController.text,
                          contrasena: contrasenaController.text,
                        ),
                      );
                    });
                    Navigator.pop(context);
                    _mostrarMensaje(
                      'Entrenador agregado correctamente',
                      Colors.green,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: esEdicion ? Colors.orange : Colors.green,
              ),
              child: Text(
                esEdicion ? 'Actualizar' : 'Agregar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoVerEntrenador(Entrenador entrenador) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              _buildCampoDetalle(
                'Nombre Completo:',
                '${entrenador.nombre} ${entrenador.apellido}',
              ),
              _buildCampoDetalle('DNI:', entrenador.dni),
              _buildCampoDetalle('Celular:', entrenador.celular),
              _buildCampoDetalle('Correo:', entrenador.correo),
              _buildCampoDetalle(
                'Contraseña:',
                '•' * entrenador.contrasena.length,
              ),
            ],
          ),
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

  void _mostrarDialogoEliminarEntrenador(Entrenador entrenador) {
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
          '¿Estás seguro de que deseas eliminar al entrenador "${entrenador.nombre} ${entrenador.apellido}"? Esta acción no se puede deshacer.',
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
                _entrenadores.removeWhere((e) => e.id == entrenador.id);
              });
              Navigator.pop(context);
              _mostrarMensaje('Entrenador eliminado correctamente', Colors.red);
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
