import 'package:flutter/material.dart';
import '../../constants.dart';

class AgregarHorarioCitaScreen extends StatefulWidget {
  const AgregarHorarioCitaScreen({super.key});

  @override
  State<AgregarHorarioCitaScreen> createState() =>
      _AgregarHorarioCitaScreenState();
}

class _AgregarHorarioCitaScreenState extends State<AgregarHorarioCitaScreen> {
  // Lista de citas programadas (inicialmente vacía)
  final List<Map<String, dynamic>> _citasProgramadas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80.0,
        title: Text(
          'HORARIOS DE CITAS',
          style: AppTextStyles.appBarTitle.copyWith(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _citasProgramadas.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _citasProgramadas.length,
              itemBuilder: (context, index) {
                final cita = _citasProgramadas[index];
                return _buildCitaItem(cita, index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarAAgregarCita,
        backgroundColor: Colors.grey[400],
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No hay citas programadas',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Presiona el botón + para agregar una nueva cita',
            style: AppTextStyles.contactText.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCitaItem(Map<String, dynamic> cita, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono de calendario
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          // Información de la cita
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cita['fecha']} ${cita['hora']}',
                  style: AppTextStyles.mainText.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  cita['tipoServicio'],
                  style: AppTextStyles.contactText.copyWith(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Botones de acción
          Row(
            children: [
              IconButton(
                onPressed: () => _editarCita(index),
                icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              SizedBox(width: 8),
              IconButton(
                onPressed: () => _eliminarCita(index),
                icon: Icon(Icons.delete, color: Colors.red, size: 20),
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navegarAAgregarCita() {
    DateTime? fechaSeleccionada;
    TimeOfDay? horaSeleccionada;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Agregar Nueva Cita',
            style: AppTextStyles.mainText.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Seleccionar fecha
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final DateTime? fecha = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                        helpText: 'Seleccionar fecha de la cita',
                        cancelText: 'Cancelar',
                        confirmText: 'Confirmar',
                      );
                      if (fecha != null) {
                        setDialogState(() {
                          fechaSeleccionada = fecha;
                        });
                      }
                    },
                    icon: Icon(Icons.calendar_today),
                    label: Text(
                      fechaSeleccionada != null
                          ? '${fechaSeleccionada!.day.toString().padLeft(2, '0')}/${fechaSeleccionada!.month.toString().padLeft(2, '0')}/${fechaSeleccionada!.year}'
                          : 'Seleccionar Fecha',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Seleccionar hora
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final TimeOfDay? hora = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        helpText: 'Seleccionar hora de la cita',
                        cancelText: 'Cancelar',
                        confirmText: 'Confirmar',
                      );
                      if (hora != null) {
                        setDialogState(() {
                          horaSeleccionada = hora;
                        });
                      }
                    },
                    icon: Icon(Icons.access_time),
                    label: Text(
                      horaSeleccionada != null
                          ? horaSeleccionada!.format(context)
                          : 'Seleccionar Hora',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
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
              onPressed: fechaSeleccionada != null && horaSeleccionada != null
                  ? () {
                      // Agregar la nueva cita a la lista
                      setState(() {
                        _citasProgramadas.add({
                          'fecha':
                              '${fechaSeleccionada!.year}-${fechaSeleccionada!.month.toString().padLeft(2, '0')}-${fechaSeleccionada!.day.toString().padLeft(2, '0')}',
                          'hora': horaSeleccionada!.format(context),
                          'tipoServicio': 'Cita general',
                          'duracion': 60,
                        });
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cita agregada exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _editarCita(int index) {
    final cita = _citasProgramadas[index];

    // Convertir la fecha de string a DateTime
    final fechaParts = cita['fecha'].split('-');
    DateTime? fechaSeleccionada = DateTime(
      int.parse(fechaParts[0]), // año
      int.parse(fechaParts[1]), // mes
      int.parse(fechaParts[2]), // día
    );

    // Convertir la hora de string a TimeOfDay con manejo de errores
    TimeOfDay? horaSeleccionada;
    try {
      final horaString = cita['hora'];
      // Remover AM/PM si existe y hacer split
      final horaLimpia = horaString.replaceAll(RegExp(r'\s*(AM|PM)\s*'), '');
      final horaParts = horaLimpia.split(':');

      if (horaParts.length >= 2) {
        int hour = int.parse(horaParts[0]);
        int minute = int.parse(horaParts[1]);

        // Si la hora original tenía PM y no es 12, agregar 12 horas
        if (horaString.toUpperCase().contains('PM') && hour != 12) {
          hour += 12;
        }
        // Si la hora original tenía AM y es 12, convertir a 0
        else if (horaString.toUpperCase().contains('AM') && hour == 12) {
          hour = 0;
        }

        horaSeleccionada = TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Si falla el parsing, usar hora actual como fallback
      horaSeleccionada = TimeOfDay.now();
    }

    // Si aún es null, usar hora actual
    horaSeleccionada ??= TimeOfDay.now();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Editar Cita',
            style: AppTextStyles.mainText.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Información actual
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    // ignore: deprecated_member_use
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cita actual:',
                        style: AppTextStyles.contactText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${cita['fecha']} ${cita['hora']}',
                        style: AppTextStyles.contactText.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        cita['tipoServicio'],
                        style: AppTextStyles.contactText.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Selecciona nueva fecha y hora:',
                  style: AppTextStyles.contactText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                // Seleccionar nueva fecha
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final DateTime? fecha = await showDatePicker(
                        context: context,
                        initialDate: fechaSeleccionada ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                        helpText: 'Seleccionar nueva fecha',
                        cancelText: 'Cancelar',
                        confirmText: 'Confirmar',
                      );
                      if (fecha != null) {
                        setDialogState(() {
                          fechaSeleccionada = fecha;
                        });
                      }
                    },
                    icon: Icon(Icons.calendar_today),
                    label: Text(
                      fechaSeleccionada != null
                          ? '${fechaSeleccionada!.day.toString().padLeft(2, '0')}/${fechaSeleccionada!.month.toString().padLeft(2, '0')}/${fechaSeleccionada!.year}'
                          : 'Seleccionar Fecha',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // Seleccionar nueva hora
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final TimeOfDay? hora = await showTimePicker(
                        context: context,
                        initialTime: horaSeleccionada ?? TimeOfDay.now(),
                        helpText: 'Seleccionar nueva hora',
                        cancelText: 'Cancelar',
                        confirmText: 'Confirmar',
                      );
                      if (hora != null) {
                        setDialogState(() {
                          horaSeleccionada = hora;
                        });
                      }
                    },
                    icon: Icon(Icons.access_time),
                    label: Text(
                      horaSeleccionada != null
                          ? horaSeleccionada!.format(context)
                          : 'Seleccionar Hora',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
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
              onPressed: fechaSeleccionada != null && horaSeleccionada != null
                  ? () {
                      // Actualizar la cita en la lista
                      setState(() {
                        _citasProgramadas[index] = {
                          ..._citasProgramadas[index],
                          'fecha':
                              '${fechaSeleccionada!.year}-${fechaSeleccionada!.month.toString().padLeft(2, '0')}-${fechaSeleccionada!.day.toString().padLeft(2, '0')}',
                          'hora': horaSeleccionada!.format(context),
                        };
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cita actualizada exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  void _eliminarCita(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Cita'),
        content: Text('¿Estás seguro de que quieres eliminar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _citasProgramadas.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cita eliminada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
