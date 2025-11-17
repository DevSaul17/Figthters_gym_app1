import 'package:flutter/material.dart';
import '../../constants.dart';
import 'registro_cliente_screen.dart';
import 'agregar_horario_cita_screen.dart';
import 'configuracion_screen.dart';
import '../../home_screen.dart';

class HomeGymScreen extends StatefulWidget {
  final String nombreEmpleado;

  const HomeGymScreen({super.key, required this.nombreEmpleado});

  @override
  State<HomeGymScreen> createState() => _HomeGymScreenState();
}

class _HomeGymScreenState extends State<HomeGymScreen> {
  int _selectedIndex = 0;

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
              Expanded(
                child: _buildStatCard(
                  'Citas Hoy',
                  '12',
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ),
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
              Expanded(
                child: _buildStatCard(
                  'Equipos en Activos',
                  '8',
                  Icons.fitness_center,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Ingresos Hoy',
                  '\$450',
                  Icons.attach_money,
                  Colors.purple,
                ),
              ),
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
                  'Ver Reportes',
                  Icons.bar_chart,
                  Colors.orange,
                  () => _mostrarEnDesarrollo('Reportes'),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 80,
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.6),
          ),
          SizedBox(height: 16),
          Text(
            'Gestión de Clientes',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('Módulo en desarrollo...', style: AppTextStyles.contactText),
        ],
      ),
    );
  }

  Widget _buildCitas() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.6),
          ),
          SizedBox(height: 16),
          Text(
            'Gestión de Citas',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('Módulo en desarrollo...', style: AppTextStyles.contactText),
        ],
      ),
    );
  }

  Widget _buildEquipos() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.6),
          ),
          SizedBox(height: 16),
          Text(
            'Gestión de Equipos',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('Módulo en desarrollo...', style: AppTextStyles.contactText),
        ],
      ),
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

  void _mostrarEnDesarrollo(String modulo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$modulo en desarrollo...'),
        backgroundColor: Colors.orange,
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
}
