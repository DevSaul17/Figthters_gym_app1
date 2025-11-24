import 'package:flutter/material.dart';
import '../../constants.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MensajeScreen extends StatefulWidget {
  final Map<String, String> datosCita;
  final Map<String, dynamic> horarioSeleccionado;

  const MensajeScreen({
    super.key,
    required this.datosCita,
    required this.horarioSeleccionado,
  });

  @override
  State<MensajeScreen> createState() => _MensajeScreenState();
}

class _MensajeScreenState extends State<MensajeScreen> {
  bool _formatsReady = false;

  @override
  void initState() {
    super.initState();
    _initFormats();
  }

  Future<void> _initFormats() async {
    try {
      await initializeDateFormatting('es');
    } catch (_) {}
    if (mounted) setState(() => _formatsReady = true);
  }

  String _formatHorario(Map<String, dynamic> horario) {
    final rawFecha = horario['fecha'];
    DateTime dt;
    if (rawFecha is Timestamp) {
      dt = rawFecha.toDate();
    } else if (rawFecha is DateTime) {
      dt = rawFecha;
    } else if (rawFecha is String) {
      try {
        dt = DateTime.parse(rawFecha);
      } catch (e) {
        return rawFecha.toString();
      }
    } else {
      return '-';
    }

    try {
      final dia = DateFormat('EEEE', 'es').format(dt.toLocal()).toUpperCase();
      final fechaHora = DateFormat(
        "d 'de' MMMM 'de' y, h:mm a",
        'es',
      ).format(dt.toLocal());
      return '$dia $fechaHora';
    } catch (e) {
      return dt.toLocal().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.datosCita['nombre'] ?? '';
    final apellidos = widget.datosCita['apellidos'] ?? '';
    final citaTexto = _formatsReady
        ? _formatHorario(widget.horarioSeleccionado)
        : (widget.horarioSeleccionado['fecha']?.toString() ?? '-');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80.0,
        title: Text(
          'Confirmación',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),

            // Icono de éxito
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green[100],
              ),
              child: Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green[600],
              ),
            ),

            SizedBox(height: 30),

            // Título de confirmación
            Text(
              '¡Cita Confirmada!',
              style: AppTextStyles.mainText.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 20),

            // Mensaje
            Text(
              'Tu cita ha sido agendada exitosamente:',
              style: AppTextStyles.contactText.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 30),

            // Mensaje personalizado
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$nombre $apellidos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20),

                    Text(
                      'para el $citaTexto',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20),

                    Text(
                      '¡Felicitaciones por dar el primer paso hacia tu bienestar!',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Mensaje final
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                'Te contactaremos pronto para confirmar los detalles.',
                style: AppTextStyles.contactText.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.blue[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 30),

            // Botón de regreso al inicio
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: AppButtonStyles.primaryButton.copyWith(
                  backgroundColor: WidgetStateProperty.all(AppColors.primary),
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
                  'Volver al Inicio',
                  style: AppTextStyles.buttonText.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
