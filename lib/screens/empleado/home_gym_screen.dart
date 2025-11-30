import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'registro_cliente_screen.dart';
import 'agregar_horario_cita_screen.dart';
import 'configuracion_screen.dart';
import 'equipos_screen.dart';
import 'registro_membresia_screen.dart';
import 'generar_credenciales_screen.dart';
import 'citas_screen.dart';
import '../../home_screen.dart';

class HomeGymScreen extends StatefulWidget {
  final String nombreEmpleado;

  const HomeGymScreen({super.key, required this.nombreEmpleado});

  @override
  State<HomeGymScreen> createState() => _HomeGymScreenState();
}

class _HomeGymScreenState extends State<HomeGymScreen> {
  int _selectedIndex = 0;
  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        toolbarHeight: 80.0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'GESTIÓN GYM',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle, color: Colors.white, size: 30),
            onSelected: (value) {
              if (value == 'logout') {
                _mostrarDialogCerrarSesion();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'perfil',
                child: Row(
                  children: [
                    Icon(Icons.person, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Perfil: ${widget.nombreEmpleado}'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
            label: 'Panel',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            selectedIcon: Icon(Icons.people, color: AppColors.primary),
            label: 'Clientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            selectedIcon: Icon(Icons.calendar_today, color: AppColors.primary),
            label: 'Citas',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            selectedIcon: Icon(Icons.fitness_center, color: AppColors.primary),
            label: 'Equipos',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildClientes();
      case 2:
        return _buildCitas();
      case 3:
        return _buildEquipos();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saludo personalizado
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // ignore: deprecated_member_use
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, ${widget.nombreEmpleado}!',
                  style: AppTextStyles.appBarTitle.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Bienvenido al panel de gestión',
                  style: AppTextStyles.contactText.copyWith(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Estadísticas rápidas
          Text(
            'Resumen del día',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _buildCitasHoyCard()),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Clientes Asistentes',
                  '3',
                  Icons.how_to_reg,
                  Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _buildEquiposActivosCard()),
              SizedBox(width: 12),
              Expanded(child: _buildIngresosHoyCard()),
            ],
          ),

          SizedBox(height: 24),

          // Acciones rápidas
          Text(
            'Acciones Rápidas',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildActionCard(
                  'Registrar Cliente',
                  Icons.person_add,
                  Colors.blue,
                  () => _navegarARegistroCliente(),
                ),
                _buildActionCard(
                  'Horarios de citas',
                  Icons.calendar_today,
                  Colors.green,
                  () => _navegarAAgregarHorarioCita(),
                ),
                _buildActionCard(
                  'Generar credenciales',
                  Icons.vpn_key,
                  Colors.orange,
                  () => _navegarAGenerarCredenciales(),
                ),
                _buildActionCard(
                  'Configuración',
                  Icons.settings,
                  Colors.purple,
                  () => _navegarAConfiguracion(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientes() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header con título y botón de agregar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Clientes',
                style: AppTextStyles.mainText.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _navegarARegistroCliente,
                icon: Icon(Icons.person_add, color: Colors.white),
                label: Text('Agregar', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Lista de clientes con membresías
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('membresias')
                  .snapshots(),
              builder: (context, membresiaSnapshot) {
                if (membresiaSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text('Cargando clientes...'),
                      ],
                    ),
                  );
                }

                if (membresiaSnapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 60),
                        SizedBox(height: 16),
                        Text(
                          'Error al cargar clientes: ${membresiaSnapshot.error}',
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                // Obtener IDs únicos de clientes que tienen membresías
                final membresiasData = membresiaSnapshot.data?.docs ?? [];
                final clienteIds = <String>{};

                for (var doc in membresiasData) {
                  final data = doc.data() as Map<String, dynamic>;
                  final clienteId = data['clienteId'];
                  if (clienteId != null) {
                    clienteIds.add(clienteId.toString());
                  }
                }

                if (clienteIds.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          // ignore: deprecated_member_use
                          color: AppColors.primary.withOpacity(0.6),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay clientes con membresías',
                          style: AppTextStyles.mainText.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Los clientes con membresías aparecerán aquí',
                          style: AppTextStyles.contactText.copyWith(
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Ahora obtener los datos de los clientes que tienen membresías
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('clientes')
                      .snapshots(),
                  builder: (context, clienteSnapshot) {
                    if (clienteSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (clienteSnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar clientes',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    // Filtrar clientes que tienen membresías
                    final allClienteDocs = clienteSnapshot.data?.docs ?? [];
                    final clienteDocs = allClienteDocs.where((doc) {
                      return clienteIds.contains(doc.id);
                    }).toList();

                    // Ordenar por fecha de creación (más recientes primero)
                    clienteDocs.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTimestamp = aData['creadoEn'] as Timestamp?;
                      final bTimestamp = bData['creadoEn'] as Timestamp?;

                      if (aTimestamp == null && bTimestamp == null) return 0;
                      if (aTimestamp == null) return 1;
                      if (bTimestamp == null) return -1;

                      return bTimestamp.compareTo(aTimestamp);
                    });

                    return ListView.separated(
                      itemCount: clienteDocs.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final clienteDoc = clienteDocs[index];
                        final clienteData =
                            clienteDoc.data() as Map<String, dynamic>;

                        return _buildClienteCard(clienteDoc.id, clienteData);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClienteCard(String clienteId, Map<String, dynamic> clienteData) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Información del cliente
          ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.person, color: AppColors.primary, size: 24),
            ),
            title: Text(
              '${clienteData['nombre'] ?? ''} ${clienteData['apellidos'] ?? ''}',
              style: AppTextStyles.mainText.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  'DNI: ${clienteData['dni'] ?? 'N/A'}',
                  style: AppTextStyles.contactText.copyWith(fontSize: 13),
                ),
                Text(
                  'Tel: ${clienteData['celular'] ?? 'N/A'}',
                  style: AppTextStyles.contactText.copyWith(fontSize: 13),
                ),
                Text(
                  'Edad: ${clienteData['edad']?.toString() ?? 'N/A'} años',
                  style: AppTextStyles.contactText.copyWith(fontSize: 13),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppColors.primary),
              onSelected: (value) {
                switch (value) {
                  case 'ver':
                    _mostrarDetallesCliente(clienteId, clienteData);
                    break;
                  case 'membresias':
                    _mostrarMembresiasCliente(clienteId, clienteData);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'ver',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Ver Detalles'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'membresias',
                  child: Row(
                    children: [
                      Icon(Icons.card_membership, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Membresías'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Membresía activa (si existe)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('membresias')
                .where('clienteId', isEqualTo: clienteId)
                .where('activa', isEqualTo: true)
                .where('estado', isEqualTo: 'pagada')
                .limit(1)
                .snapshots(),
            builder: (context, membresiaSnapshot) {
              if (membresiaSnapshot.hasData &&
                  membresiaSnapshot.data!.docs.isNotEmpty) {
                final membresiaData =
                    membresiaSnapshot.data!.docs.first.data()
                        as Map<String, dynamic>;

                final fechaFin = (membresiaData['fechaFin'] as Timestamp?)
                    ?.toDate();
                final diasRestantes = fechaFin != null
                    ? fechaFin.difference(DateTime.now()).inDays
                    : 0;

                Color estadoColor = Colors.green;
                String estadoTexto = 'Activa';

                if (diasRestantes < 0) {
                  estadoColor = Colors.red;
                  estadoTexto = 'Vencida';
                } else if (diasRestantes <= 7) {
                  estadoColor = Colors.orange;
                  estadoTexto = 'Por vencer';
                }

                return Container(
                  margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: estadoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    // ignore: deprecated_member_use
                    border: Border.all(color: estadoColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.card_membership, color: estadoColor, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              membresiaData['planNombre'] ?? 'Plan N/A',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: estadoColor,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '$estadoTexto${diasRestantes >= 0 ? ' ($diasRestantes días)' : ''}',
                              style: TextStyle(
                                color: estadoColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Container(
                  margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    // ignore: deprecated_member_use
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sin membresía activa',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _completarMembresia(clienteId, clienteData),
                              icon: Icon(Icons.add_card, size: 16),
                              label: Text(
                                'Completar Membresía',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCitas() {
    return CitasScreen();
  }

  Widget _buildEquipos() {
    return EquiposScreen();
  }

  Widget _buildEquiposActivosCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.streamCollection(
        'equipos',
        queryBuilder: (q) => q.where('activo', isEqualTo: true),
      ),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return _buildStatCard(
          'Equipos Activos',
          '$count',
          Icons.fitness_center,
          Colors.orange,
        );
      },
    );
  }

  Widget _buildCitasHoyCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('prospectos').snapshots(),
      builder: (context, snapshot) {
        int citasHoy = 0;

        if (snapshot.hasData) {
          final hoy = DateTime.now();
          final inicio = DateTime(hoy.year, hoy.month, hoy.day);
          final fin = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);

          citasHoy = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final citaFecha = data['citaFecha'];

            if (citaFecha == null) return false;

            DateTime? fecha;
            if (citaFecha is Timestamp) {
              fecha = citaFecha.toDate();
            } else if (citaFecha is DateTime) {
              fecha = citaFecha;
            }

            if (fecha == null) return false;

            return fecha.isAfter(inicio) && fecha.isBefore(fin);
          }).length;
        }

        return _buildStatCard(
          'Citas Hoy',
          '$citasHoy',
          Icons.calendar_today,
          Colors.blue,
        );
      },
    );
  }

  Widget _buildIngresosHoyCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('membresias').snapshots(),
      builder: (context, snapshot) {
        double ingresosHoy = 0.0;

        if (snapshot.hasData) {
          final hoy = DateTime.now();
          final inicio = DateTime(hoy.year, hoy.month, hoy.day);
          final fin = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);

          // ignore: avoid_types_as_parameter_names
          ingresosHoy = snapshot.data!.docs.fold(0.0, (sum, doc) {
            final data = doc.data() as Map<String, dynamic>;
            final fechaPago = data['fechaPago'];
            final estado = data['estado'];
            final monto = data['monto'];

            // Solo contar pagos completados de hoy
            if (estado != 'pagada' || monto == null) return sum;

            if (fechaPago == null) return sum;

            DateTime? fecha;
            if (fechaPago is Timestamp) {
              fecha = fechaPago.toDate();
            } else if (fechaPago is DateTime) {
              fecha = fechaPago;
            }

            if (fecha == null) return sum;

            if (fecha.isAfter(inicio) && fecha.isBefore(fin)) {
              return sum + (monto as num).toDouble();
            }
            return sum;
          });
        }

        final montoFormato = ingresosHoy.toStringAsFixed(2);

        return _buildStatCard(
          'Ingresos Hoy',
          'S/.$montoFormato',
          Icons.attach_money,
          Colors.purple,
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.contactText.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          // ignore: deprecated_member_use
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.contactText.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogCerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.logout, color: Colors.red, size: 50),
        title: Text(
          'Cerrar Sesión',
          style: AppTextStyles.mainText.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: AppTextStyles.contactText,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar dialog
              // Navegar a la pantalla home y limpiar el stack
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navegarARegistroCliente() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroClienteScreen()),
    );
  }

  void _navegarAAgregarHorarioCita() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgregarHorarioCitaScreen()),
    );
  }

  void _navegarAConfiguracion() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConfiguracionScreen()),
    );
  }

  void _navegarAGenerarCredenciales() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GenerarCredencialesScreen(),
      ),
    );
  }

  void _completarMembresia(
    String clienteId,
    Map<String, dynamic> clienteData,
  ) async {
    // Navegamos a registro de membresía con cliente preseleccionado
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroMembresiaScreen(
          datosCliente: {
            'clienteId': clienteId,
            'nombre': '${clienteData['nombre']} ${clienteData['apellidos']}',
            'dni': clienteData['dni'] ?? '',
          },
        ),
      ),
    );

    // Verificar que el widget aún esté montado antes de usar context
    if (!mounted) return;

    // Si el proceso se completó exitosamente (membresía y pago)
    if (resultado != null && resultado['pagoCompletado'] == true) {
      // Asegurar que estamos en la pestaña de clientes
      setState(() {
        _selectedIndex = 1; // Índice de la pestaña de clientes
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Membresía y pago completados exitosamente!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } else if (resultado != null && resultado['membresiaCreada'] == true) {
      // Solo se creó la membresía pero falta el pago
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membresía creada. Pendiente de pago.'),
          backgroundColor: Colors.orange,
        ),
      );

      // Refrescar la vista para mostrar la membresía pendiente
      setState(() {});
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _mostrarDetallesCliente(
    String clienteId,
    Map<String, dynamic> clienteData,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.blue),
            SizedBox(width: 8),
            Text('Detalles del Cliente', style: TextStyle(color: Colors.blue)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Nombre', clienteData['nombre'] ?? 'N/A'),
              _detailRow('Apellidos', clienteData['apellidos'] ?? 'N/A'),
              _detailRow('DNI', clienteData['dni'] ?? 'N/A'),
              _detailRow('Email', clienteData['email'] ?? 'N/A'),
              _detailRow('Celular', clienteData['celular'] ?? 'N/A'),
              _detailRow('Edad', clienteData['edad']?.toString() ?? 'N/A'),
              _detailRow('Género', clienteData['genero'] ?? 'N/A'),
              _detailRow(
                'Peso',
                '${clienteData['peso']?.toString() ?? 'N/A'} kg',
              ),
              _detailRow(
                'Talla',
                '${clienteData['talla']?.toString() ?? 'N/A'} cm',
              ),
              _detailRow(
                'Condición Física',
                clienteData['condicionFisica'] ?? 'N/A',
              ),
              if (clienteData['fechaNacimiento'] != null)
                _detailRow('Fecha Nacimiento', clienteData['fechaNacimiento']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarMembresiasCliente(
    String clienteId,
    Map<String, dynamic> clienteData,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.card_membership, color: Colors.green),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Membresías de ${clienteData['nombre']} ${clienteData['apellidos']}',
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('membresias')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'Error al cargar membresías',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Detalles: ${snapshot.error}',
                        style: TextStyle(color: Colors.red[300], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // Filtrar membresías por clienteId en el lado del cliente
              final allMembresias = snapshot.data?.docs ?? [];
              final membresias = allMembresias.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['clienteId'] == clienteId;
              }).toList();

              // Ordenar por fecha de creación (más recientes primero)
              membresias.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aTimestamp = aData['fechaCreacion'] as Timestamp?;
                final bTimestamp = bData['fechaCreacion'] as Timestamp?;

                if (aTimestamp == null && bTimestamp == null) return 0;
                if (aTimestamp == null) return 1;
                if (bTimestamp == null) return -1;

                return bTimestamp.compareTo(aTimestamp);
              });

              if (membresias.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_membership_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Sin membresías registradas',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: membresias.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final membresiaData =
                      membresias[index].data() as Map<String, dynamic>;

                  final fechaInicio =
                      (membresiaData['fechaInicio'] as Timestamp?)?.toDate();
                  final fechaFin = (membresiaData['fechaFin'] as Timestamp?)
                      ?.toDate();
                  final estado = membresiaData['estado'] ?? 'pendiente';

                  Color estadoColor = Colors.grey;
                  IconData estadoIcon = Icons.help_outline;

                  switch (estado) {
                    case 'pagada':
                      estadoColor = Colors.green;
                      estadoIcon = Icons.check_circle;
                      break;
                    case 'pendiente_pago':
                      estadoColor = Colors.orange;
                      estadoIcon = Icons.schedule;
                      break;
                    case 'vencida':
                      estadoColor = Colors.red;
                      estadoIcon = Icons.error;
                      break;
                  }

                  return Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: estadoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      // ignore: deprecated_member_use
                      border: Border.all(color: estadoColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(estadoIcon, color: estadoColor, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                membresiaData['planNombre'] ?? 'Plan N/A',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: estadoColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Estado: ${estado.replaceAll('_', ' ').toUpperCase()}',
                          style: TextStyle(
                            color: estadoColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (fechaInicio != null)
                          Text(
                            'Inicio: ${DateFormat('dd/MM/yyyy').format(fechaInicio)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (fechaFin != null)
                          Text(
                            'Fin: ${DateFormat('dd/MM/yyyy').format(fechaFin)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (membresiaData['frecuencia'] != null)
                          Text(
                            'Frecuencia: ${membresiaData['frecuencia']} días/semana',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (membresiaData['diasSeleccionados'] != null)
                          Text(
                            'Días: ${(membresiaData['diasSeleccionados'] as List).join(', ')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
