import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../../models/models.dart';

class AsistenciaScreen extends StatefulWidget {
  const AsistenciaScreen({super.key});

  @override
  State<AsistenciaScreen> createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  late TextEditingController _buscadorController;
  List<Cliente> _clientesEncontrados = [];
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    _buscadorController = TextEditingController();
  }

  @override
  void dispose() {
    _buscadorController.dispose();
    super.dispose();
  }

  Future<void> _buscarClientes(String query) async {
    if (query.isEmpty) {
      setState(() {
        _clientesEncontrados = [];
      });
      return;
    }

    setState(() {
      _buscando = true;
    });

    try {
      final clientesSnapshot = await FirebaseFirestore.instance
          .collection('clientes')
          .get();

      final queryLower = query.toLowerCase();
      final resultados = <Cliente>[];

      for (var doc in clientesSnapshot.docs) {
        final data = doc.data();
        final nombre = (data['nombre'] ?? '').toString().toLowerCase();
        final apellidos = (data['apellidos'] ?? '').toString().toLowerCase();
        final dni = (data['dni'] ?? '').toString().toLowerCase();

        if (nombre.contains(queryLower) ||
            apellidos.contains(queryLower) ||
            dni.contains(queryLower)) {
          // Crear modelo Cliente con campos básicos
          // Usamos el Map directo por compatibilidad con campos extendidos
          resultados.add(
            Cliente(
              id: doc.id,
              nombre: '${data['nombre'] ?? ''} ${data['apellidos'] ?? ''}',
              email: data['email'] ?? '',
              telefono: data['celular'] ?? '',
              fechaRegistro: data['creadoEn'] is Timestamp
                  ? (data['creadoEn'] as Timestamp).toDate()
                  : DateTime.now(),
              direccion:
                  data['dni'] ?? '', // Guardamos DNI en dirección temporalmente
            ),
          );
        }
      }

      setState(() {
        _clientesEncontrados = resultados;
        _buscando = false;
      });
    } catch (e) {
      print('Error al buscar clientes: $e');
      setState(() {
        _buscando = false;
      });
      if (mounted) {
        _showSnackBar('Error al buscar clientes', Colors.red);
      }
    }
  }

  Future<void> _registrarAsistencia(String clienteId, String nombre) async {
    try {
      // Crear modelo Asistencia
      final asistencia = Asistencia(
        id: '', // Se asignará automáticamente
        clienteId: clienteId,
        fechaHoraEntrada: DateTime.now(),
      );

      // Guardar usando el modelo (datos básicos)
      final asistenciaData = asistencia.toJson();

      // Agregar campos adicionales por compatibilidad
      final ahora = DateTime.now();
      asistenciaData['clienteNombre'] = nombre;
      asistenciaData['fecha'] = DateFormat('yyyy-MM-dd').format(ahora);
      asistenciaData['hora'] = DateFormat('HH:mm:ss').format(ahora);
      asistenciaData['fechaRegistro'] = Timestamp.now();

      await FirebaseFirestore.instance
          .collection('asistencias')
          .add(asistenciaData);

      if (mounted) {
        _showSnackBar(
          'Asistencia registrada: $nombre - ${asistencia.horaEntrada}',
          Colors.green,
        );
      }

      _buscadorController.clear();
      setState(() {
        _clientesEncontrados = [];
      });
    } catch (e) {
      print('Error al registrar asistencia: $e');
      if (mounted) {
        _showSnackBar('Error al registrar asistencia', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildClienteCard(Cliente cliente) {
    final dni =
        cliente.direccion ?? ''; // DNI guardado temporalmente en direccion
    final celular = cliente.telefono;

    // Edad - necesitariamos calcularla o guardarla en notas
    final edad = cliente.notas ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.person, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nombre,
                      style: AppTextStyles.mainText.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'DNI: $dni',
                      style: AppTextStyles.contactText.copyWith(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                celular,
                style: AppTextStyles.contactText.copyWith(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 24),
              Icon(Icons.cake, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                '$edad años',
                style: AppTextStyles.contactText.copyWith(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _registrarAsistencia(cliente.id, cliente.nombre),
              icon: const Icon(Icons.check_circle),
              label: const Text('Marcar Asistencia de Hoy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Asistencia'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscadorController,
                    onChanged: _buscarClientes,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o DNI...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _buscadorController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _buscadorController.clear();
                                setState(() {
                                  _clientesEncontrados = [];
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegistroAsistenciaScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('Registro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buscando
                ? const Center(child: CircularProgressIndicator())
                : _clientesEncontrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Comienza a buscar un cliente',
                          style: AppTextStyles.mainText.copyWith(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _clientesEncontrados.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildClienteCard(_clientesEncontrados[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class RegistroAsistenciaScreen extends StatefulWidget {
  const RegistroAsistenciaScreen({super.key});

  @override
  State<RegistroAsistenciaScreen> createState() =>
      _RegistroAsistenciaScreenState();
}

class _RegistroAsistenciaScreenState extends State<RegistroAsistenciaScreen> {
  late Stream<QuerySnapshot> _asistenciasStream;

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    final fechaHoy = DateFormat('yyyy-MM-dd').format(hoy);

    _asistenciasStream = FirebaseFirestore.instance
        .collection('asistencias')
        .where('fecha', isEqualTo: fechaHoy)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Asistencias'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _asistenciasStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final asistencias = snapshot.data?.docs ?? [];

          // Ordenar por hora descendente
          final asistenciasOrdenadas = [...asistencias];
          asistenciasOrdenadas.sort((a, b) {
            final horaA = (a.data() as Map<String, dynamic>)['hora'] ?? '';
            final horaB = (b.data() as Map<String, dynamic>)['hora'] ?? '';
            return horaB.compareTo(horaA); // Descendente
          });

          if (asistenciasOrdenadas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay asistencias registradas hoy',
                    style: AppTextStyles.mainText.copyWith(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: asistenciasOrdenadas.length,
            itemBuilder: (context, index) {
              final asistencia =
                  asistenciasOrdenadas[index].data() as Map<String, dynamic>;
              final nombre = asistencia['clienteNombre'] ?? '';
              final dni = asistencia['clienteDni'] ?? '';
              final hora = asistencia['hora'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            style: AppTextStyles.mainText.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'DNI: $dni',
                            style: AppTextStyles.contactText.copyWith(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      hora,
                      style: AppTextStyles.mainText.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
