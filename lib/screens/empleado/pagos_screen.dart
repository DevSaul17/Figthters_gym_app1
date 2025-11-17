import 'package:flutter/material.dart';
import '../../constants.dart';

class PagosScreen extends StatefulWidget {
  final Map<String, String> datosCliente;
  final String planSeleccionado;
  final int frecuencia;
  final int tiempo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final TimeOfDay hora;
  final List<String> diasSeleccionados;
  final DateTime fechaCreacion;

  const PagosScreen({
    super.key,
    required this.datosCliente,
    required this.planSeleccionado,
    required this.frecuencia,
    required this.tiempo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.hora,
    required this.diasSeleccionados,
    required this.fechaCreacion,
  });

  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  final _formKey = GlobalKey<FormState>();

  // Campos de pago
  final _montoController = TextEditingController();

  String _metodoPago = 'Efectivo';

  final List<String> _metodosPago = [
    'Efectivo',
    'Tarjeta de Débito',
    'Tarjeta de Crédito',
    'Yape',
    'Plin',
    'Transferencia Bancaria',
  ];

  @override
  void initState() {
    super.initState();
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
          'REGISTRO DE PAGO',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen de Membresía
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
                              Icon(
                                Icons.receipt_long,
                                color: Colors.blue,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Resumen de Membresía',
                                style: AppTextStyles.mainText.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          _buildResumenField(
                            'Cliente:',
                            '${widget.datosCliente['nombre']} ${widget.datosCliente['apellidos']}',
                          ),
                          _buildResumenField('Plan:', widget.planSeleccionado),
                          _buildResumenField(
                            'Duración:',
                            '${widget.tiempo} mes${widget.tiempo > 1 ? 'es' : ''}',
                          ),
                          _buildResumenField(
                            'Frecuencia:',
                            '${widget.frecuencia} días/semana',
                          ),
                          _buildResumenField(
                            'Días:',
                            widget.diasSeleccionados.join(', '),
                          ),
                          _buildResumenField(
                            'Horario:',
                            widget.hora.format(context),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Información de Pago
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        // ignore: deprecated_member_use
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.payment, color: Colors.orange, size: 30),
                          SizedBox(width: 12),
                          Text(
                            'Información de Pago',
                            style: AppTextStyles.mainText.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Método de Pago
                    Text(
                      'Método de Pago',
                      style: AppTextStyles.mainText.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _metodoPago,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.payment,
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
                      items: _metodosPago.map((metodo) {
                        return DropdownMenuItem<String>(
                          value: metodo,
                          child: Text(metodo),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _metodoPago = value!;
                        });
                      },
                    ),

                    SizedBox(height: 16),

                    // Monto a Pagar
                    Text(
                      'Monto a Pagar',
                      style: AppTextStyles.mainText.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _montoController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.monetization_on,
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
                        prefixText: 'S/ ',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el monto';
                        }
                        final monto = double.tryParse(value);
                        if (monto == null || monto <= 0) {
                          return 'Ingresa un monto válido';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // Botón fijo en la parte inferior
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _procesarPago,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Procesar Pago',
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
          ),
        ],
      ),
    );
  }

  Widget _buildResumenField(String label, String valor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.contactText.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: AppTextStyles.contactText.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _procesarPago() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(Icons.check_circle, color: Colors.green, size: 50),
          title: Text(
            'Pago Procesado Exitosamente',
            style: AppTextStyles.mainText.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'El pago de S/ ${_montoController.text} ha sido procesado correctamente.',
                textAlign: TextAlign.center,
                style: AppTextStyles.contactText,
              ),
              SizedBox(height: 8),
              Text(
                'Membresía activada para ${widget.datosCliente['nombre']} ${widget.datosCliente['apellidos']}',
                textAlign: TextAlign.center,
                style: AppTextStyles.contactText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar dialog
                Navigator.pop(context); // Volver a registro membresía
                Navigator.pop(context); // Volver a registro cliente
                Navigator.pop(context); // Volver al home gym
              },
              child: Text('Finalizar'),
            ),
          ],
        ),
      );
    }
  }
}
