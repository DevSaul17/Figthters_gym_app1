import 'package:flutter/material.dart';
import '../../../constants.dart';

class CalculadoraIMCWidget extends StatefulWidget {
  const CalculadoraIMCWidget({super.key});

  @override
  State<CalculadoraIMCWidget> createState() => _CalculadoraIMCWidgetState();
}

class _CalculadoraIMCWidgetState extends State<CalculadoraIMCWidget> {
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  double _imcCalculado = 0.0;
  String _categoriaIMC = '';
  Color _colorIMC = Colors.grey;
  bool _mostrarResultado = false;
  String _generoSeleccionado = 'Masculino';
  String _unidadAltura = 'metros'; // metros o centímetros

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  void _calcularIMC() {
    if (_pesoController.text.isEmpty || _alturaController.text.isEmpty) {
      _mostrarError('Por favor, complete todos los campos');
      return;
    }

    try {
      double peso = double.parse(_pesoController.text);
      double altura = double.parse(_alturaController.text);

      // Convertir altura a metros si está en centímetros
      if (_unidadAltura == 'centímetros' || altura > 3) {
        altura = altura / 100;
      }

      if (peso <= 0 || altura <= 0) {
        _mostrarError('Los valores deben ser positivos');
        return;
      }

      if (altura < 0.5 || altura > 2.5) {
        _mostrarError('La altura debe estar entre 0.5 y 2.5 metros');
        return;
      }

      setState(() {
        _imcCalculado = peso / (altura * altura);
        _categoriaIMC = _obtenerCategoriaIMC(_imcCalculado);
        _colorIMC = _obtenerColorIMC(_imcCalculado);
        _mostrarResultado = true;
      });
    } catch (e) {
      _mostrarError('Error en los valores ingresados');
    }
  }

  String _obtenerCategoriaIMC(double imc) {
    if (imc < 18.5) {
      return 'Bajo peso';
    } else if (imc < 25.0) {
      return 'Peso normal';
    } else if (imc < 30.0) {
      return 'Sobrepeso';
    } else {
      return 'Obesidad';
    }
  }

  Color _obtenerColorIMC(double imc) {
    if (imc < 18.5) {
      return Colors.blue;
    } else if (imc < 25.0) {
      return Colors.green;
    } else if (imc < 30.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  void _limpiarCampos() {
    setState(() {
      _pesoController.clear();
      _alturaController.clear();
      _imcCalculado = 0.0;
      _categoriaIMC = '';
      _colorIMC = Colors.grey;
      _mostrarResultado = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            // Título
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // ignore: deprecated_member_use
                    colors: [Colors.purple, Colors.purple.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'CALCULADORA IMC',
                  style: AppTextStyles.appBarTitle.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // Información sobre IMC
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                // ignore: deprecated_member_use
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Índice de Masa Corporal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'El IMC es una medida que relaciona tu peso y altura para determinar si tienes un peso saludable.',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Género
            Text(
              'Género:',
              style: AppTextStyles.mainText.copyWith(
                fontWeight: FontWeight.bold,
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
                    groupValue: _generoSeleccionado,
                    // ignore: deprecated_member_use
                    onChanged: (value) {
                      setState(() {
                        _generoSeleccionado = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Femenino'),
                    value: 'Femenino',
                    // ignore: deprecated_member_use
                    groupValue: _generoSeleccionado,
                    // ignore: deprecated_member_use
                    onChanged: (value) {
                      setState(() {
                        _generoSeleccionado = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Campo Peso
            Text(
              'Peso (kg):',
              style: AppTextStyles.mainText.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _pesoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Ej: 70.5',
                prefixIcon: Icon(
                  Icons.fitness_center,
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
            ),

            SizedBox(height: 20),

            // Campo Altura
            Text(
              'Altura:',
              style: AppTextStyles.mainText.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _alturaController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: _unidadAltura == 'metros'
                          ? 'Ej: 1.75'
                          : 'Ej: 175',
                      prefixIcon: Icon(Icons.height, color: AppColors.primary),
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
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _unidadAltura,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'metros', child: Text('metros')),
                      DropdownMenuItem(value: 'centímetros', child: Text('cm')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _unidadAltura = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Botones
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _calcularIMC,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'CALCULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _limpiarCampos,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'LIMPIAR',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Resultado
            if (_mostrarResultado) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: _colorIMC.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _colorIMC, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(Icons.assessment, color: _colorIMC, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'Tu IMC es',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _imcCalculado.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _colorIMC,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _categoriaIMC,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _colorIMC,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _obtenerRecomendacion(_imcCalculado),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Tabla de referencia
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tabla de Referencia IMC:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildReferenceRow('< 18.5', 'Bajo peso', Colors.blue),
                    _buildReferenceRow(
                      '18.5 - 24.9',
                      'Peso normal',
                      Colors.green,
                    ),
                    _buildReferenceRow(
                      '25.0 - 29.9',
                      'Sobrepeso',
                      Colors.orange,
                    ),
                    _buildReferenceRow('≥ 30.0', 'Obesidad', Colors.red),
                  ],
                ),
              ),
            ],

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceRow(String rango, String categoria, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text('$rango - $categoria', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  String _obtenerRecomendacion(double imc) {
    if (imc < 18.5) {
      return 'Considera consultar con un profesional de la salud para evaluar tu peso y nutrición.';
    } else if (imc < 25.0) {
      return '¡Excelente! Mantienes un peso saludable. Continúa con una dieta balanceada y ejercicio regular.';
    } else if (imc < 30.0) {
      return 'Es recomendable adoptar hábitos más saludables: dieta equilibrada y actividad física regular.';
    } else {
      return 'Te recomendamos consultar con un profesional de la salud para un plan personalizado.';
    }
  }
}
