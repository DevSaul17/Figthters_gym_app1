import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';

class RegistroClienteScreen extends StatefulWidget {
  const RegistroClienteScreen({super.key});

  @override
  State<RegistroClienteScreen> createState() => _RegistroClienteScreenState();
}

class _RegistroClienteScreenState extends State<RegistroClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _celularController = TextEditingController();
  final _emailController = TextEditingController();
  final _edadController = TextEditingController();
  final _pesoController = TextEditingController();
  final _tallaController = TextEditingController();
  final _condicionFisicaController = TextEditingController();

  String _genero = 'Masculino';
  String _planSeleccionado = 'Básico';
  String _objetivo = 'Pérdida de peso';

  final List<String> _planes = ['Básico', 'Intermedio', 'Premium', 'VIP'];

  final List<String> _objetivos = [
    'Pérdida de peso',
    'Ganancia muscular',
    'Tonificación',
    'Resistencia',
    'Fuerza',
    'Rehabilitación',
  ];

  @override
  void dispose() {
    _dniController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _fechaNacimientoController.dispose();
    _celularController.dispose();
    _emailController.dispose();
    _edadController.dispose();
    _pesoController.dispose();
    _tallaController.dispose();
    _condicionFisicaController.dispose();
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
        title: Text(
          'REGISTRO CLIENTE',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de sección
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  // ignore: deprecated_member_use
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: AppColors.primary, size: 30),
                    SizedBox(width: 12),
                    Text(
                      'Datos Personales',
                      style: AppTextStyles.mainText.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // DNI
              _buildTextField(
                controller: _dniController,
                label: 'DNI',
                hint: 'Ej: 12345678',
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el DNI';
                  }
                  if (!RegExp(r'^[0-9]{6,10}$').hasMatch(value)) {
                    return 'El DNI debe tener entre 6 y 10 dígitos';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),

              SizedBox(height: 16),

              // Nombre
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre',
                hint: 'Ingresa el nombre',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  if (value.length < 2) {
                    return 'El nombre debe tener al menos 2 caracteres';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Apellidos
              _buildTextField(
                controller: _apellidosController,
                label: 'Apellidos',
                hint: 'Ingresa los apellidos',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa los apellidos';
                  }
                  if (value.length < 2) {
                    return 'Los apellidos deben tener al menos 2 caracteres';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Fecha de Nacimiento
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha de Nacimiento',
                    style: AppTextStyles.mainText.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _fechaNacimientoController,
                    readOnly: true,
                    onTap: _seleccionarFechaNacimiento,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor selecciona la fecha de nacimiento';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Selecciona la fecha de nacimiento',
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                      ),
                      suffixIcon: Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.primary,
                      ),
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red, width: 1),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Celular
              _buildTextField(
                controller: _celularController,
                label: 'Celular',
                hint: 'Ej: 3001234567',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el número de celular';
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'El celular debe tener 10 dígitos';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),

              SizedBox(height: 16),

              // Email
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'ejemplo@correo.com',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Ingresa un email válido';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // Información física
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  // ignore: deprecated_member_use
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.fitness_center, color: Colors.blue, size: 30),
                    SizedBox(width: 12),
                    Text(
                      'Información Física',
                      style: AppTextStyles.mainText.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Género
              Text(
                'Género',
                style: AppTextStyles.mainText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Masculino'),
                      value: 'Masculino',
                      // ignore: deprecated_member_use
                      groupValue: _genero,
                      // ignore: deprecated_member_use
                      onChanged: (value) {
                        setState(() {
                          _genero = value!;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Femenino'),
                      value: 'Femenino',
                      // ignore: deprecated_member_use
                      groupValue: _genero,
                      // ignore: deprecated_member_use
                      onChanged: (value) {
                        setState(() {
                          _genero = value!;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Edad, Peso y Talla en una fila
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _edadController,
                      label: 'Edad',
                      hint: '25',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa la edad';
                        }
                        int? edad = int.tryParse(value);
                        if (edad == null || edad < 16 || edad > 80) {
                          return 'Edad entre 16-80 años';
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _pesoController,
                      label: 'Peso (kg)',
                      hint: '70.5',
                      icon: Icons.monitor_weight,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa el peso';
                        }
                        double? peso = double.tryParse(value);
                        if (peso == null || peso < 40 || peso > 200) {
                          return 'Peso entre 40-200 kg';
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _tallaController,
                      label: 'Talla (m)',
                      hint: '1.75',
                      icon: Icons.height,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa la talla';
                        }
                        double? talla = double.tryParse(value);
                        if (talla == null || talla < 1.40 || talla > 2.10) {
                          return 'Talla entre 1.40-2.10 m';
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Condición Física
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Condición Física',
                    style: AppTextStyles.mainText.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _condicionFisicaController,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText:
                          'Describe brevemente la condición física actual del cliente...',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Icon(
                          Icons.fitness_center,
                          color: AppColors.primary,
                        ),
                      ),
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red, width: 1),
                      ),
                      counterText: '', // Ocultar contador de caracteres
                    ),
                    validator: (value) {
                      if (value != null && value.length > 200) {
                        return 'Máximo 200 caracteres';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Plan y objetivo
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  // ignore: deprecated_member_use
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.fitness_center, color: Colors.green, size: 30),
                    SizedBox(width: 12),
                    Text(
                      'Plan y Objetivos',
                      style: AppTextStyles.mainText.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Plan
              Text(
                'Plan de Membresía',
                style: AppTextStyles.mainText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _planSeleccionado,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.card_membership,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                items: _planes.map((plan) {
                  return DropdownMenuItem<String>(
                    value: plan,
                    child: Text(plan),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _planSeleccionado = value!;
                  });
                },
              ),

              SizedBox(height: 16),

              // Objetivo
              Text(
                'Objetivo Principal',
                style: AppTextStyles.mainText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _objetivo,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.flag, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                items: _objetivos.map((objetivo) {
                  return DropdownMenuItem<String>(
                    value: objetivo,
                    child: Text(objetivo),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _objetivo = value!;
                  });
                },
              ),

              SizedBox(height: 30),

              // Botón Registrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registrarCliente,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Registrar Cliente',
                    style: AppTextStyles.buttonText.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.mainText.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  void _registrarCliente() {
    if (_formKey.currentState!.validate()) {
      // Calcular IMC
      double peso = double.parse(_pesoController.text);
      double talla = double.parse(_tallaController.text);
      double imc = peso / (talla * talla);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(Icons.check_circle, color: Colors.green, size: 50),
          title: Text(
            'Cliente Registrado',
            style: AppTextStyles.mainText.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_nombreController.text} ${_apellidosController.text}',
                style: AppTextStyles.mainText.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'DNI: ${_dniController.text}',
                style: AppTextStyles.contactText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Fecha Nac: ${_fechaNacimientoController.text}',
                style: AppTextStyles.contactText,
              ),
              Text(
                'Plan: $_planSeleccionado',
                style: AppTextStyles.contactText,
              ),
              Text(
                'IMC: ${imc.toStringAsFixed(1)}',
                style: AppTextStyles.contactText,
              ),
              Text('Objetivo: $_objetivo', style: AppTextStyles.contactText),
              if (_condicionFisicaController.text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Condición: ${_condicionFisicaController.text}',
                    style: AppTextStyles.contactText.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar dialog
                Navigator.pop(context); // Volver al home gym
              },
              child: Text('Continuar'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _seleccionarFechaNacimiento() async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        Duration(days: 365 * 25),
      ), // 25 años atrás por defecto
      firstDate: DateTime.now().subtract(
        Duration(days: 365 * 80),
      ), // 80 años atrás máximo
      lastDate: DateTime.now().subtract(
        Duration(days: 365 * 16),
      ), // 16 años atrás mínimo
      helpText: 'Seleccionar fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaNacimientoController.text =
            '${fechaSeleccionada.day.toString().padLeft(2, '0')}/${fechaSeleccionada.month.toString().padLeft(2, '0')}/${fechaSeleccionada.year}';

        // Calcular edad automáticamente
        int edad = DateTime.now().year - fechaSeleccionada.year;
        if (DateTime.now().month < fechaSeleccionada.month ||
            (DateTime.now().month == fechaSeleccionada.month &&
                DateTime.now().day < fechaSeleccionada.day)) {
          edad--;
        }
        _edadController.text = edad.toString();
      });
    }
  }
}
