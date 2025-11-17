import 'package:flutter/material.dart';
import '../../constants.dart';
import 'gestionar_planes_screen.dart';
import 'pagos_screen.dart';

class RegistroMembresiaScreen extends StatefulWidget {
  final Map<String, String> datosCliente;

  const RegistroMembresiaScreen({super.key, required this.datosCliente});

  @override
  State<RegistroMembresiaScreen> createState() =>
      _RegistroMembresiaScreenState();
}

class _RegistroMembresiaScreenState extends State<RegistroMembresiaScreen> {
  final _formKey = GlobalKey<FormState>();

  String _planSeleccionado = '';
  int _frecuencia = 3; // 3 o 5 días
  int _tiempo = 1; // meses
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now().add(Duration(days: 30));
  TimeOfDay _hora = TimeOfDay(hour: 6, minute: 0);
  List<String> _diasSeleccionados = [];
  final DateTime _fechaCreacion = DateTime.now();

  final List<PlanMembresia> _planesDisponibles = [
    PlanMembresia(
      id: 1,
      nombre: 'Fitness Musculacion',
      descripcion:
          'Plan enfocado en desarrollo muscular y acondicionamiento físico general',
      precio: 120.0,
      beneficios: [
        'Acceso completo al área de pesas',
        'Uso de máquinas cardiovasculares',
        'Rutinas personalizadas',
        'Horario: 6:00 AM - 10:00 PM',
        'Ducha y vestuarios',
      ],
    ),
    PlanMembresia(
      id: 2,
      nombre: 'Hibrido',
      descripcion: 'Combinación de entrenamiento funcional, pesas y cardio',
      precio: 180.0,
      beneficios: [
        'Acceso completo al gimnasio',
        'Clases funcionales incluidas',
        'Entrenamiento personalizado',
        'Horario: 24/7',
        'Ducha y vestuarios premium',
      ],
    ),
    PlanMembresia(
      id: 3,
      nombre: 'Artes Marciales',
      descripcion:
          'Plan especializado en disciplinas de combate y defensa personal',
      precio: 200.0,
      beneficios: [
        'Clases de Muay Thai, Boxing y MMA',
        'Entrenadores especializados',
        'Equipo de protección incluido',
        'Preparación para competencias',
        'Horario flexible de clases',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (_planesDisponibles.isNotEmpty) {
      _planSeleccionado = _planesDisponibles.first.nombre;
    }
    _actualizarDiasDisponibles();
    _calcularFechaFin();
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
          'REGISTRO MEMBRESÍA',
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
              // Información del cliente
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Información del Cliente',
                          style: AppTextStyles.mainText.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '${widget.datosCliente['nombre']} ${widget.datosCliente['apellidos']}',
                      style: AppTextStyles.mainText.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'DNI: ${widget.datosCliente['dni']}',
                      style: AppTextStyles.contactText,
                    ),
                    Text(
                      'Edad: ${widget.datosCliente['edad']} años',
                      style: AppTextStyles.contactText,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

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
                      'Plan de Membresía',
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
                initialValue: _planSeleccionado.isEmpty
                    ? null
                    : _planSeleccionado,
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
                items: _planesDisponibles.map((plan) {
                  return DropdownMenuItem<String>(
                    value: plan.nombre,
                    child: Text(plan.nombre),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _planSeleccionado = value!;
                  });
                },
              ),

              SizedBox(height: 30),

              // Configuración de Horarios y Frecuencia
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  // ignore: deprecated_member_use
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.purple, size: 30),
                    SizedBox(width: 12),
                    Text(
                      'Configuración de Membresía',
                      style: AppTextStyles.mainText.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Frecuencia y Tiempo - Row
              Row(
                children: [
                  // Frecuencia
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Frecuencia',
                          style: AppTextStyles.mainText.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: _frecuencia,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.fitness_center,
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
                          ),
                          items: [
                            DropdownMenuItem(value: 3, child: Text('3 días')),
                            DropdownMenuItem(value: 5, child: Text('5 días')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _frecuencia = value!;
                              _actualizarDiasDisponibles();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  // Tiempo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tiempo',
                          style: AppTextStyles.mainText.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: _tiempo,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.calendar_month,
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
                          ),
                          items: [
                            DropdownMenuItem(value: 1, child: Text('1 mes')),
                            DropdownMenuItem(value: 2, child: Text('2 meses')),
                            DropdownMenuItem(value: 3, child: Text('3 meses')),
                            DropdownMenuItem(value: 6, child: Text('6 meses')),
                            DropdownMenuItem(
                              value: 12,
                              child: Text('12 meses'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _tiempo = value!;
                              _calcularFechaFin();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Fechas - Row
              Row(
                children: [
                  // Fecha de Inicio
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha de Inicio',
                          style: AppTextStyles.mainText.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.calendar_today,
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
                          ),
                          controller: TextEditingController(
                            text:
                                '${_fechaInicio.day.toString().padLeft(2, '0')}/${_fechaInicio.month.toString().padLeft(2, '0')}/${_fechaInicio.year}',
                          ),
                          onTap: () async {
                            final fecha = await showDatePicker(
                              context: context,
                              initialDate: _fechaInicio,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(Duration(days: 365)),
                            );
                            if (fecha != null) {
                              setState(() {
                                _fechaInicio = fecha;
                                _calcularFechaFin();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  // Fecha de Fin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha de Fin',
                          style: AppTextStyles.mainText.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.event, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fillColor: Colors.grey[100],
                            filled: true,
                          ),
                          controller: TextEditingController(
                            text:
                                '${_fechaFin.day.toString().padLeft(2, '0')}/${_fechaFin.month.toString().padLeft(2, '0')}/${_fechaFin.year}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Hora
              Text(
                'Hora de Entrenamiento',
                style: AppTextStyles.mainText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.access_time, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                controller: TextEditingController(text: _hora.format(context)),
                onTap: () async {
                  final hora = await showTimePicker(
                    context: context,
                    initialTime: _hora,
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(alwaysUse24HourFormat: false),
                        child: child!,
                      );
                    },
                  );
                  if (hora != null) {
                    // Validar horario permitido (6 AM a 10 PM)
                    if ((hora.hour >= 6 && hora.hour < 22) ||
                        (hora.hour == 22 && hora.minute == 0)) {
                      setState(() {
                        _hora = hora;
                      });
                    } else {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'El horario debe estar entre 6:00 AM y 10:00 PM',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),

              SizedBox(height: 16),

              // Días de Entrenamiento
              Text(
                'Días de Entrenamiento',
                style: AppTextStyles.mainText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildDaysSelection(),
              ),

              SizedBox(height: 16),

              // Fecha de Creación
              Text(
                'Fecha de Creación de Membresía',
                style: AppTextStyles.mainText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.today, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fillColor: Colors.green[50],
                  filled: true,
                ),
                controller: TextEditingController(
                  text:
                      '${_fechaCreacion.day.toString().padLeft(2, '0')}/${_fechaCreacion.month.toString().padLeft(2, '0')}/${_fechaCreacion.year}',
                ),
              ),

              SizedBox(height: 30),

              // Botón Registrar Cliente
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navegarAPagos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Realizar Pago',
                        style: AppTextStyles.buttonText.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

  void _calcularFechaFin() {
    _fechaFin = DateTime(
      _fechaInicio.year,
      _fechaInicio.month + _tiempo,
      _fechaInicio.day,
    );
  }

  void _actualizarDiasDisponibles() {
    setState(() {
      _diasSeleccionados.clear();
      if (_frecuencia == 5) {
        // 5 días: Lunes a Viernes automático
        _diasSeleccionados = [
          'Lunes',
          'Martes',
          'Miércoles',
          'Jueves',
          'Viernes',
        ];
      }
      // Para 3 días se deja vacío para que el usuario seleccione
    });
  }

  Widget _buildDaysSelection() {
    if (_frecuencia == 5) {
      // Mostrar días fijos para 5 días (Lunes a Viernes)
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'].map((
          dia,
        ) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dia,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      );
    } else {
      // Para 3 días: permitir seleccionar de Lunes a Sábado
      final diasDisponibles = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona 3 días:',
            style: AppTextStyles.contactText.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: diasDisponibles.map((dia) {
              final isSelected = _diasSeleccionados.contains(dia);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _diasSeleccionados.remove(dia);
                    } else if (_diasSeleccionados.length < 3) {
                      _diasSeleccionados.add(dia);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Solo puedes seleccionar 3 días'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[400]!,
                    ),
                  ),
                  child: Text(
                    dia,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    }
  }

  void _navegarAPagos() {
    if (_formKey.currentState!.validate()) {
      // Validar que se hayan seleccionado días para frecuencia de 3 días
      if (_frecuencia == 3 && _diasSeleccionados.length != 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debes seleccionar exactamente 3 días para entrenar'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Navegar a la pantalla de pagos
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PagosScreen(
            datosCliente: widget.datosCliente,
            planSeleccionado: _planSeleccionado,
            frecuencia: _frecuencia,
            tiempo: _tiempo,
            fechaInicio: _fechaInicio,
            fechaFin: _fechaFin,
            hora: _hora,
            diasSeleccionados: _diasSeleccionados,
            fechaCreacion: _fechaCreacion,
          ),
        ),
      );
    }
  }
}
