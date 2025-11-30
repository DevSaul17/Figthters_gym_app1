import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';

class PerfilScreen extends StatefulWidget {
  final String nombreUsuario;
  const PerfilScreen({super.key, required this.nombreUsuario});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Map<String, dynamic>? _clienteData;
  bool _isLoading = true;
  bool _isEditing = false;

  late TextEditingController _nombreController;
  late TextEditingController _apellidosController;
  late TextEditingController _celularController;
  late TextEditingController _emailController;
  late TextEditingController _pesoController;
  late TextEditingController _tallaController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _apellidosController = TextEditingController();
    _celularController = TextEditingController();
    _emailController = TextEditingController();
    _pesoController = TextEditingController();
    _tallaController = TextEditingController();
    _cargarDatos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _celularController.dispose();
    _emailController.dispose();
    _pesoController.dispose();
    _tallaController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    try {
      final credencialesSnapshot = await _db
          .collection('credenciales')
          .where('usuario', isEqualTo: widget.nombreUsuario)
          .get();

      if (credencialesSnapshot.docs.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
          _mostrarError('Cliente no encontrado');
        }
        return;
      }

      final clienteId = credencialesSnapshot.docs.first.get('clienteId');
      final clienteDoc = await _db.collection('clientes').doc(clienteId).get();

      if (mounted) {
        setState(() {
          _clienteData = clienteDoc.data();
          _isLoading = false;
          _nombreController.text = _clienteData?['nombre'] ?? '';
          _apellidosController.text = _clienteData?['apellidos'] ?? '';
          _celularController.text = _clienteData?['celular'] ?? '';
          _emailController.text = _clienteData?['email'] ?? '';
          _pesoController.text = _clienteData?['peso']?.toString() ?? '';
          _tallaController.text = _clienteData?['talla']?.toString() ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarError('Error al cargar datos: $e');
      }
    }
  }

  Future<void> _guardarCambios() async {
    try {
      final credencialesSnapshot = await _db
          .collection('credenciales')
          .where('usuario', isEqualTo: widget.nombreUsuario)
          .get();

      final clienteId = credencialesSnapshot.docs.first.get('clienteId');

      await _db.collection('clientes').doc(clienteId).update({
        'nombre': _nombreController.text,
        'apellidos': _apellidosController.text,
        'celular': _celularController.text,
        'email': _emailController.text,
        'peso': double.tryParse(_pesoController.text),
        'talla': double.tryParse(_tallaController.text),
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      });

      setState(() {
        _clienteData = {
          ..._clienteData ?? {},
          'nombre': _nombreController.text,
          'apellidos': _apellidosController.text,
          'celular': _celularController.text,
          'email': _emailController.text,
          'peso': double.tryParse(_pesoController.text),
          'talla': double.tryParse(_tallaController.text),
        };
        _isEditing = false;
      });

      _mostrarMensaje('Cambios guardados exitosamente', Colors.green);
    } catch (e) {
      _mostrarError('Error al guardar cambios: $e');
    }
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

  void _mostrarError(String mensaje) {
    _mostrarMensaje(mensaje, Colors.red);
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
          'Mi Perfil',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _nombreController.text = _clienteData?['nombre'] ?? '';
                  _apellidosController.text = _clienteData?['apellidos'] ?? '';
                  _celularController.text = _clienteData?['celular'] ?? '';
                  _emailController.text = _clienteData?['email'] ?? '';
                  _pesoController.text =
                      _clienteData?['peso']?.toString() ?? '';
                  _tallaController.text =
                      _clienteData?['talla']?.toString() ?? '';
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _buildDatosPersonalesCard(),
                  SizedBox(height: 24),
                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _guardarCambios,
                        icon: Icon(Icons.check),
                        label: Text('Guardar Cambios'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildDatosPersonalesCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 28, color: AppColors.primary),
              SizedBox(width: 12),
              Text(
                'Datos Personales',
                style: AppTextStyles.mainText.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildTextField(
            controller: _nombreController,
            label: 'Nombre',
            hintText: 'Tu nombre',
            enabled: _isEditing,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _apellidosController,
            label: 'Apellidos',
            hintText: 'Tus apellidos',
            enabled: _isEditing,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hintText: 'tu@email.com',
            keyboardType: TextInputType.emailAddress,
            enabled: _isEditing,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _celularController,
            label: 'Celular',
            hintText: 'Tu número de celular',
            keyboardType: TextInputType.phone,
            enabled: _isEditing,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _pesoController,
            label: 'Peso (kg)',
            hintText: 'Tu peso en kilogramos',
            keyboardType: TextInputType.number,
            enabled: _isEditing,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _tallaController,
            label: 'Talla (cm)',
            hintText: 'Tu talla en centímetros',
            keyboardType: TextInputType.number,
            enabled: _isEditing,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: TextEditingController(text: _clienteData?['dni'] ?? ''),
            label: 'DNI',
            hintText: 'Tu DNI',
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.contactText.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: AppTextStyles.contactText.copyWith(fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
