import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';
import 'mensaje_screen.dart';

class DatosCitaScreen extends StatefulWidget {
  final Map<String, dynamic> horarioSeleccionado;

  const DatosCitaScreen({super.key, required this.horarioSeleccionado});

  @override
  State<DatosCitaScreen> createState() => _DatosCitaScreenState();
}

class _DatosCitaScreenState extends State<DatosCitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _celularController = TextEditingController();
  final _edadController = TextEditingController();
  final _pesoController = TextEditingController();
  final _tallaController = TextEditingController();

  String _generoSeleccionado = '';
  String _objetivoSeleccionado = '';

  final List<String> objetivos = [
    'Movilidad, coordinación y fuerza.',
    'Desarrollo Muscular.',
    'Pérdida de grasa corporal.',
    'Recuperación de habilidades funcionales.',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _celularController.dispose();
    _edadController.dispose();
    _pesoController.dispose();
    _tallaController.dispose();
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
          'DATOS CITA',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/datos.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.1),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),

                  // Campo Nombre
                  _buildTextField(
                    controller: _nombreController,
                    label: 'NOMBRE',
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]*$'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'No vacío';
                      }
                      if (value.length < 2) {
                        return 'Longitud mínima (ej. 2 caracteres)';
                      }
                      if (!RegExp(
                        r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$',
                      ).hasMatch(value)) {
                        return 'Solo letras y espacios';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Campo Apellidos
                  _buildTextField(
                    controller: _apellidosController,
                    label: 'APELLIDOS',
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]*$'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'No vacío';
                      }
                      if (value.length < 2) {
                        return 'Longitud mínima (ej. 2 caracteres)';
                      }
                      if (!RegExp(
                        r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$',
                      ).hasMatch(value)) {
                        return 'Solo letras y espacios';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16),

                  // Fila: Campo Celular y Edad
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _celularController,
                          label: 'CELULAR',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'No vacío';
                            }
                            if (value.length != 9) {
                              return 'Exactamente 9 dígitos';
                            }
                            if (!value.startsWith('9')) {
                              return 'Debe comenzar con "9"';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return 'Solo números';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _edadController,
                          label: 'EDAD',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'No vacío';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return 'Solo números';
                            }
                            int? edad = int.tryParse(value);
                            if (edad == null || edad < 1 || edad > 120) {
                              return 'Rango válido (ej. 1 a 120)';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Fila: Campo Peso y Talla
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _pesoController,
                          label: 'PESO / KG',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^[0-9]+\.?[0-9]*$'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'No vacío';
                            }
                            if (!RegExp(r'^[0-9]+\.?[0-9]*$').hasMatch(value)) {
                              return 'Solo números (puede incluir decimales)';
                            }
                            double? peso = double.tryParse(value);
                            if (peso == null || peso < 1 || peso > 300) {
                              return 'Rango válido (ej. 1 a 300)';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _tallaController,
                          label: 'TALLA (m o cm)',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^[0-9]+\.?[0-9]*$'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'No vacío';
                            }
                            if (!RegExp(r'^[0-9]+\.?[0-9]*$').hasMatch(value)) {
                              return 'Solo números (puede incluir decimales)';
                            }
                            double? talla = double.tryParse(value);
                            if (talla == null) {
                              return 'Número válido';
                            }
                            // Validar rango: 0.5 a 2.5 m o 50 a 250 cm
                            if ((talla >= 0.5 && talla <= 2.5) ||
                                (talla >= 50 && talla <= 250)) {
                              return null;
                            } else {
                              return 'Rango válido (ej. 0.5 a 2.5 m o 50 a 250 cm)';
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Género
                  Text(
                    'GÉNERO',
                    style: AppTextStyles.mainText.copyWith(fontSize: 16),
                  ),

                  SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: _buildGenderOption('Masculino')),
                      SizedBox(width: 20),
                      Expanded(child: _buildGenderOption('Femenino')),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Objetivos/Necesidad
                  Text(
                    'OBJETIVOS / NECESIDAD',
                    style: AppTextStyles.mainText.copyWith(fontSize: 16),
                  ),

                  SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _objetivoSeleccionado.isEmpty
                            ? null
                            : _objetivoSeleccionado,
                        hint: Text(
                          '----Seleccionar----',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        isExpanded: true,
                        items: objetivos.map((String objetivo) {
                          return DropdownMenuItem<String>(
                            value: objetivo,
                            child: Text(objetivo),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _objetivoSeleccionado = value ?? '';
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Cita Seleccionada
                  Text(
                    'CITA SELECCIONADA',
                    style: AppTextStyles.mainText.copyWith(fontSize: 16),
                  ),

                  SizedBox(height: 8),

                  Text(
                    '${widget.horarioSeleccionado['dia']} ${widget.horarioSeleccionado['fecha']} ${widget.horarioSeleccionado['hora']}',
                    style: AppTextStyles.contactText.copyWith(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),

                  SizedBox(height: 40),

                  // Botón Solicitar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _confirmarCita();
                      },
                      style: AppButtonStyles.primaryButton.copyWith(
                        backgroundColor: WidgetStateProperty.all(Colors.black),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        padding: WidgetStateProperty.all(
                          EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      child: Text(
                        'Solicitar',
                        style: AppTextStyles.buttonText.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ], // Cierre del Column children
              ), // Cierre del Column
            ), // Cierre del Form
          ), // Cierre del SingleChildScrollView
        ), // Cierre del Container con transparencia
      ), // Cierre del Container con imagen de fondo
    ); // Cierre del Scaffold
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization? textCapitalization,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.contactText.copyWith(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          style: AppTextStyles.contactText.copyWith(fontSize: 16),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String genero) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _generoSeleccionado = genero;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _generoSeleccionado == genero
                      ? AppColors.primary
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: _generoSeleccionado == genero
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12),
            Text(
              genero,
              style: AppTextStyles.contactText.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarCita() {
    // Validar el formulario antes de confirmar la cita
    if (!_formKey.currentState!.validate()) {
      return; // Si hay errores de validación, no proceder
    }

    // Validar que el género esté seleccionado
    if (_generoSeleccionado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecciona un género'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar que el objetivo esté seleccionado
    if (_objetivoSeleccionado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecciona un objetivo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Si todas las validaciones pasan, navegar a la pantalla de mensaje
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MensajeScreen(
          datosCita: {
            'nombre': _nombreController.text,
            'apellidos': _apellidosController.text,
            'celular': _celularController.text,
            'edad': _edadController.text,
            'peso': _pesoController.text,
            'talla': _tallaController.text,
            'genero': _generoSeleccionado,
            'objetivo': _objetivoSeleccionado,
          },
          horarioSeleccionado: widget.horarioSeleccionado,
        ),
      ),
    );
  }
}
