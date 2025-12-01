import 'package:flutter/material.dart';
import '../../constants.dart';
import 'datos_cita_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  // ID del documento seleccionado
  String? selectedId;
  // Mapa con los datos del documento seleccionado para navegar
  Map<String, dynamic>? _selectedHorario;

  final FirestoreService _firestore = FirestoreService();
  bool _formatsReady = false;

  @override
  void initState() {
    super.initState();
    _initializeDateFormats();
  }

  Future<void> _initializeDateFormats() async {
    try {
      await initializeDateFormatting('es');
    } catch (e) {
      // If initialization fails, we still allow the UI to continue; DateFormat
      // will fallback to default formatting.
    }
    if (mounted) setState(() => _formatsReady = true);
  }

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
            // Lista de horarios (desde Firestore)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
                child: !_formatsReady
                    ? Center(child: CircularProgressIndicator())
                    : StreamBuilder<QuerySnapshot>(
                        stream: _firestore.streamCollection(
                          'citas',
                          queryBuilder: (q) =>
                              q.orderBy('fecha', descending: false),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error al cargar horarios'),
                            );
                          }
                          final docs = snapshot.data?.docs ?? [];

                          // Filtrar horarios vencidos (fecha y hora pasadas)
                          final now = DateTime.now();
                          final horariosValidos = docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final rawFecha = data['fecha'];

                            DateTime dt;
                            if (rawFecha is Timestamp) {
                              dt = rawFecha.toDate();
                            } else if (rawFecha is DateTime) {
                              dt = rawFecha;
                            } else if (rawFecha is String) {
                              try {
                                dt = DateTime.parse(rawFecha);
                              } catch (e) {
                                return true; // Si hay error al parsear, mostrar
                              }
                            } else {
                              return true; // Si no hay fecha, mostrar
                            }

                            // Solo mostrar si la fecha/hora es futura
                            return dt.isAfter(now);
                          }).toList();

                          if (horariosValidos.isEmpty) {
                            return Center(
                              child: Text('No hay horarios disponibles'),
                            );
                          }

                          return ListView.builder(
                            itemCount: horariosValidos.length,
                            itemBuilder: (context, index) {
                              final doc = horariosValidos[index];
                              final data = {
                                ...doc.data() as Map<String, dynamic>,
                                'id': doc.id,
                              };
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildHorarioCardFromDoc(data),
                              );
                            },
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
                  onPressed: _selectedHorario != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DatosCitaScreen(
                                horarioSeleccionado: _selectedHorario!,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: AppButtonStyles.primaryButton.copyWith(
                    backgroundColor: WidgetStateProperty.all(
                      _selectedHorario != null
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

  Widget _buildHorarioCardFromDoc(Map<String, dynamic> horario) {
    final String docId = (horario['id'] ?? '') as String;
    // Determine availability color
    final bool disponible = (horario['disponible'] == null)
        ? true
        : (horario['disponible'] as bool);
    final Color cardColor = disponible ? Colors.black : Colors.red;

    // Parse fecha (could be Timestamp or String)
    DateTime dt;
    final rawFecha = horario['fecha'];
    if (rawFecha is Timestamp) {
      dt = rawFecha.toDate();
    } else if (rawFecha is DateTime) {
      dt = rawFecha;
    } else if (rawFecha is String) {
      try {
        dt = DateTime.parse(rawFecha);
      } catch (e) {
        dt = DateTime.now();
      }
    } else {
      dt = DateTime.now();
    }

    final diaStr = DateFormat('EEEE', 'es').format(dt.toLocal()).toUpperCase();
    final fechaStr = DateFormat('d/MM/yyyy', 'es').format(dt.toLocal());
    final horaStr = DateFormat('h:mm a', 'es').format(dt.toLocal());

    final isSelected = selectedId != null && selectedId == docId;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedId = docId;
          _selectedHorario = horario;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
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
                  diaStr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$fechaStr $horaStr',
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
