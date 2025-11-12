import 'package:flutter/material.dart';
import '../../constants.dart';
import 'datos_cita_screen.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  int? selectedIndex;

  final List<Map<String, dynamic>> horarios = [
    {
      'dia': 'LUNES',
      'fecha': '27/10/2025',
      'hora': '13:00',
      'isSelected': false,
      'color': Colors.black,
    },
    {
      'dia': 'MARTES',
      'fecha': '28/10/2025',
      'hora': '14:00',
      'isSelected': false,
      'color': Colors.red,
    },
    {
      'dia': 'MIÉRCOLES',
      'fecha': '29/10/2025',
      'hora': '15:00',
      'isSelected': false,
      'color': Colors.black,
    },
    {
      'dia': 'MIÉRCOLES',
      'fecha': '29/10/2025',
      'hora': '16:00',
      'isSelected': false,
      'color': Colors.red,
    },
    {
      'dia': 'VIERNES',
      'fecha': '31/10/2025',
      'hora': '17:00',
      'isSelected': false,
      'color': Colors.black,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80.0, // Aumenta la altura del AppBar
        title: Text('Horarios', style: AppTextStyles.appBarTitle),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.horarioImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Lista de horarios
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
                child: ListView.builder(
                  itemCount: horarios.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildHorarioCard(index),
                    );
                  },
                ),
              ),
            ),

            // Botón Seleccionar Horario
            Padding(
              padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedIndex != null
                      ? () {
                          // Navegar a la pantalla de datos de cita
                          final horarioSeleccionado = horarios[selectedIndex!];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DatosCitaScreen(
                                horarioSeleccionado: horarioSeleccionado,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: AppButtonStyles.primaryButton.copyWith(
                    backgroundColor: WidgetStateProperty.all(
                      selectedIndex != null
                          ? AppColors.primary
                          : Colors.grey[400],
                    ),
                  ),
                  child: Text(
                    'Seleccionar Horario',
                    style: AppTextStyles.buttonText,
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

  Widget _buildHorarioCard(int index) {
    final horario = horarios[index];
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: horario['color'],
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.blue, width: 3) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  horario['dia'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${horario['fecha']} ${horario['hora']}',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
